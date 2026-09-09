// SPDX-License-Identifier: BSD-2-Clause

#include "mp_generalized_eig.h"

#include <cmath>
#include <iostream>
#include <stdexcept>
#include <string>
#include <variant>
#include <vector>

using octave_mplapack::MpGeneralizedComplexDefiniteEigResult;
using octave_mplapack::MpGeneralizedEigResult;
using octave_mplapack::MpGeneralizedQzEigResult;
using octave_mplapack::MpGeneralizedRealDefiniteEigResult;
using octave_mplapack::MpfrComplexMatrixStorage;
using octave_mplapack::MpfrMatrixStorage;

namespace
{

void
require (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

double
real_component (const MpfrComplexMatrixStorage::NativeScalar& value)
{
  return mpfr_get_d (mpc_realref (value.mpc_data ()), MPFR_RNDN);
}

double
imag_component (const MpfrComplexMatrixStorage::NativeScalar& value)
{
  return mpfr_get_d (mpc_imagref (value.mpc_data ()), MPFR_RNDN);
}

void
check_precision (const MpfrMatrixStorage& matrix, mpfr_prec_t precision)
{
  require (matrix.precision_bits () == precision
             && matrix.all_elements_have_uniform_precision (),
           "real generalized eig precision contract mismatch");
}

void
check_precision (const MpfrComplexMatrixStorage& matrix,
                 mpfr_prec_t precision)
{
  require (matrix.precision_bits () == precision
             && matrix.all_elements_have_uniform_precision (),
           "complex generalized eig precision contract mismatch");
}

} // namespace

int
main ()
{
  try
    {
      MpfrMatrixStorage real_a (2, 2, 256,
                                std::vector<double> {2.0, 1.0, 1.0, 3.0});
      MpfrMatrixStorage real_b (2, 2, 256,
                                std::vector<double> {3.0, 0.0, 0.0, 2.0});
      const auto real_before = real_a;
      const MpGeneralizedEigResult real_definite
        = octave_mplapack::mplapack_mpfr_matrix_generalized_eig (
          real_a, real_b,
          octave_mplapack::GeneralizedEigAlgorithm::auto_select);
      const auto& definite
        = std::get<MpGeneralizedRealDefiniteEigResult> (real_definite);
      require (std::abs (mpfr_get_d (definite.eigenvalues.at (0, 0).mpfr_data (),
                                     MPFR_RNDN) - 0.5) < 1e-12,
               "real definite generalized eigenvalue mismatch");
      require (std::abs (mpfr_get_d (definite.eigenvalues.at (1, 0).mpfr_data (),
                                     MPFR_RNDN) - 5.0 / 3.0) < 1e-12,
               "real definite generalized eigenvalue mismatch");
      check_precision (definite.eigenvalues, 256);
      check_precision (definite.right_vectors, 256);
      require (real_a.element_exactly_equal (0, 0, real_before, 0, 0)
                 && real_a.element_exactly_equal (1, 0, real_before, 1, 0),
               "Rsygvd modified generalized eig input");

      const auto real_qz
        = octave_mplapack::mplapack_mpfr_matrix_generalized_eig (
          MpfrMatrixStorage (2, 2, 256,
                             std::vector<double> {0.0, -1.0, 1.0, 0.0}),
          MpfrMatrixStorage (2, 2, 256,
                             std::vector<double> {1.0, 0.0, 0.0, 1.0}),
          octave_mplapack::GeneralizedEigAlgorithm::qz);
      const auto& qz = std::get<MpGeneralizedQzEigResult> (real_qz);
      require (qz.eigenvalues.rows () == 2
                 && qz.right_vectors.columns () == 2
                 && qz.left_vectors.columns () == 2,
               "real generalized QZ shape mismatch");
      require (std::abs (std::abs (imag_component (qz.eigenvalues.at (0, 0)))
                         - 1.0) < 1e-12,
               "real generalized QZ conjugate pair mismatch");
      check_precision (qz.eigenvalues, 256);

      MpfrComplexMatrixStorage complex_a (2, 2, 256,
        std::vector<std::string> {"(1,0)", "(0,-1)",
                                  "(0,1)", "(3,0)"});
      MpfrComplexMatrixStorage complex_b (2, 2, 256,
        std::vector<std::string> {"(2,0)", "(0,0)",
                                  "(0,0)", "(1,0)"});
      const auto complex_definite
        = octave_mplapack::mplapack_mpc_matrix_generalized_eig (
          complex_a, complex_b,
          octave_mplapack::GeneralizedEigAlgorithm::chol);
      const auto& cdefinite
        = std::get<MpGeneralizedComplexDefiniteEigResult> (complex_definite);
      require (cdefinite.eigenvalues.rows () == 2
                 && cdefinite.right_vectors.columns () == 2,
               "complex definite generalized eig shape mismatch");
      require (real_component (cdefinite.right_vectors.at (0, 0))
                   == real_component (cdefinite.right_vectors.at (0, 0)),
               "complex definite generalized eig returned invalid data");
      check_precision (cdefinite.eigenvalues, 256);
      check_precision (cdefinite.right_vectors, 256);

      const auto complex_qz
        = octave_mplapack::mplapack_mpc_matrix_generalized_eig (
          MpfrComplexMatrixStorage (2, 2, 256,
            std::vector<std::string> {"(0,0)", "(-1,0)",
                                      "(1,0)", "(0,0)"}),
          MpfrComplexMatrixStorage (2, 2, 256,
            std::vector<std::string> {"(1,0)", "(0,0)",
                                      "(0,0)", "(1,0)"}),
          octave_mplapack::GeneralizedEigAlgorithm::qz);
      const auto& cqz = std::get<MpGeneralizedQzEigResult> (complex_qz);
      require (std::abs (real_component (cqz.eigenvalues.at (0, 0))) < 1e-12
                 && std::abs (std::abs (imag_component (
                       cqz.eigenvalues.at (0, 0))) - 1.0) < 1e-12,
               "complex generalized QZ eigenvalue mismatch");
      check_precision (cqz.eigenvalues, 256);

      const auto infinite
        = octave_mplapack::mplapack_mpfr_matrix_generalized_eig (
          MpfrMatrixStorage (2, 2, 256,
                             std::vector<double> {1.0, 0.0, 0.0, 1.0}),
          MpfrMatrixStorage (2, 2, 256,
                             std::vector<double> {1.0, 0.0, 0.0, 0.0}),
          octave_mplapack::GeneralizedEigAlgorithm::auto_select);
      const auto& infinite_qz = std::get<MpGeneralizedQzEigResult> (infinite);
      require (mpfr_inf_p (mpc_realref (
                              infinite_qz.eigenvalues.at (1, 0).mpc_data ()))
                 != 0,
               "singular-B generalized eig did not preserve infinity");

      bool rejected = false;
      try
        {
          octave_mplapack::mplapack_mpfr_matrix_generalized_eig (
            MpfrMatrixStorage (2, 2, 256,
                               std::vector<double> {1.0, 1.0, 0.0, 1.0}),
            real_b, octave_mplapack::GeneralizedEigAlgorithm::chol);
        }
      catch (const std::invalid_argument&)
        {
          rejected = true;
        }
      require (rejected, "chol accepted a nonsymmetric generalized pair");

      for (mpfr_prec_t precision : {1024, 2048})
        {
          MpfrMatrixStorage high_a (2, 2, precision,
                                    std::vector<double> {1.0, 0.0, 0.0, 3.0});
          MpfrMatrixStorage high_b (2, 2, precision,
                                    std::vector<double> {1.0, 0.0, 0.0, 1.0});
          const auto high
            = octave_mplapack::mplapack_mpfr_matrix_generalized_eig (
              high_a, high_b,
              octave_mplapack::GeneralizedEigAlgorithm::qz);
          const auto& high_qz = std::get<MpGeneralizedQzEigResult> (high);
          check_precision (high_qz.eigenvalues, precision);
          require (std::abs (real_component (high_qz.eigenvalues.at (0, 0)) - 1.0)
                     < 1e-12,
                   "high precision generalized QZ canary mismatch");
        }

      std::cout << "PASS: real/complex generalized eig, definite/QZ dispatch, "
                   "singular-B infinity, precision canaries, immutability, "
                   "and option validation\n";
      return 0;
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
}
