// SPDX-License-Identifier: BSD-2-Clause

#include <complex>
#include <iostream>
#include <stdexcept>
#include <vector>

#include "mp_complex_arithmetic.h"

namespace
{

void
check (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

} // namespace

int
main ()
{
  try
    {
      for (mpfr_prec_t precision : {128, 512, 1024, 2048})
        {
          octave_mplapack::MpfrComplexScalarStorage lhs (
            "(1.5,2)", precision);
          octave_mplapack::MpfrComplexScalarStorage rhs (
            "(2,-1)", precision);
          octave_mplapack::MpfrScalarStorage real_rhs ("2", precision);
          const auto sum = octave_mplapack::mpc_matrix_elementwise_binary (
            octave_mplapack::MpcElementwiseOperand::from_complex_scalar (lhs),
            octave_mplapack::MpcElementwiseOperand::from_complex_scalar (rhs),
            octave_mplapack::MpcElementwiseBinaryOperation::add);
          const auto product = octave_mplapack::mpc_matrix_elementwise_binary (
            octave_mplapack::MpcElementwiseOperand::from_complex_scalar (lhs),
            octave_mplapack::MpcElementwiseOperand::from_real_scalar (real_rhs),
            octave_mplapack::MpcElementwiseBinaryOperation::multiply);
          check (sum.precision_bits () == precision
                   && product.precision_bits () == precision,
                 "scalar result precision changed");
          check (sum.element_exactly_equal_double (0, 0, {3.5, 1.0}),
                 "complex scalar sum mismatch");
          check (product.element_exactly_equal_double (0, 0, {3.0, 4.0}),
                 "mixed scalar product mismatch");

          const std::vector<std::complex<double>> matrix_values {
            {1.0, 2.0}, {3.0, 4.0}, {5.0, 6.0}, {7.0, 8.0}
          };
          const std::vector<std::complex<double>> row_values {
            {10.0, 1.0}, {20.0, 2.0}
          };
          octave_mplapack::MpfrComplexMatrixStorage matrix (
            2, 2, precision, matrix_values);
          octave_mplapack::MpfrComplexMatrixStorage row (
            1, 2, precision, row_values);
          const auto broadcast = octave_mplapack::mpc_matrix_elementwise_binary (
            octave_mplapack::MpcElementwiseOperand::from_complex_matrix (matrix),
            octave_mplapack::MpcElementwiseOperand::from_complex_matrix (row),
            octave_mplapack::MpcElementwiseBinaryOperation::add);
          check (broadcast.rows () == 2 && broadcast.columns () == 2,
                 "complex broadcast shape mismatch");
          check (broadcast.element_exactly_equal_double (1, 1, {27.0, 10.0}),
                 "complex broadcast value mismatch");

          const auto negated = octave_mplapack::mpc_matrix_negate (matrix);
          check (negated.element_exactly_equal_double (0, 1, {-5.0, -6.0}),
                 "complex matrix negate mismatch");

          octave_mplapack::MpfrComplexMatrixStorage zero (
            1, 1, precision,
            std::vector<std::complex<double>> {{0.0, 0.0}});
          const auto quotient = octave_mplapack::mpc_matrix_elementwise_binary (
            octave_mplapack::MpcElementwiseOperand::from_complex_scalar (lhs),
            octave_mplapack::MpcElementwiseOperand::from_complex_matrix (zero),
            octave_mplapack::MpcElementwiseBinaryOperation::divide);
          const octave_mplapack::MpfrComplexScalarStorage quotient_scalar (
            quotient.at (0, 0));
          check (quotient_scalar.is_nan () || quotient_scalar.is_infinite (),
                 "complex division by zero was not deterministic");
        }

      std::cout << "PASS: complex element-wise arithmetic, mixed real operands, broadcasting, precision, special values, and sanitizer coverage\n";
      return 0;
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
}
