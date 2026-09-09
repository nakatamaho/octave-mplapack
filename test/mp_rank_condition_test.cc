// SPDX-License-Identifier: BSD-2-Clause

#include "mp_rank_condition.h"

#include <cmath>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

using octave_mplapack::MpfrConditionKind;
using octave_mplapack::MpfrComplexMatrixStorage;
using octave_mplapack::MpfrMatrixStorage;
using octave_mplapack::MpfrScalarStorage;

namespace
{

void
check (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

void
test_real_rank_and_conditions ()
{
  const MpfrMatrixStorage a (2, 2, 512,
                             std::vector<std::string> {"1", "3", "2", "4"});
  check (octave_mplapack::mplapack_mpfr_matrix_rank (a) == 2,
         "real full rank mismatch");
  const MpfrScalarStorage zero ("0", 512);
  check (octave_mplapack::mplapack_mpfr_matrix_rank (a, &zero) == 2,
         "explicit zero rank tolerance mismatch");

  const auto cond2 = octave_mplapack::mplapack_mpfr_matrix_condition (
    a, MpfrConditionKind::two);
  const auto cond1 = octave_mplapack::mplapack_mpfr_matrix_condition (
    a, MpfrConditionKind::one);
  const auto condinf = octave_mplapack::mplapack_mpfr_matrix_condition (
    a, MpfrConditionKind::infinity);
  const auto condfro = octave_mplapack::mplapack_mpfr_matrix_condition (
    a, MpfrConditionKind::frobenius);
  const auto reciprocal = octave_mplapack::mplapack_mpfr_matrix_rcond (a);
  check (cond2.to_double () > 14.0 && cond2.to_double () < 15.0,
         "real 2-norm condition mismatch");
  check (cond1.to_double () > 20.0 && cond1.to_double () < 22.0,
         "real 1-norm condition mismatch");
  check (condinf.to_double () > 20.0 && condinf.to_double () < 22.0,
         "real infinity-norm condition mismatch");
  check (condfro.to_double () > 14.0 && condfro.to_double () < 16.0,
         "real Frobenius condition mismatch");
  check (reciprocal.to_double () > 0.04 && reciprocal.to_double () < 0.05,
         "real reciprocal condition mismatch");
  check (std::abs (cond1.to_double () * reciprocal.to_double () - 1.0)
           < 1e-12,
         "real reciprocal condition is not reciprocal");
}

void
test_complex_rank_and_conditions ()
{
  const MpfrComplexMatrixStorage a (
    2, 2, 512,
    std::vector<std::string> {"1+2i", "3", "2-1i", "4+3i"});
  check (octave_mplapack::mplapack_mpc_matrix_rank (a) == 2,
         "complex full rank mismatch");
  const auto cond2 = octave_mplapack::mplapack_mpc_matrix_condition (
    a, MpfrConditionKind::two);
  const auto cond1 = octave_mplapack::mplapack_mpc_matrix_condition (
    a, MpfrConditionKind::one);
  const auto condinf = octave_mplapack::mplapack_mpc_matrix_condition (
    a, MpfrConditionKind::infinity);
  const auto condfro = octave_mplapack::mplapack_mpc_matrix_condition (
    a, MpfrConditionKind::frobenius);
  const auto reciprocal = octave_mplapack::mplapack_mpc_matrix_rcond (a);
  check (cond2.to_double () > 1.0, "complex 2-norm condition mismatch");
  check (cond1.to_double () > 1.0, "complex 1-norm condition mismatch");
  check (condinf.to_double () > 1.0,
         "complex infinity-norm condition mismatch");
  check (condfro.to_double () > 1.0,
         "complex Frobenius condition mismatch");
  check (reciprocal.to_double () > 0.0 && reciprocal.to_double () < 1.0,
         "complex reciprocal condition mismatch");
}

void
test_precision_and_singular_edges ()
{
  MpfrMatrixStorage low (2, 2, 512,
                         std::vector<std::string> {"1", "0", "0", "0"});
  mpfr_set_ui_2exp (low.at (1, 1).mpfr_data (), 1, -700, MPFR_RNDN);
  check (octave_mplapack::mplapack_mpfr_matrix_rank (low) == 1,
         "512-bit rank canary mismatch");

  MpfrMatrixStorage middle (2, 2, 1024,
                            std::vector<std::string> {"1", "0", "0", "0"});
  mpfr_set_ui_2exp (middle.at (1, 1).mpfr_data (), 1, -700, MPFR_RNDN);
  check (octave_mplapack::mplapack_mpfr_matrix_rank (middle) == 2,
         "1024-bit rank canary mismatch");

  MpfrMatrixStorage high (2, 2, 2048,
                          std::vector<std::string> {"1", "0", "0", "0"});
  mpfr_set_ui_2exp (high.at (1, 1).mpfr_data (), 1, -1500, MPFR_RNDN);
  check (octave_mplapack::mplapack_mpfr_matrix_rank (high) == 2,
         "2048-bit rank canary mismatch");

  const MpfrMatrixStorage singular (
    2, 2, 512, std::vector<std::string> {"1", "2", "2", "4"});
  const auto cond = octave_mplapack::mplapack_mpfr_matrix_condition (
    singular, MpfrConditionKind::two);
  const auto reciprocal = octave_mplapack::mplapack_mpfr_matrix_rcond (
    singular);
  check (cond.is_infinite (), "singular condition must be infinite");
  check (reciprocal.is_zero (), "singular reciprocal condition must be zero");

  const MpfrMatrixStorage empty (0, 0, 512);
  check (octave_mplapack::mplapack_mpfr_matrix_condition (
           empty, MpfrConditionKind::two)
           .is_zero (),
         "empty condition must be zero");
  check (octave_mplapack::mplapack_mpfr_matrix_rcond (empty).is_infinite (),
         "empty reciprocal condition must be infinite");
}

} // namespace

int
main ()
{
  try
    {
      test_real_rank_and_conditions ();
      test_complex_rank_and_conditions ();
      test_precision_and_singular_edges ();
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
  std::cout << "PASS: MPLAPACK MPFR/MPC rank and condition tests\n";
  return 0;
}
