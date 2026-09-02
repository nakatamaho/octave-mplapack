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

using octave_mplapack::MpfrLuResult;
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
check_fraction (const Real& value, unsigned long numerator,
                unsigned long denominator, mpfr_prec_t precision,
                const char *message)
{
  Real expected = Real::with_precision (precision);
  mpfr_set_ui (expected.mpfr_data (), numerator, MPFR_RNDN);
  mpfr_div_ui (expected.mpfr_data (), expected.mpfr_data (), denominator,
               MPFR_RNDN);
  Real difference = Real::with_precision (precision);
  mpfr_sub (difference.mpfr_data (), value.mpfr_data (), expected.mpfr_data (),
            MPFR_RNDN);
  mpfr_abs (difference.mpfr_data (), difference.mpfr_data (), MPFR_RNDN);
  Real tolerance = Real::with_precision (precision);
  mpfr_set_ui_2exp (tolerance.mpfr_data (), 1,
                    -static_cast<mpfr_exp_t> (precision * 3 / 4), MPFR_RNDN);
  check (mpfr_cmp (difference.mpfr_data (), tolerance.mpfr_data ()) < 0,
         message);
}

bool
same (const MpfrMatrixStorage& lhs, const MpfrMatrixStorage& rhs)
{
  if (lhs.rows () != rhs.rows () || lhs.columns () != rhs.columns ()
      || lhs.precision_bits () != rhs.precision_bits ())
    return false;
  for (std::size_t index = 0; index < lhs.numel (); ++index)
    if (mpfr_equal_p (lhs.data ()[index].mpfr_data (),
                      rhs.data ()[index].mpfr_data ()) == 0)
      return false;
  return true;
}

void
check_permutation (const MpfrLuResult& result,
                   std::initializer_list<MpfrMatrixStorage::MplapackInteger>
                     expected)
{
  check (result.permutation.size () == expected.size (),
         "LU permutation length mismatch");
  std::size_t index = 0;
  for (const auto value : expected)
    {
      check (result.permutation[index++] == value,
             "LU permutation value mismatch");
    }
}

void
test_square_and_rectangular_shapes ()
{
  const auto square = matrix (2, 2, 256, {"1", "3", "2", "4"});
  const auto result = octave_mplapack::mplapack_mpfr_matrix_lu (square);
  check (result.info == 0, "square LU unexpectedly failed");
  check_permutation (result, {2, 1});
  check (result.packed.rows () == 2 && result.packed.columns () == 2,
         "packed square LU shape mismatch");
  check (result.packed.element_exactly_equal_text (0, 0, "3")
         && result.packed.element_exactly_equal_text (0, 1, "4"),
         "packed square LU integer values mismatch");
  check_fraction (result.packed.at (1, 0), 1, 3, 256,
                  "packed square LU multiplier mismatch");
  check_fraction (result.packed.at (1, 1), 2, 3, 256,
                  "packed square LU diagonal mismatch");
  check (result.lower.element_exactly_equal_text (0, 0, "1")
         && result.lower.element_exactly_equal_text (0, 1, "0")
         && result.lower.element_exactly_equal_text (1, 1, "1"),
         "canonical L integer values mismatch");
  check_fraction (result.lower.at (1, 0), 1, 3, 256,
                  "canonical L multiplier mismatch");
  check (result.upper.element_exactly_equal_text (0, 0, "3")
         && result.upper.element_exactly_equal_text (1, 0, "0")
         && result.upper.element_exactly_equal_text (0, 1, "4"),
         "canonical U integer values mismatch");
  check_fraction (result.upper.at (1, 1), 2, 3, 256,
                  "canonical U diagonal mismatch");

  const auto tall = matrix (3, 2, 256, {"1", "3", "5", "2", "4", "6"});
  const auto tall_result = octave_mplapack::mplapack_mpfr_matrix_lu (tall);
  check (tall_result.lower.rows () == 3 && tall_result.lower.columns () == 2
         && tall_result.upper.rows () == 2 && tall_result.upper.columns () == 2,
         "tall LU shape mismatch");
  check_permutation (tall_result, {3, 1, 2});

  const auto wide = matrix (2, 3, 256, {"1", "3", "2", "4", "5", "6"});
  const auto wide_result = octave_mplapack::mplapack_mpfr_matrix_lu (wide);
  check (wide_result.lower.rows () == 2 && wide_result.lower.columns () == 2
         && wide_result.upper.rows () == 2 && wide_result.upper.columns () == 3,
         "wide LU shape mismatch");
  check_permutation (wide_result, {2, 1});
}

