// SPDX-License-Identifier: BSD-2-Clause

#include "mp_lapack.h"

#include <cmath>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

namespace
{

using octave_mplapack::MpfrMatrixStorage;
using octave_mplapack::MpfrQrResult;
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
check_close (const Real& value, const Real& expected, mpfr_prec_t precision,
             const char *message)
{
  Real difference = Real::with_precision (precision);
  mpfr_sub (difference.mpfr_data (), value.mpfr_data (), expected.mpfr_data (),
            MPFR_RNDN);
  Real tolerance = Real::with_precision (precision);
  mpfr_set_ui_2exp (tolerance.mpfr_data (), 1,
                    -static_cast<mpfr_exp_t> (precision / 2), MPFR_RNDN);
  mpfr_abs (difference.mpfr_data (), difference.mpfr_data (), MPFR_RNDN);
  check (mpfr_cmp (difference.mpfr_data (), tolerance.mpfr_data ()) < 0,
         message);
}

void
check_reconstruction (const MpfrQrResult& result,
                      const MpfrMatrixStorage& input,
                      const char *message)
{
  const std::size_t m = input.rows ();
  const std::size_t n = input.columns ();
  const std::size_t q_columns = result.q.columns ();
  const mpfr_prec_t precision = input.precision_bits ();
  for (std::size_t column = 0; column < n; ++column)
    for (std::size_t row = 0; row < m; ++row)
      {
        Real reconstructed = Real::with_precision (precision);
        mpfr_set_zero (reconstructed.mpfr_data (), 0);
        for (std::size_t inner = 0; inner < q_columns; ++inner)
          {
            Real product = Real::with_precision (precision);
            mpfr_mul (product.mpfr_data (), result.q.at (row, inner).mpfr_data (),
                      result.r.at (inner, column).mpfr_data (), MPFR_RNDN);
            mpfr_add (reconstructed.mpfr_data (), reconstructed.mpfr_data (),
                      product.mpfr_data (), MPFR_RNDN);
          }
        check_close (reconstructed, input.at (row, column), precision, message);
      }
}

void
check_orthogonality (const MpfrQrResult& result, const char *message)
{
  const std::size_t rows = result.q.rows ();
  const std::size_t columns = result.q.columns ();
  const mpfr_prec_t precision = result.q.precision_bits ();
  for (std::size_t column = 0; column < columns; ++column)
    for (std::size_t row = 0; row < columns; ++row)
      {
        Real value = Real::with_precision (precision);
        mpfr_set_zero (value.mpfr_data (), 0);
        for (std::size_t inner = 0; inner < rows; ++inner)
          {
            Real product = Real::with_precision (precision);
            mpfr_mul (product.mpfr_data (), result.q.at (inner, row).mpfr_data (),
                      result.q.at (inner, column).mpfr_data (), MPFR_RNDN);
            mpfr_add (value.mpfr_data (), value.mpfr_data (), product.mpfr_data (),
                      MPFR_RNDN);
          }
        Real expected = Real::with_precision (precision);
        mpfr_set_ui (expected.mpfr_data (), row == column ? 1 : 0, MPFR_RNDN);
        check_close (value, expected, precision, message);
      }
}

void
check_upper_structure (const MpfrMatrixStorage& r, const char *message)
{
  const std::size_t active = std::min (r.rows (), r.columns ());
  for (std::size_t column = 0; column < r.columns (); ++column)
    for (std::size_t row = 0; row < r.rows (); ++row)
      if (row >= active || row > column)
        check (mpfr_zero_p (r.at (row, column).mpfr_data ()) != 0, message);
}

void
test_shapes_and_reconstruction ()
{
  const auto tall = matrix (4, 2, 256,
                            {"1", "3", "5", "11", "2", "4", "7", "13"});
  const auto full = octave_mplapack::mplapack_mpfr_matrix_qr (tall, false, true);
  check (full.q.rows () == 4 && full.q.columns () == 4
         && full.r.rows () == 4 && full.r.columns () == 2,
         "full tall QR shape mismatch");
  check_reconstruction (full, tall, "full tall reconstruction mismatch");
  check_orthogonality (full, "full tall orthogonality mismatch");
  check_upper_structure (full.r, "full R structure mismatch");

  const auto economy
    = octave_mplapack::mplapack_mpfr_matrix_qr (tall, true, true);
  check (economy.q.rows () == 4 && economy.q.columns () == 2
         && economy.r.rows () == 2 && economy.r.columns () == 2,
         "economy tall QR shape mismatch");
  check_reconstruction (economy, tall, "economy tall reconstruction mismatch");
  check_orthogonality (economy, "economy tall orthogonality mismatch");

  const auto wide = matrix (2, 4, 256,
                            {"1", "3", "2", "4", "5", "7", "6", "8"});
  const auto wide_result
    = octave_mplapack::mplapack_mpfr_matrix_qr (wide, false, true);
  check (wide_result.q.rows () == 2 && wide_result.q.columns () == 2
         && wide_result.r.rows () == 2 && wide_result.r.columns () == 4,
         "wide QR shape mismatch");
  check_reconstruction (wide_result, wide, "wide reconstruction mismatch");
  check_orthogonality (wide_result, "wide orthogonality mismatch");

  const auto one_output
    = octave_mplapack::mplapack_mpfr_matrix_qr (tall, false, false);
  check (one_output.q.rows () == 0 && one_output.q.columns () == 0,
         "one-output QR unexpectedly generated Q");
  check (one_output.r.rows () == 4 && one_output.r.columns () == 2,
         "one-output R shape mismatch");
}

void
test_precision_and_empty ()
{
  mpfrxx::set_default_precision_bits (128);
  for (const auto fixture : {std::pair<mpfr_prec_t, long> (1024, -700),
                             std::pair<mpfr_prec_t, long> (2048, -1500)})
    {
      const auto precision = fixture.first;
      auto input = matrix (2, 2, precision, {"1", "0", "1", "1"});
      Real tail = Real::with_precision (precision);
      mpfr_set_ui_2exp (tail.mpfr_data (), 1, fixture.second, MPFR_RNDN);
      mpfr_add (input.at (1, 1).mpfr_data (), input.at (1, 1).mpfr_data (),
                tail.mpfr_data (), MPFR_RNDN);
      const auto result
        = octave_mplapack::mplapack_mpfr_matrix_qr (input, false, true);
      check (result.q.precision_bits () == precision
             && result.r.precision_bits () == precision,
             "QR precision metadata mismatch");
      check (mpfr_equal_p (result.r.at (1, 1).mpfr_data (),
                           input.at (1, 1).mpfr_data ()) != 0,
             "QR precision tail was not preserved");
      check_reconstruction (result, input, "precision QR reconstruction mismatch");
      check (mpfrxx::default_precision_bits () == 128,
             "QR leaked ambient precision");
    }

  const auto empty = matrix (0, 3, 1024, {});
  const auto empty_full
    = octave_mplapack::mplapack_mpfr_matrix_qr (empty, false, true);
  check (empty_full.q.rows () == 0 && empty_full.q.columns () == 0
         && empty_full.r.rows () == 0 && empty_full.r.columns () == 3
         && empty_full.r.precision_bits () == 1024,
         "empty QR shape mismatch");
  const auto zero_columns = matrix (3, 0, 1024, {});
  const auto zero_econ
    = octave_mplapack::mplapack_mpfr_matrix_qr (zero_columns, true, true);
  check (zero_econ.q.rows () == 3 && zero_econ.q.columns () == 0
         && zero_econ.r.rows () == 0 && zero_econ.r.columns () == 0,
         "zero-column economy QR shape mismatch");
}

} // namespace

int
main ()
{
  try
    {
      test_shapes_and_reconstruction ();
      test_precision_and_empty ();
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
  std::cout << "PASS: MPLAPACK MPFR Rgeqrf/Rorgqr QR tests\n";
  return 0;
}
