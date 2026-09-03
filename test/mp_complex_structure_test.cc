// SPDX-License-Identifier: BSD-2-Clause

#include <complex>
#include <iostream>
#include <stdexcept>
#include <vector>

#include "mp_complex_structure.h"
#include "mp_matrix_structure.h"

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
          octave_mplapack::MpfrComplexScalarStorage scalar (
            "(1.25,-2.5)", precision);
          const auto real = octave_mplapack::mpfr_complex_scalar_real (scalar);
          const auto imag = octave_mplapack::mpfr_complex_scalar_imag (scalar);
          const auto conjugate =
            octave_mplapack::mpfr_complex_scalar_conj (scalar);
          const auto transpose =
            octave_mplapack::mpfr_complex_scalar_transpose (scalar);
          const auto ctranspose =
            octave_mplapack::mpfr_complex_scalar_ctranspose (scalar);
          check (real.precision_bits () == precision
                   && imag.precision_bits () == precision,
                 "scalar component precision changed");
          check (real.exactly_equal_string ("1.25"),
                 "real component mismatch");
          check (imag.exactly_equal_string ("-2.5"),
                 "imaginary component mismatch");
          check (conjugate.to_canonical_string () == "(1.25e+0,2.5e+0)",
                 "scalar conjugate mismatch");
          check (transpose.exactly_equal (scalar),
                 "scalar transpose changed value");
          check (ctranspose.exactly_equal (conjugate),
                 "scalar conjugate transpose mismatch");

          octave_mplapack::MpfrComplexScalarStorage signed_zero (
            0.0, -0.0, precision);
          const auto signed_conjugate =
            octave_mplapack::mpfr_complex_scalar_conj (signed_zero);
          check (signed_zero.imag_signbit ()
                   && ! signed_conjugate.imag_signbit (),
                 "scalar conjugation did not flip signed zero");

          const std::vector<std::complex<double>> values {
            {1.0, 2.0}, {5.0, 6.0}, {3.0, -4.0}, {7.0, -8.0}
          };
          octave_mplapack::MpfrComplexMatrixStorage matrix (
            2, 2, precision, values);
          const auto matrix_real =
            octave_mplapack::mpfr_complex_matrix_real (matrix);
          const auto matrix_imag =
            octave_mplapack::mpfr_complex_matrix_imag (matrix);
          const auto matrix_conj =
            octave_mplapack::mpfr_complex_matrix_conj (matrix);
          const auto matrix_transpose =
            octave_mplapack::mpfr_complex_matrix_transpose (matrix);
          const auto matrix_ctranspose =
            octave_mplapack::mpfr_complex_matrix_ctranspose (matrix);
          check (matrix_real.rows () == 2 && matrix_real.columns () == 2
                   && matrix_imag.precision_bits () == precision,
                 "matrix component shape or precision mismatch");
          check (matrix_real.element_exactly_equal_double (1, 0, 5.0),
                 "matrix real component mismatch");
          check (matrix_imag.element_exactly_equal_double (0, 1, -4.0),
                 "matrix imaginary component mismatch");
          check (matrix_conj.element_exactly_equal_double (0, 1,
                                                            {3.0, 4.0}),
                 "matrix conjugate mismatch");
          check (matrix_transpose.element_exactly_equal_double (0, 1,
                                                                 {5.0, 6.0}),
                 "matrix transpose mismatch");
          check (matrix_ctranspose.element_exactly_equal_double (0, 1,
                                                                  {5.0, -6.0}),
                 "matrix conjugate transpose mismatch");
        }

      std::cout << "PASS: complex real/imag/conjugate/transpose helpers, signed zero, precision, and sanitizer coverage\n";
      return 0;
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
}
