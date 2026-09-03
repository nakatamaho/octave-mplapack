// SPDX-License-Identifier: BSD-2-Clause

#include "mp_lapack.h"

#include <iostream>
#include <initializer_list>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

namespace
{

using octave_mplapack::MpfrCholeskyResult;
using octave_mplapack::MpfrMatrixStorage;
using Real = mpfrxx::mpfr_class;

void
check (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

MpfrMatrixStorage
matrix (std::size_t rows, std::size_t columns, mpfr_prec_t precision,
        std::initializer_list<const char*> values)
{
  return MpfrMatrixStorage (rows, columns, precision,
                            std::vector<std::string> (values.begin (),
                                                      values.end ()));
}

void
check_factor (const MpfrCholeskyResult& result, std::size_t rows,
              std::size_t columns, const char *message)
{
  check (result.info == 0 && result.factor.rows () == rows
         && result.factor.columns () == columns, message);
  check (result.factor.precision_bits () == 1024,
         "Cholesky result precision mismatch");
}

void
test_triangle_selection ()
{
  const auto upper_input = matrix (2, 2, 1024,
                                   {"4", "999", "2", "10"});
  const auto upper_before = upper_input;
  const auto upper
    = octave_mplapack::mplapack_mpfr_matrix_cholesky (upper_input, false);
  check_factor (upper, 2, 2, "upper factor metadata mismatch");
  check (upper.factor.element_exactly_equal_text (0, 0, "2")
         && upper.factor.element_exactly_equal_text (0, 1, "1")
         && upper.factor.element_exactly_equal_text (1, 1, "3")
         && mpfr_zero_p (upper.factor.at (1, 0).mpfr_data ()) != 0,
         "upper factor values mismatch");
  check (upper_input.element_exactly_equal (0, 0, upper_before, 0, 0)
         && upper_input.element_exactly_equal (1, 1, upper_before, 1, 1),
         "upper Cholesky modified input");

  const auto lower_input = matrix (2, 2, 1024,
                                   {"4", "2", "999", "10"});
  const auto lower
    = octave_mplapack::mplapack_mpfr_matrix_cholesky (lower_input, true);
  check_factor (lower, 2, 2, "lower factor metadata mismatch");
  check (lower.factor.element_exactly_equal_text (0, 0, "2")
         && lower.factor.element_exactly_equal_text (1, 0, "1")
         && lower.factor.element_exactly_equal_text (1, 1, "3")
         && mpfr_zero_p (lower.factor.at (0, 1).mpfr_data ()) != 0,
         "lower factor values mismatch");
}

void
test_precision_and_empty ()
{
  mpfrxx::set_default_precision_bits (128);
  for (const auto case_data : {std::pair<mpfr_prec_t, long> (1024, -700),
                               std::pair<mpfr_prec_t, long> (2048, -1500)})
    {
      const mpfr_prec_t precision = case_data.first;
      auto input = MpfrMatrixStorage (2, 2, precision);
      mpfr_set_ui (input.at (0, 0).mpfr_data (), 1, MPFR_RNDN);
      mpfr_set_ui (input.at (1, 0).mpfr_data (), 1, MPFR_RNDN);
      mpfr_set_ui (input.at (0, 1).mpfr_data (), 1, MPFR_RNDN);
      Real delta = Real::with_precision (precision);
      mpfr_set_ui_2exp (delta.mpfr_data (), 1, case_data.second, MPFR_RNDN);
      mpfr_add (input.at (1, 1).mpfr_data (), delta.mpfr_data (),
                input.at (0, 0).mpfr_data (), MPFR_RNDN);
      const auto result
        = octave_mplapack::mplapack_mpfr_matrix_cholesky (input, false);
      check (result.info == 0 && result.factor.precision_bits () == precision,
             "precision Cholesky metadata mismatch");
      Real expected = Real::with_precision (precision);
      mpfr_set_ui_2exp (expected.mpfr_data (), 1, case_data.second / 2,
                        MPFR_RNDN);
      check (mpfr_equal_p (result.factor.at (1, 1).mpfr_data (),
                           expected.mpfr_data ()) != 0,
             "precision Cholesky tail mismatch");
      check (mpfrxx::default_precision_bits () == 128,
             "Cholesky leaked ambient precision");
    }

  const auto empty = MpfrMatrixStorage (0, 0, 2048);
  const auto empty_result
    = octave_mplapack::mplapack_mpfr_matrix_cholesky (empty, false);
  check (empty_result.info == 0 && empty_result.factor.rows () == 0
         && empty_result.factor.columns () == 0
         && empty_result.factor.precision_bits () == 2048,
         "empty Cholesky result mismatch");
}

void
test_precision_dependent_pd ()
{
  MpfrMatrixStorage low (2, 2, 512);
  MpfrMatrixStorage high (2, 2, 1024);
  for (MpfrMatrixStorage* input : {&low, &high})
    {
      mpfr_set_ui (input->at (0, 0).mpfr_data (), 1, MPFR_RNDN);
      mpfr_set_ui (input->at (1, 0).mpfr_data (), 1, MPFR_RNDN);
      mpfr_set_ui (input->at (0, 1).mpfr_data (), 1, MPFR_RNDN);
      Real delta = Real::with_precision (input->precision_bits ());
      mpfr_set_ui_2exp (delta.mpfr_data (), 1, -700, MPFR_RNDN);
      mpfr_add (input->at (1, 1).mpfr_data (), delta.mpfr_data (),
                input->at (0, 0).mpfr_data (), MPFR_RNDN);
    }
  const auto low_result
    = octave_mplapack::mplapack_mpfr_matrix_cholesky (low, false);
  const auto high_result
    = octave_mplapack::mplapack_mpfr_matrix_cholesky (high, false);
  check (low_result.info > 0 && high_result.info == 0,
         "precision-dependent PD classification mismatch");
}

void
test_failure_and_alias_safety ()
{
  const auto input = matrix (3, 3, 1024,
                             {"4", "0", "0", "0", "9", "0", "0", "0", "-1"});
  const auto before = input;
  const auto result
    = octave_mplapack::mplapack_mpfr_matrix_cholesky (input, false);
  check (result.info == 3 && result.factor.rows () == 2
         && result.factor.columns () == 2,
         "partial Cholesky factor metadata mismatch");
  check (result.factor.element_exactly_equal_text (0, 0, "2")
         && result.factor.element_exactly_equal_text (1, 1, "3"),
         "partial Cholesky factor values mismatch");
  check (input.element_exactly_equal (2, 2, before, 2, 2),
         "failed Cholesky modified input");

  const auto semidefinite = matrix (2, 2, 1024, {"1", "1", "1", "1"});
  const auto partial
    = octave_mplapack::mplapack_mpfr_matrix_cholesky (semidefinite, true);
  check (partial.info == 2 && partial.factor.rows () == 1
         && partial.factor.columns () == 1,
         "semidefinite partial lower factor mismatch");
  check (mpfrxx::default_precision_bits () == 128,
         "failure Cholesky changed ambient precision");
}

} // namespace

int
main ()
{
  try
    {
      test_triangle_selection ();
      test_precision_and_empty ();
      test_precision_dependent_pd ();
      test_failure_and_alias_safety ();
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
  std::cout << "PASS: MPLAPACK MPFR Rpotrf Cholesky tests\n";
  return 0;
}
