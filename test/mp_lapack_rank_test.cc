// SPDX-License-Identifier: BSD-2-Clause

#include "mp_lapack.h"

#include <cmath>
#include <iostream>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

namespace
{

using octave_mplapack::MpfrMatrixStorage;
using octave_mplapack::MpfrRankRevealingSolveResult;
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
check_close (const Real& value, const Real& expected, const char *message)
{
  Real difference = Real::with_precision (value.precision ());
  mpfr_sub (difference.mpfr_data (), value.mpfr_data (), expected.mpfr_data (),
            MPFR_RNDN);
  Real magnitude = Real::with_precision (value.precision ());
  mpfr_abs (magnitude.mpfr_data (), difference.mpfr_data (), MPFR_RNDN);
  check (mpfr_get_d (magnitude.mpfr_data (), MPFR_RNDN) < 1e-40, message);
}

Real
rational (long numerator, long denominator, mpfr_prec_t precision)
{
  Real result = Real::with_precision (precision);
  Real denominator_value = Real::with_precision (precision);
  mpfr_set_si (result.mpfr_data (), numerator, MPFR_RNDN);
  mpfr_set_si (denominator_value.mpfr_data (), denominator, MPFR_RNDN);
  mpfr_div (result.mpfr_data (), result.mpfr_data (), denominator_value.mpfr_data (),
            MPFR_RNDN);
  return result;
}

void
test_rank_one_fixtures ()
{
  const auto a_over = matrix (3, 2, 1024, {"1", "2", "3", "2", "4", "6"});
  const auto b_consistent = matrix (3, 1, 1024, {"1", "2", "3"});
  const auto a_before = a_over;
  const auto b_before = b_consistent;
  const MpfrRankRevealingSolveResult consistent
    = octave_mplapack::mplapack_mpfr_matrix_rank_revealing_solve (
        a_over, b_consistent);
  check (consistent.rank == 1, "rank-one overdetermined rank mismatch");
  check_close (consistent.solution.at (0, 0), rational (1, 5, 1024),
               "rank-one overdetermined first value mismatch");
  check_close (consistent.solution.at (1, 0), rational (2, 5, 1024),
               "rank-one overdetermined second value mismatch");
  check (a_over.element_exactly_equal (0, 0, a_before, 0, 0)
         && b_consistent.element_exactly_equal (0, 0, b_before, 0, 0),
         "rank-one inputs were modified");

  const auto b_inconsistent = matrix (3, 1, 1024, {"1", "2", "4"});
  const auto inconsistent
    = octave_mplapack::mplapack_mpfr_matrix_rank_revealing_solve (
        a_over, b_inconsistent);
  check (inconsistent.rank == 1, "inconsistent rank mismatch");
  check_close (inconsistent.solution.at (0, 0), rational (17, 70, 1024),
               "inconsistent first value mismatch");
  check_close (inconsistent.solution.at (1, 0), rational (17, 35, 1024),
               "inconsistent second value mismatch");

  const auto a_under = matrix (2, 3, 1024, {"1", "2", "2", "4", "3", "6"});
  const auto b_under = matrix (2, 1, 1024, {"1", "2"});
  const auto under
    = octave_mplapack::mplapack_mpfr_matrix_rank_revealing_solve (
        a_under, b_under);
  check (under.rank == 1, "rank-one underdetermined rank mismatch");
  check_close (under.solution.at (0, 0), rational (1, 14, 1024),
               "underdetermined first value mismatch");
  check_close (under.solution.at (1, 0), rational (2, 14, 1024),
               "underdetermined second value mismatch");
  check_close (under.solution.at (2, 0), rational (3, 14, 1024),
               "underdetermined third value mismatch");
}

void
test_rank_zero_and_multiple_rhs ()
{
  const auto zero_a = matrix (3, 2, 512, {"0", "0", "0", "0", "0", "0"});
  const auto zero_b = matrix (3, 2, 512, {"1", "2", "3", "4", "5", "6"});
  const auto zero
    = octave_mplapack::mplapack_mpfr_matrix_rank_revealing_solve (
        zero_a, zero_b);
  check (zero.rank == 0 && zero.solution.rows () == 2
         && zero.solution.columns () == 2,
         "rank-zero result metadata mismatch");
  for (std::size_t index = 0; index < zero.solution.numel (); ++index)
    check (mpfr_zero_p (zero.solution.data ()[index].mpfr_data ()) != 0,
           "rank-zero result is not zero");

  const auto a = matrix (3, 2, 512, {"1", "0", "1", "0", "1", "1"});
  const auto b = matrix (3, 2, 512, {"0", "1", "4", "1", "0", "4"});
  const auto result
    = octave_mplapack::mplapack_mpfr_matrix_rank_revealing_solve (a, b);
  check (result.rank == 2 && result.solution.rows () == 2
         && result.solution.columns () == 2,
         "full-rank multiple-RHS metadata mismatch");
  check_close (result.solution.at (0, 0), rational (1, 1, 512),
               "multiple-RHS first value mismatch");
  check_close (result.solution.at (1, 0), rational (2, 1, 512),
               "multiple-RHS second value mismatch");
  check_close (result.solution.at (0, 1), rational (2, 1, 512),
               "multiple-RHS third value mismatch");
  check_close (result.solution.at (1, 1), rational (1, 1, 512),
               "multiple-RHS fourth value mismatch");
}

void
test_precision_rank_transition ()
{
  mpfrxx::set_default_precision_bits (128);
  for (const auto case_data : {std::pair<mpfr_prec_t, long> (512, -700),
                               std::pair<mpfr_prec_t, long> (1024, -700),
                               std::pair<mpfr_prec_t, long> (2048, -1500)})
    {
      const mpfr_prec_t precision = case_data.first;
      auto a = matrix (3, 2, precision,
                       {"1", "0", "0", "0", "0", "0"});
      MpfrMatrixStorage b (3, 1, precision);
      Real delta = Real::with_precision (precision);
      mpfr_set_ui_2exp (delta.mpfr_data (), 1, case_data.second, MPFR_RNDN);
      mpfr_set (a.at (1, 1).mpfr_data (), delta.mpfr_data (), MPFR_RNDN);
      mpfr_set (b.at (1, 0).mpfr_data (), delta.mpfr_data (), MPFR_RNDN);
      const auto result
        = octave_mplapack::mplapack_mpfr_matrix_rank_revealing_solve (a, b);
      const auto expected_rank = precision == 512 ? 1 : 2;
      check (result.rank == expected_rank, "precision-dependent rank mismatch");
      check (result.solution.precision_bits () == precision,
             "precision-dependent result precision mismatch");
      if (precision != 512)
        check (mpfr_get_d (result.solution.at (1, 0).mpfr_data (), MPFR_RNDN)
                 > 0.999999999999,
               "high-precision rank canary solution mismatch");
    }
  check (mpfrxx::default_precision_bits () == 128,
         "rank-revealing solve leaked ambient precision");
}

void
test_mixed_precision ()
{
  const auto a = matrix (3, 2, 256, {"1", "0", "1", "0", "1", "1"});
  const auto b = matrix (3, 1, 1024, {"0", "1", "4"});
  const auto result
    = octave_mplapack::mplapack_mpfr_matrix_rank_revealing_solve (a, b);
  check (result.rank == 2 && result.solution.precision_bits () == 1024,
         "mixed rank-revealing precision mismatch");
  check (mpfrxx::default_precision_bits () == 128,
         "mixed rank-revealing solve changed ambient precision");
}

} // namespace

int
main ()
{
  try
    {
      test_rank_one_fixtures ();
      test_rank_zero_and_multiple_rhs ();
      test_precision_rank_transition ();
      test_mixed_precision ();
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
  std::cout << "PASS: MPLAPACK MPFR rank-revealing Rgelss tests\n";
  return 0;
}
