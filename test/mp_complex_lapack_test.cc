// SPDX-License-Identifier: BSD-2-Clause

#include <array>
#include <cmath>
#include <iostream>
#include <stdexcept>
#include <type_traits>
#include <vector>

#include "mp_complex_blas.h"
#include "mp_complex_lapack.h"

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
      static_assert (std::is_same_v<
        octave_mplapack::MpfrComplexMatrixStorage::MplapackInteger,
        mplapackint>);

      const std::vector<std::complex<double>> coefficient {
        {3.0, 1.0}, {2.0, 0.0}, {1.0, -1.0}, {4.0, 2.0}};
      const std::vector<std::complex<double>> right_hand_side {
        {4.0, 4.0}, {14.0, 10.0}, {10.0, 4.0}, {-8.0, 12.0}};
      const std::vector<std::complex<double>> expected {
        {1.0, 2.0}, {3.0, 0.0}, {2.0, -1.0}, {-1.0, 4.0}};

      for (mpfr_prec_t precision : {128, 512})
        {
          octave_mplapack::MpfrComplexMatrixStorage lhs (
            2, 2, precision, coefficient);
          octave_mplapack::MpfrComplexMatrixStorage rhs (
            2, 2, precision, right_hand_side);
          const auto solution = octave_mplapack::mplapack_mpc_matrix_solve (
            lhs, rhs);
          check (solution.precision_bits () == precision,
                 "Cgesv solution precision mismatch");
          for (std::size_t column = 0; column < 2; ++column)
            for (std::size_t row = 0; row < 2; ++row)
              {
                const octave_mplapack::MpfrComplexScalarStorage actual (
                  solution.at (row, column));
                check (std::abs (actual.to_double ()
                                 - expected[row + 2 * column]) < 1.0e-12,
                       "Cgesv multiple-RHS solution mismatch");
              }
          check (lhs.element_exactly_equal_double (0, 0, coefficient[0]),
                 "Cgesv mutated coefficient matrix");
          check (rhs.element_exactly_equal_double (1, 1,
                                                   right_hand_side[3]),
                 "Cgesv mutated right-hand side");

          octave_mplapack::MpfrMatrixStorage real_lhs (
            2, 2, precision, {3.0, 2.0, 1.0, 4.0});
          octave_mplapack::MpfrMatrixStorage real_rhs (
            2, 2, precision, {9.0, 8.0, 7.0, 9.0});
          const auto complex_lhs
            = octave_mplapack::mplapack_mpc_matrix_from_real (
              real_lhs, precision);
          const auto complex_rhs
            = octave_mplapack::mplapack_mpc_matrix_from_real (
              real_rhs, precision);
          const auto mixed = octave_mplapack::mplapack_mpc_matrix_solve (
            complex_lhs, complex_rhs);
          const octave_mplapack::MpfrComplexScalarStorage mixed_first (
            mixed.at (0, 0));
          const octave_mplapack::MpfrComplexScalarStorage mixed_last (
            mixed.at (1, 1));
          check (std::abs (mixed_first.to_double ()
                           - std::complex<double> {2.8, 0.0}) < 1.0e-12,
                 "mixed real/complex Cgesv mismatch");
          check (std::abs (mixed_last.to_double ()
                           - std::complex<double> {1.3, 0.0}) < 1.0e-12,
                 "mixed real/complex multiple-RHS mismatch");
        }

      for (const std::array<unsigned long, 2> settings : {
             std::array<unsigned long, 2> {{1024, 700}},
             std::array<unsigned long, 2> {{2048, 1500}}})
        {
          const mpfr_prec_t precision = static_cast<mpfr_prec_t> (settings[0]);
          const unsigned long exponent = settings[1];
          octave_mplapack::MpfrComplexMatrixStorage lhs (
            2, 2, precision,
            std::vector<std::complex<double>> {
              {1.0, 0.0}, {0.0, 0.0}, {0.0, 0.0}, {1.0, 0.0}});
          octave_mplapack::MpfrComplexMatrixStorage rhs (
            2, 1, precision);
          set_power_of_two (rhs.at (0, 0).mpc_data (), exponent);
          set_power_of_two (rhs.at (1, 0).mpc_data (), exponent);
          mpfrxx::set_default_precision_bits (128);
          const auto solution
            = octave_mplapack::mplapack_mpc_matrix_solve (lhs, rhs);
          check (solution.precision_bits () == precision,
                 "Cgesv canary precision mismatch");
          check (mpfr_equal_p (mpc_realref (solution.at (0, 0).mpc_data ()),
                               mpc_realref (rhs.at (0, 0).mpc_data ())) != 0,
                 "Cgesv real precision canary changed");
          check (mpfr_equal_p (mpc_imagref (solution.at (1, 0).mpc_data ()),
                               mpc_imagref (rhs.at (1, 0).mpc_data ())) != 0,
                 "Cgesv imaginary precision canary changed");
          check (mpfrxx::default_precision_bits () == 128,
                 "Cgesv changed ambient precision");
        }

      octave_mplapack::MpfrComplexMatrixStorage singular (
        2, 2, 256, std::vector<std::complex<double>> {
          {1.0, 0.0}, {2.0, 0.0}, {2.0, 0.0}, {4.0, 0.0}});
      octave_mplapack::MpfrComplexMatrixStorage singular_rhs (
        2, 1, 256, std::vector<std::complex<double>> {{1.0, 0.0},
                                                       {2.0, 0.0}});
      bool singular_seen = false;
      try
        {
          octave_mplapack::mplapack_mpc_matrix_solve (singular,
                                                       singular_rhs);
        }
      catch (const octave_mplapack::MpcCgesvError& exception)
        {
          singular_seen = true;
          check (exception.kind ()
                   == octave_mplapack::MpcCgesvError::Kind::singular,
                 "Cgesv singular classification mismatch");
          check (exception.info () > 0, "Cgesv singular info mismatch");
        }
      check (singular_seen, "Cgesv singular solve unexpectedly succeeded");

      octave_mplapack::MpfrComplexMatrixStorage nonsquare (
        2, 1, 256, std::vector<std::complex<double>> {{1.0, 0.0},
                                                       {2.0, 0.0}});
      bool nonsquare_seen = false;
      try
        {
          octave_mplapack::mplapack_mpc_matrix_solve (nonsquare,
                                                       singular_rhs);
        }
      catch (const std::invalid_argument&)
        {
          nonsquare_seen = true;
        }
      check (nonsquare_seen, "Cgesv nonsquare solve unexpectedly succeeded");

      octave_mplapack::MpfrComplexMatrixStorage empty_lhs (0, 0, 256);
      octave_mplapack::MpfrComplexMatrixStorage empty_rhs (0, 3, 256);
      const auto empty = octave_mplapack::mplapack_mpc_matrix_solve (
        empty_lhs, empty_rhs);
      check (empty.rows () == 0 && empty.columns () == 3,
             "Cgesv empty shape mismatch");

      std::cout << "PASS: complex Cgesv dispatch, pivot type, singular behavior, multiple RHS, precision canaries, ambient precision, and immutability\n";
      return 0;
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
}
