// SPDX-License-Identifier: BSD-2-Clause

#include <complex>
#include <iostream>
#include <stdexcept>
#include <vector>

#include "mp_complex_matrix_concat.h"
#include "mp_matrix_storage.h"

namespace
{

using ComplexMatrix = octave_mplapack::MpfrComplexMatrixStorage;
using RealMatrix = octave_mplapack::MpfrMatrixStorage;

void
check (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

void
test_horizontal_mixed_concat ()
{
  const RealMatrix real (2, 1, 256, std::vector<double> {1.0, 2.0});
  const ComplexMatrix complex (2, 1, 1024,
                               std::vector<std::complex<double>> {
                                 {3.0, 4.0}, {5.0, -6.0}});
  octave_mplapack::MpcConcatOperand real_operand;
  real_operand.rows = real.rows ();
  real_operand.columns = real.columns ();
  real_operand.precision_bits = real.precision_bits ();
  real_operand.has_mp_precision = true;
  real_operand.copy_element
    = [&real] (mpfrxx::mpc_class& destination, std::size_t row,
               std::size_t column)
    {
      mpc_set_fr (destination.mpc_data (), real.at (row, column).mpfr_data (),
                  MPC_RND (MPFR_RNDN, MPFR_RNDN));
    };

  octave_mplapack::MpcConcatOperand complex_operand;
  complex_operand.rows = complex.rows ();
  complex_operand.columns = complex.columns ();
  complex_operand.precision_bits = complex.precision_bits ();
  complex_operand.has_mp_precision = true;
  complex_operand.copy_element
    = [&complex] (mpfrxx::mpc_class& destination, std::size_t row,
                  std::size_t column)
    {
      mpc_set (destination.mpc_data (), complex.at (row, column).mpc_data (),
               MPC_RND (MPFR_RNDN, MPFR_RNDN));
    };

  const auto result = octave_mplapack::mpc_matrix_concatenate (
    {real_operand, complex_operand}, 1, 2, 2, 1024);
  check (result.rows () == 2 && result.columns () == 2
           && result.precision_bits () == 1024
           && result.all_elements_have_uniform_precision (),
         "mixed horizontal complex concatenation metadata mismatch");
  check (result.element_exactly_equal_double (0, 0, {1.0, 0.0})
           && result.element_exactly_equal_double (1, 0, {2.0, 0.0})
           && result.element_exactly_equal_double (0, 1, {3.0, 4.0})
           && result.element_exactly_equal_double (1, 1, {5.0, -6.0}),
         "mixed horizontal complex concatenation values mismatch");
}

void
test_vertical_and_empty_concat ()
{
  const RealMatrix real (1, 2, 512, std::vector<double> {1.0, 2.0});
  const ComplexMatrix complex (1, 2, 512,
                               std::vector<std::complex<double>> {
                                 {3.0, 1.0}, {4.0, -1.0}});
  octave_mplapack::MpcConcatOperand real_operand;
  real_operand.rows = 1;
  real_operand.columns = 2;
  real_operand.precision_bits = 512;
  real_operand.has_mp_precision = true;
  real_operand.copy_element
    = [&real] (mpfrxx::mpc_class& destination, std::size_t row,
               std::size_t column)
    {
      mpc_set_fr (destination.mpc_data (), real.at (row, column).mpfr_data (),
                  MPC_RND (MPFR_RNDN, MPFR_RNDN));
    };
  octave_mplapack::MpcConcatOperand complex_operand;
  complex_operand.rows = 1;
  complex_operand.columns = 2;
  complex_operand.precision_bits = 512;
  complex_operand.has_mp_precision = true;
  complex_operand.copy_element
    = [&complex] (mpfrxx::mpc_class& destination, std::size_t row,
                  std::size_t column)
    {
      mpc_set (destination.mpc_data (), complex.at (row, column).mpc_data (),
               MPC_RND (MPFR_RNDN, MPFR_RNDN));
    };

  const auto result = octave_mplapack::mpc_matrix_concatenate (
    {real_operand, complex_operand}, 0, 2, 2, 512);
  check (result.element_exactly_equal_double (0, 0, {1.0, 0.0})
           && result.element_exactly_equal_double (0, 1, {2.0, 0.0})
           && result.element_exactly_equal_double (1, 0, {3.0, 1.0})
           && result.element_exactly_equal_double (1, 1, {4.0, -1.0}),
         "mixed vertical complex concatenation values mismatch");

  octave_mplapack::MpcConcatOperand empty_operand;
  empty_operand.rows = 0;
  empty_operand.columns = 2;
  empty_operand.precision_bits = 2048;
  empty_operand.has_mp_precision = true;
  empty_operand.copy_element
    = [] (mpfrxx::mpc_class&, std::size_t, std::size_t) {};
  const auto empty_result = octave_mplapack::mpc_matrix_concatenate (
    {empty_operand}, 0, 0, 2, 2048);
  check (empty_result.rows () == 0 && empty_result.columns () == 2
           && empty_result.precision_bits () == 2048,
         "empty complex concatenation shape mismatch");
}

} // namespace

int
main ()
{
  try
    {
      test_horizontal_mixed_concat ();
      test_vertical_and_empty_concat ();
      std::cout << "PASS: native mixed real/complex concatenation, precision, values, and empty shapes\n";
      return 0;
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
}
