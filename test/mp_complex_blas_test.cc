// SPDX-License-Identifier: BSD-2-Clause

#include <array>
#include <iostream>
#include <stdexcept>
#include <vector>

#include "mp_complex_blas.h"

namespace
{

void
check (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

void
set_power_of_two (mpc_ptr value, unsigned long exponent)
{
  mpfr_set_ui (mpc_realref (value), 1, MPFR_RNDN);
  mpfr_div_2si (mpc_realref (value), mpc_realref (value), exponent,
                MPFR_RNDN);
  mpfr_set (mpc_imagref (value), mpc_realref (value), MPFR_RNDN);
  mpfr_neg (mpc_imagref (value), mpc_imagref (value), MPFR_RNDN);
}

} // namespace

int
main ()
{
  try
    {
      for (mpfr_prec_t precision : {128, 512})
        {
          octave_mplapack::MpfrComplexMatrixStorage lhs (
            2, 2, precision,
            std::vector<std::complex<double>> {
              {1.0, 2.0}, {3.0, 4.0}, {5.0, 6.0}, {7.0, 8.0}});
          octave_mplapack::MpfrComplexMatrixStorage rhs (
            2, 2, precision,
            std::vector<std::complex<double>> {
              {1.0, 0.0}, {0.0, 1.0}, {2.0, -1.0}, {1.0, 2.0}});
          const auto product = octave_mplapack::mplapack_mpc_matrix_multiply (
            lhs, rhs);
          check (product.precision_bits () == precision,
                 "Cgemm result precision mismatch");
          check (product.element_exactly_equal_double (0, 0, {-5.0, 7.0}),
                 "Cgemm first result mismatch");
          check (product.element_exactly_equal_double (1, 1, {1.0, 27.0}),
                 "Cgemm second result mismatch");
          check (lhs.element_exactly_equal_double (0, 0, {1.0, 2.0}),
                 "Cgemm mutated lhs");
          check (rhs.element_exactly_equal_double (1, 1, {1.0, 2.0}),
                 "Cgemm mutated rhs");

          octave_mplapack::MpfrMatrixStorage real (
            2, 2, precision, {1.0, 2.0, 3.0, 4.0});
          const auto complex_real
            = octave_mplapack::mplapack_mpc_matrix_from_real (real, precision);
          const auto mixed = octave_mplapack::mplapack_mpc_matrix_multiply (
            complex_real, rhs);
          check (mixed.element_exactly_equal_double (0, 0, {1.0, 3.0}),
                 "mixed real/complex Cgemm mismatch");
        }

      for (const std::array<unsigned long, 2> settings : {
             std::array<unsigned long, 2> {{1024, 700}},
             std::array<unsigned long, 2> {{2048, 1500}}})
        {
          const mpfr_prec_t precision = static_cast<mpfr_prec_t> (settings[0]);
          const unsigned long exponent = static_cast<unsigned long> (settings[1]);
          octave_mplapack::MpfrComplexMatrixStorage lhs (1, 1, precision);
          set_power_of_two (lhs.at (0, 0).mpc_data (), exponent);
          octave_mplapack::MpfrComplexMatrixStorage unit (
            1, 1, precision,
            std::vector<std::complex<double>> {{1.0, 0.0}});
          const auto product = octave_mplapack::mplapack_mpc_matrix_multiply (
            lhs, unit);
          check (mpfr_equal_p (mpc_realref (product.at (0, 0).mpc_data ()),
                               mpc_realref (lhs.at (0, 0).mpc_data ())) != 0,
                 "Cgemm real precision canary changed");
          check (mpfr_equal_p (mpc_imagref (product.at (0, 0).mpc_data ()),
                               mpc_imagref (lhs.at (0, 0).mpc_data ())) != 0,
                 "Cgemm imaginary precision canary changed");
        }

      octave_mplapack::MpfrComplexMatrixStorage empty_lhs (1, 0, 256);
      octave_mplapack::MpfrComplexMatrixStorage empty_rhs (0, 2, 256);
      const auto empty = octave_mplapack::mplapack_mpc_matrix_multiply (
        empty_lhs, empty_rhs);
      check (empty.rows () == 1 && empty.columns () == 2
               && empty.numel () == 2,
             "empty Cgemm shape mismatch");

      std::cout << "PASS: complex Cgemm dispatch, precision boundary, mixed real/complex inputs, canaries, shapes, and immutability\n";
      return 0;
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
}