void
test_precision_and_scope ()
{
  mpfrxx::set_default_precision_bits (128);
  for (const auto case_data : {std::pair<mpfr_prec_t, mpfr_exp_t> (1024, -700),
                               std::pair<mpfr_prec_t, mpfr_exp_t> (2048,
                                                                    -1500)})
    {
      const mpfr_prec_t precision = case_data.first;
      MpfrMatrixStorage input (2, 2, precision);
      mpfr_set_ui (input.at (0, 0).mpfr_data (), 4, MPFR_RNDN);
      mpfr_set_ui (input.at (0, 1).mpfr_data (), 2, MPFR_RNDN);
      Real delta = Real::with_precision (precision);
      mpfr_set_ui_2exp (delta.mpfr_data (), 1, case_data.second, MPFR_RNDN);
      // Set the lower-left entry directly to 1+delta without relying on a
      // default-precision temporary.
      mpfr_set_ui (input.at (1, 0).mpfr_data (), 1, MPFR_RNDN);
      mpfr_add (input.at (1, 0).mpfr_data (), input.at (1, 0).mpfr_data (),
                delta.mpfr_data (), MPFR_RNDN);
      mpfr_set_ui (input.at (1, 1).mpfr_data (), 3, MPFR_RNDN);

      const auto before = input;
      const auto result = octave_mplapack::mplapack_mpfr_matrix_lu (input);
      check (result.info == 0 && result.packed.precision_bits () == precision
             && result.lower.precision_bits () == precision
             && result.upper.precision_bits () == precision,
             "LU precision metadata mismatch");
      Real expected = Real::with_precision (precision);
      mpfr_set_ui (expected.mpfr_data (), 1, MPFR_RNDN);
      mpfr_div_ui (expected.mpfr_data (), expected.mpfr_data (), 4,
                   MPFR_RNDN);
      Real tail = Real::with_precision (precision);
      mpfr_set_ui_2exp (tail.mpfr_data (), 1, case_data.second - 2,
                        MPFR_RNDN);
      mpfr_add (expected.mpfr_data (), expected.mpfr_data (), tail.mpfr_data (),
                MPFR_RNDN);
      check (mpfr_equal_p (result.lower.at (1, 0).mpfr_data (),
                           expected.mpfr_data ()) != 0,
             "LU multiplier tail was not preserved");
      check (same (input, before), "Rgetrf modified public input storage");
      check (mpfrxx::default_precision_bits () == 128,
             "Rgetrf leaked ambient precision");
    }

  mpfrxx::set_default_precision_bits (4096);
  const auto high_ambient = matrix (2, 2, 256, {"1", "0", "0", "2"});
  const auto result = octave_mplapack::mplapack_mpfr_matrix_lu (high_ambient);
  check (result.packed.precision_bits () == 256
         && mpfrxx::default_precision_bits () == 4096,
         "high ambient LU changed operation precision");
  mpfrxx::set_default_precision_bits (128);
}

void
test_precision_dependent_pivot ()
{
  MpfrMatrixStorage low (2, 2, 512);
  MpfrMatrixStorage high (2, 2, 1024);
  for (MpfrMatrixStorage* input : {&low, &high})
    {
      mpfr_set_ui (input->at (0, 0).mpfr_data (), 1, MPFR_RNDN);
      mpfr_set_ui (input->at (1, 0).mpfr_data (), 1, MPFR_RNDN);
      Real delta = Real::with_precision (input->precision_bits ());
      mpfr_set_ui_2exp (delta.mpfr_data (), 1, -700, MPFR_RNDN);
      mpfr_add (input->at (1, 0).mpfr_data (), input->at (1, 0).mpfr_data (),
                delta.mpfr_data (), MPFR_RNDN);
      mpfr_set_ui (input->at (0, 1).mpfr_data (), 0, MPFR_RNDN);
      mpfr_set_ui (input->at (1, 1).mpfr_data (), 1, MPFR_RNDN);
    }
  const auto low_result = octave_mplapack::mplapack_mpfr_matrix_lu (low);
  const auto high_result = octave_mplapack::mplapack_mpfr_matrix_lu (high);
  check (low_result.permutation.at (0) == 1
         && high_result.permutation.at (0) == 2,
         "precision-dependent LU pivot mismatch");
}

void
test_singular_and_empty ()
{
  const auto singular = matrix (2, 2, 256, {"1", "2", "2", "4"});
  const auto result = octave_mplapack::mplapack_mpfr_matrix_lu (singular);
  check (result.info == 2, "singular LU INFO mismatch");
  check_permutation (result, {2, 1});
  const auto empty = matrix (0, 3, 512, {});
  const auto empty_result = octave_mplapack::mplapack_mpfr_matrix_lu (empty);
  check (empty_result.info == 0 && empty_result.packed.rows () == 0
         && empty_result.packed.columns () == 0
         && empty_result.permutation.empty (),
         "empty LU result mismatch");
}

} // namespace

int
main ()
{
  try
    {
      test_square_and_rectangular_shapes ();
      test_precision_and_scope ();
      test_precision_dependent_pivot ();
      test_singular_and_empty ();
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
  std::cout << "PASS: MPLAPACK MPFR Rgetrf LU tests\n";
  return 0;
}
