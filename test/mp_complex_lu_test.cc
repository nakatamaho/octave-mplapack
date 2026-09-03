// SPDX-License-Identifier: BSD-2-Clause

#include <array>
#include <cmath>
#include <complex>
#include <iostream>
#include <stdexcept>
#include <vector>

#include "mp_complex_lu.h"

namespace
{

using Matrix = octave_mplapack::MpfrComplexMatrixStorage;
using Real = mpfrxx::mpfr_class;

void
check (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

std::complex<double>
as_double (const Matrix& matrix, std::size_t row, std::size_t column)
{
  return octave_mplapack::MpfrComplexScalarStorage (
    matrix.at (row, column)).to_double ();
}

void
set_real (mpc_ptr value, unsigned long integer)
{
  mpfr_set_ui (mpc_realref (value), integer, MPFR_RNDN);
  mpfr_set_zero (mpc_imagref (value), 0);
}

void
check_close (const Matrix& matrix, std::size_t row, std::size_t column,
             std::complex<double> expected, const char *message)
{
  check (std::abs (as_double (matrix, row, column) - expected) < 1.0e-12,
         message);
}

void
check_zero (const Matrix& matrix, std::size_t row, std::size_t column,
            const char *message)
{
  const auto& value = matrix.at (row, column);
  check (mpfr_zero_p (mpc_realref (value.mpc_data ())) != 0
         && mpfr_zero_p (mpc_imagref (value.mpc_data ())) != 0,
         message);
}

void
check_raw_reconstruction (
  const Matrix& input, const Matrix& lower, const Matrix& upper,
  const std::vector<Matrix::MplapackInteger>& permutation,
  const char *message)
{
  const double tolerance = 1.0e-10;
  check (permutation.size () == input.rows (),
         "complex LU permutation shape mismatch");
  for (std::size_t column = 0; column < input.columns (); ++column)
    for (std::size_t row = 0; row < input.rows (); ++row)
      {
        std::complex<double> product {0.0, 0.0};
        for (std::size_t inner = 0; inner < lower.columns (); ++inner)
          product += as_double (lower, row, inner)
                     * as_double (upper, inner, column);
        const auto source = static_cast<std::size_t> (
          permutation[row] - static_cast<Matrix::MplapackInteger> (1));
        check (source < input.rows ()
               && std::abs (product - as_double (input, source, column))
                    < tolerance,
               message);
      }
}

void
check_factor_shapes (const Matrix& input,
                     const octave_mplapack::MpcLuResult& result,
                     const char *message)
{
  const std::size_t m = input.rows ();
  const std::size_t n = input.columns ();
  const std::size_t k = std::min (m, n);
  check (result.packed.rows () == m && result.packed.columns () == n
         && result.lower.rows () == m && result.lower.columns () == k
         && result.upper.rows () == k && result.upper.columns () == n,
         message);
}

void
test_square_and_rectangular_shapes ()
{
  const Matrix square (2, 2, 512,
                       std::vector<std::complex<double>> {
                         {1.0, 1.0}, {3.0, -1.0},
                         {2.0, 2.0}, {4.0, 0.0}});
  const auto before = square;
  const auto result = octave_mplapack::mplapack_mpc_matrix_lu (square);
  check (result.info == 0, "square complex LU unexpectedly failed");
  check_factor_shapes (square, result, "square complex LU shape mismatch");
  check (result.permutation.size () == 2 && result.permutation[0] == 2
         && result.permutation[1] == 1,
         "square complex LU permutation mismatch");
  check_close (result.packed, 0, 0, {3.0, -1.0},
               "square complex LU pivot mismatch");
  check_close (result.lower, 0, 0, {1.0, 0.0},
               "complex LU lower unit diagonal mismatch");
  check_close (result.lower, 1, 0, {0.2, 0.4},
               "complex LU multiplier mismatch");
  check_close (result.upper, 0, 1, {4.0, 0.0},
               "complex LU upper entry mismatch");
  check_close (result.upper, 1, 1, {1.2, 0.4},
               "complex LU trailing pivot mismatch");
  check_zero (result.lower, 0, 1, "complex LU lower upper entry not zero");
  check_zero (result.upper, 1, 0, "complex LU upper lower entry not zero");
  check_raw_reconstruction (square, result.lower, result.upper,
                            result.permutation,
                            "square complex LU reconstruction mismatch");
  check (square.element_exactly_equal (0, 0, before, 0, 0)
         && square.element_exactly_equal (1, 1, before, 1, 1),
         "complex Cgetrf modified public input");

  const Matrix tall (3, 2, 512,
                     std::vector<std::complex<double>> {
                       {1.0, 0.0}, {5.0, 1.0}, {3.0, -1.0},
                       {2.0, 2.0}, {4.0, 0.0}, {6.0, 1.0}});
  const auto tall_result = octave_mplapack::mplapack_mpc_matrix_lu (tall);
  check_factor_shapes (tall, tall_result, "tall complex LU shape mismatch");
  check_raw_reconstruction (tall, tall_result.lower, tall_result.upper,
                            tall_result.permutation,
                            "tall complex LU reconstruction mismatch");

  const Matrix wide (2, 3, 512,
                     std::vector<std::complex<double>> {
                       {1.0, 0.0}, {3.0, 1.0},
                       {2.0, -1.0}, {4.0, 0.0},
                       {5.0, 2.0}, {6.0, -1.0}});
  const auto wide_result = octave_mplapack::mplapack_mpc_matrix_lu (wide);
  check_factor_shapes (wide, wide_result, "wide complex LU shape mismatch");
  check_raw_reconstruction (wide, wide_result.lower, wide_result.upper,
                            wide_result.permutation,
                            "wide complex LU reconstruction mismatch");
}

void
test_precision_and_scope ()
{
  mpfrxx::set_default_precision_bits (128);
  for (const auto setting : {std::array<long, 2> {{1024, -700}},
                             std::array<long, 2> {{2048, -1500}}})
    {
      const mpfr_prec_t precision = static_cast<mpfr_prec_t> (setting[0]);
      Matrix input (2, 2, precision);
      set_real (input.at (0, 0).mpc_data (), 4);
      set_real (input.at (0, 1).mpc_data (), 2);
      set_real (input.at (1, 0).mpc_data (), 1);
      Real delta = Real::with_precision (precision);
      mpfr_set_ui_2exp (delta.mpfr_data (), 1, setting[1], MPFR_RNDN);
      mpfr_add (mpc_realref (input.at (1, 0).mpc_data ()),
                mpc_realref (input.at (1, 0).mpc_data ()),
                delta.mpfr_data (), MPFR_RNDN);
      set_real (input.at (1, 1).mpc_data (), 3);
      const auto before = input;
      const auto result = octave_mplapack::mplapack_mpc_matrix_lu (input);
      check (result.info == 0 && result.packed.precision_bits () == precision
             && result.lower.precision_bits () == precision
             && result.upper.precision_bits () == precision
             && result.packed.all_elements_have_uniform_precision (),
             "complex LU precision metadata mismatch");
      Real expected = Real::with_precision (precision);
      mpfr_set_ui (expected.mpfr_data (), 1, MPFR_RNDN);
      mpfr_div_ui (expected.mpfr_data (), expected.mpfr_data (), 4,
                   MPFR_RNDN);
      Real tail = Real::with_precision (precision);
      mpfr_set_ui_2exp (tail.mpfr_data (), 1, setting[1] - 2, MPFR_RNDN);
      mpfr_add (expected.mpfr_data (), expected.mpfr_data (),
                tail.mpfr_data (), MPFR_RNDN);
      check (mpfr_equal_p (mpc_realref (result.lower.at (1, 0).mpc_data ()),
                           expected.mpfr_data ()) != 0,
             "complex LU multiplier tail was not preserved");
      check (input.element_exactly_equal (0, 0, before, 0, 0)
             && input.element_exactly_equal (1, 0, before, 1, 0),
             "complex Cgetrf modified input storage");
      check (mpfrxx::default_precision_bits () == 128,
             "complex Cgetrf leaked ambient precision");
    }

  mpfrxx::set_default_precision_bits (4096);
  const Matrix low_precision (2, 2, 256,
                              std::vector<std::complex<double>> {
                                {1.0, 0.0}, {0.0, 0.0},
                                {0.0, 0.0}, {2.0, 0.0}});
  const auto result
    = octave_mplapack::mplapack_mpc_matrix_lu (low_precision);
  check (result.packed.precision_bits () == 256
         && mpfrxx::default_precision_bits () == 4096,
         "complex LU changed operation precision from ambient precision");
}

void
test_precision_dependent_pivot ()
{
  Matrix low (2, 2, 512);
  Matrix high (2, 2, 1024);
  for (Matrix* input : {&low, &high})
    {
      set_real (input->at (0, 0).mpc_data (), 1);
      set_real (input->at (1, 0).mpc_data (), 1);
      Real delta = Real::with_precision (input->precision_bits ());
      mpfr_set_ui_2exp (delta.mpfr_data (), 1, -700, MPFR_RNDN);
      mpfr_add (mpc_realref (input->at (1, 0).mpc_data ()),
                mpc_realref (input->at (1, 0).mpc_data ()),
                delta.mpfr_data (), MPFR_RNDN);
      set_real (input->at (0, 1).mpc_data (), 0);
      set_real (input->at (1, 1).mpc_data (), 1);
    }
  const auto low_result = octave_mplapack::mplapack_mpc_matrix_lu (low);
  const auto high_result = octave_mplapack::mplapack_mpc_matrix_lu (high);
  check (low_result.permutation.at (0) == 1
         && high_result.permutation.at (0) == 2,
         "precision-dependent complex LU pivot mismatch");
}

void
test_singular_empty_and_lifetime ()
{
  const Matrix singular (2, 2, 256,
                         std::vector<std::complex<double>> {
                           {1.0, 0.0}, {2.0, 0.0},
                           {2.0, 0.0}, {4.0, 0.0}});
  const auto result = octave_mplapack::mplapack_mpc_matrix_lu (singular);
  check (result.info == 2 && result.permutation.at (0) == 2
         && result.packed.rows () == 2 && result.upper.rows () == 2,
         "singular complex LU status or partial factors mismatch");
  check_raw_reconstruction (singular, result.lower, result.upper,
                            result.permutation,
                            "singular complex LU partial reconstruction mismatch");

  const Matrix empty (0, 3, 512);
  const auto empty_result = octave_mplapack::mplapack_mpc_matrix_lu (empty);
  check (empty_result.info == 0 && empty_result.packed.rows () == 0
         && empty_result.packed.columns () == 0
         && empty_result.lower.rows () == 0 && empty_result.upper.rows () == 0
         && empty_result.permutation.empty (),
         "empty complex LU result mismatch");

  Matrix scoped_input (2, 2, 512,
                       std::vector<std::complex<double>> {
                         {4.0, 0.0}, {1.0, 2.0},
                         {2.0, -1.0}, {3.0, 0.0}});
  auto retained = octave_mplapack::mplapack_mpc_matrix_lu (scoped_input);
  scoped_input = Matrix (0, 0, 512);
  check (retained.packed.rows () == 2 && retained.packed.columns () == 2
         && retained.packed.all_elements_have_uniform_precision (),
         "complex LU result did not retain operation-owned storage");
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
      test_singular_empty_and_lifetime ();
      std::cout << "PASS: complex Cgetrf LU packed/two-factor shapes, row permutations, rectangular and singular behavior, source-precision pivots, ambient scope, immutability, and lifetime\n";
      return 0;
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
}
