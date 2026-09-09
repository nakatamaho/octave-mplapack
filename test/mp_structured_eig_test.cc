// SPDX-License-Identifier: BSD-2-Clause

#include "mp_structured_eig.h"

#include <cmath>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

#include <gmp.h>

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

bool
close_to (const MpfrMatrixStorage::NativeScalar& lhs,
          const MpfrMatrixStorage::NativeScalar& rhs,
          double tolerance)
{
  auto difference = MpfrMatrixStorage::NativeScalar::with_precision (
    lhs.precision ());
  mpfr_sub (difference.mpfr_data (), lhs.mpfr_data (), rhs.mpfr_data (),
            MPFR_RNDN);
  return std::abs (mpfr_get_d (difference.mpfr_data (), MPFR_RNDN))
         <= tolerance;
}

} // namespace

int
main ()
{
  try
    {
      MpfrMatrixStorage real (2, 2, 256,
                              std::vector<double> {2.0, 1.0, 1.0, 2.0});
      const auto real_result
        = octave_mplapack::mplapack_mpfr_matrix_structured_eig (real);
      require (real_result.eigenvalues.rows () == 2
                 && real_result.eigenvalues.columns () == 1,
               "real eigenvalue shape mismatch");
      require (real_result.vectors.rows () == 2
                 && real_result.vectors.columns () == 2,
               "real eigenvector shape mismatch");
      require (close_to (real_result.eigenvalues.at (0, 0),
                         MpfrMatrixStorage::NativeScalar (1.0, 256), 1e-60),
               "real first eigenvalue mismatch");
      require (close_to (real_result.eigenvalues.at (1, 0),
                         MpfrMatrixStorage::NativeScalar (3.0, 256), 1e-60),
               "real second eigenvalue mismatch");
      require (real.element_exactly_equal_double (0, 1, 1.0),
               "real structured eig modified its input");

      MpfrComplexMatrixStorage complex (2, 2, 256,
        std::vector<std::string> {"(2,0)", "(1,-1)",
                                  "(1,1)", "(3,0)"});
      const auto complex_result
        = octave_mplapack::mplapack_mpc_matrix_structured_eig (complex);
      require (complex_result.eigenvalues.rows () == 2
                 && complex_result.vectors.columns () == 2,
               "complex structured eig shape mismatch");
      require (complex_result.eigenvalues.precision_bits () == 256
                 && complex_result.vectors.precision_bits () == 256,
               "structured eig precision mismatch");
      require (complex.element_exactly_equal_text (1, 0, "(1,-1)"),
               "complex structured eig modified its input");

      MpfrMatrixStorage nonsymmetric (2, 2, 256,
                                      std::vector<double> {1.0, 2.0,
                                                           3.0, 4.0});
      bool rejected = false;
      try
        {
          (void) octave_mplapack::mplapack_mpfr_matrix_structured_eig (
            nonsymmetric);
        }
      catch (const std::invalid_argument&)
        {
          rejected = true;
        }
      require (rejected, "nonsymmetric input was not rejected");

      MpfrComplexMatrixStorage nonhermitian (2, 2, 256,
        std::vector<std::string> {"(1,1)", "(2,0)",
                                  "(3,0)", "(4,0)"});
      rejected = false;
      try
        {
          (void) octave_mplapack::mplapack_mpc_matrix_structured_eig (
            nonhermitian);
        }
      catch (const std::invalid_argument&)
        {
          rejected = true;
        }
      require (rejected, "non-Hermitian input was not rejected");

      std::cout << "PASS: structured real symmetric and complex Hermitian "
                   "Rsyevd/Cheevd eigenvalue QA, precision, rejection, "
                   "and immutability\n";
      return 0;
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
}
