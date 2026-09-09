// SPDX-License-Identifier: BSD-2-Clause

#include "mp_det_inv.h"

#include <iostream>
#include <initializer_list>
#include <stdexcept>
#include <string>
#include <vector>

namespace
{

using octave_mplapack::MpfrComplexMatrixStorage;
using octave_mplapack::MpfrComplexScalarStorage;
using octave_mplapack::MpfrMatrixStorage;
using octave_mplapack::MpfrScalarStorage;
using Real = mpfrxx::mpfr_class;

void
check (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

MpfrMatrixStorage
real_matrix (std::size_t rows, std::size_t columns, mpfr_prec_t precision,
             std::initializer_list<const char*> values)
{
  return MpfrMatrixStorage (rows, columns, precision,
                            std::vector<std::string> (values.begin (),
                                                      values.end ()));
}

MpfrComplexMatrixStorage
complex_matrix (std::size_t rows, std::size_t columns, mpfr_prec_t precision,
                std::initializer_list<const char*> values)
{
  return MpfrComplexMatrixStorage (rows, columns, precision,
                                   std::vector<std::string> (values.begin (),
                                                             values.end ()));
}

void
check_real_close (const Real& value, const Real& expected, mpfr_prec_t precision,
                  const char *message)
{
  Real difference = Real::with_precision (precision);
  Real tolerance = Real::with_precision (precision);
  mpfr_sub (difference.mpfr_data (), value.mpfr_data (), expected.mpfr_data (),
            MPFR_RNDN);
  mpfr_abs (difference.mpfr_data (), difference.mpfr_data (), MPFR_RNDN);
  mpfr_set_ui_2exp (tolerance.mpfr_data (), 1,
                    -static_cast<mpfr_exp_t> (precision / 2), MPFR_RNDN);
  check (mpfr_cmp (difference.mpfr_data (), tolerance.mpfr_data ()) < 0,
         message);
}

void
check_complex_close (const MpfrComplexScalarStorage::NativeScalar& value,
                     const MpfrComplexScalarStorage::NativeScalar& expected,
                     mpfr_prec_t precision, const char *message)
{
  auto difference = MpfrComplexScalarStorage::NativeScalar::with_precision (
    precision);
  auto magnitude = Real::with_precision (precision);
  auto tolerance = Real::with_precision (precision);
  mpc_sub (difference.mpc_data (), value.mpc_data (), expected.mpc_data (),
           MPC_RND (MPFR_RNDN, MPFR_RNDN));
  mpc_abs (magnitude.mpfr_data (), difference.mpc_data (), MPFR_RNDN);
  mpfr_set_ui_2exp (tolerance.mpfr_data (), 1,
                    -static_cast<mpfr_exp_t> (precision / 2), MPFR_RNDN);
  check (mpfr_cmp (magnitude.mpfr_data (), tolerance.mpfr_data ()) < 0,
         message);
}

void
check_real_matrix_close (const MpfrMatrixStorage& value,
                         const MpfrMatrixStorage& expected,
                         const char *message)
{
  check (value.rows () == expected.rows ()
           && value.columns () == expected.columns (),
         message);
  for (std::size_t index = 0; index < value.numel (); ++index)
    check_real_close (value.data ()[index], expected.data ()[index],
                      value.precision_bits (), message);
}

void
check_complex_matrix_close (const MpfrComplexMatrixStorage& value,
                            const MpfrComplexMatrixStorage& expected,
                            const char *message)
{
  check (value.rows () == expected.rows ()
           && value.columns () == expected.columns (),
         message);
  for (std::size_t index = 0; index < value.numel (); ++index)
    check_complex_close (value.data ()[index], expected.data ()[index],
                        value.precision_bits (), message);
}

void
test_real_det_and_inverse ()
{
  const auto input = real_matrix (2, 2, 256, {"1", "3", "2", "4"});
  const auto before = input;
  const auto determinant = octave_mplapack::mplapack_mpfr_matrix_det (input);
  auto expected_determinant = Real::with_precision (256);
  mpfr_set_si (expected_determinant.mpfr_data (), -2, MPFR_RNDN);
  check_real_close (determinant.native_value (), expected_determinant, 256,
                    "real determinant pivot sign mismatch");
  const auto inverse = octave_mplapack::mplapack_mpfr_matrix_inverse (input);
  const auto expected = real_matrix (2, 2, 256,
                                     {"-2", "1.5", "1", "-0.5"});
  check_real_matrix_close (inverse, expected, "real inverse values mismatch");
  for (std::size_t index = 0; index < input.numel (); ++index)
    check (mpfr_equal_p (input.data ()[index].mpfr_data (),
                         before.data ()[index].mpfr_data ()) != 0,
           "real det/inv modified public input");
}

void
test_complex_det_and_inverse ()
{
  const auto input = complex_matrix (2, 2, 256,
                                     {"(1,1)", "(3,0)", "(2,0)", "(4,-1)"});
  const auto determinant = octave_mplapack::mplapack_mpc_matrix_det (input);
  auto expected_det = MpfrComplexScalarStorage::NativeScalar::with_precision (256);
  expected_det.set_str ("(-1,3)", 10);
  check_complex_close (determinant.native_value (), expected_det, 256,
                       "complex determinant mismatch");

  const auto inverse = octave_mplapack::mplapack_mpc_matrix_inverse (input);
  const auto expected = complex_matrix (2, 2, 256,
    {"(-0.7,-1.1)", "(0.3,0.9)", "(0.2,0.6)", "(0.2,-0.4)"});
  check_complex_matrix_close (inverse, expected,
                              "complex inverse values mismatch");
}

void
test_singular_shapes_and_empty ()
{
  const auto singular = real_matrix (2, 2, 256, {"1", "2", "2", "4"});
  const auto determinant = octave_mplapack::mplapack_mpfr_matrix_det (singular);
  check (determinant.is_zero (), "singular determinant is not exact zero");
  bool caught = false;
  try
    {
      (void) octave_mplapack::mplapack_mpfr_matrix_inverse (singular);
    }
  catch (const octave_mplapack::MpfrDetInvError& exception)
    {
      caught = exception.kind ()
               == octave_mplapack::MpfrDetInvError::Kind::singular;
    }
  check (caught, "singular real inverse did not report singularity");

  const auto complex_singular
    = complex_matrix (2, 2, 256, {"(1,0)", "(2,0)", "(2,0)", "(4,0)"});
  const auto complex_determinant
    = octave_mplapack::mplapack_mpc_matrix_det (complex_singular);
  check (complex_determinant.is_zero (),
         "singular complex determinant is not exact zero");
  caught = false;
  try
    {
      (void) octave_mplapack::mplapack_mpc_matrix_inverse (complex_singular);
    }
  catch (const octave_mplapack::MpcDetInvError& exception)
    {
      caught = exception.kind ()
               == octave_mplapack::MpcDetInvError::Kind::singular;
    }
  check (caught, "singular complex inverse did not report singularity");

  const auto empty = real_matrix (0, 3, 256, {});
  bool non_square_caught = false;
  try
    {
      (void) octave_mplapack::mplapack_mpfr_matrix_det (empty);
    }
  catch (const std::invalid_argument&)
    {
      non_square_caught = true;
    }
  check (non_square_caught, "non-square determinant was accepted");
  const auto empty_square = real_matrix (0, 0, 256, {});
  const auto empty_det
    = octave_mplapack::mplapack_mpfr_matrix_det (empty_square);
  check (empty_det.exactly_equal_string ("1"),
         "empty determinant is not one");
  const auto empty_inverse
    = octave_mplapack::mplapack_mpfr_matrix_inverse (empty_square);
  check (empty_inverse.rows () == 0 && empty_inverse.columns () == 0,
         "empty inverse shape mismatch");
}

void
test_precision_and_scope ()
{
  mpfrxx::set_default_precision_bits (128);
  for (const auto setting : {std::pair<mpfr_prec_t, mpfr_exp_t> (1024, -700),
                             std::pair<mpfr_prec_t, mpfr_exp_t> (2048, -1500)})
    {
      const mpfr_prec_t precision = setting.first;
      auto input = real_matrix (2, 2, precision, {"0", "0", "0", "1"});
      mpfr_set_ui_2exp (input.at (0, 0).mpfr_data (), 1, setting.second,
                        MPFR_RNDN);
      const auto determinant
        = octave_mplapack::mplapack_mpfr_matrix_det (input);
      check (mpfr_equal_p (determinant.native_value ().mpfr_data (),
                           input.at (0, 0).mpfr_data ()) != 0,
             "high-precision determinant tail mismatch");
      const auto inverse
        = octave_mplapack::mplapack_mpfr_matrix_inverse (input);
      auto expected = Real::with_precision (precision);
      mpfr_set_ui_2exp (expected.mpfr_data (), 1, -setting.second, MPFR_RNDN);
      check_real_close (inverse.at (0, 0), expected, precision,
                        "high-precision inverse tail mismatch");
      check (inverse.precision_bits () == precision
               && mpfrxx::default_precision_bits () == 128,
             "inverse precision or ambient precision mismatch");
    }
}

} // namespace

int
main ()
{
  try
    {
      test_real_det_and_inverse ();
      test_complex_det_and_inverse ();
      test_singular_shapes_and_empty ();
      test_precision_and_scope ();
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
  std::cout << "PASS: MPLAPACK MPFR/MPC determinant and inverse tests\n";
  return 0;
}
