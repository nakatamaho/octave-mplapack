// SPDX-License-Identifier: BSD-2-Clause

#include "mp_general_eig.h"

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

double
component_double (const MpfrComplexMatrixStorage::NativeScalar& value,
                  bool imaginary)
{
  return mpfr_get_d (imaginary ? mpc_imagref (value.mpc_data ())
                               : mpc_realref (value.mpc_data ()),
                     MPFR_RNDN);
}

} // namespace

int
main ()
{
  try
    {
      MpfrMatrixStorage real (2, 2, 256,
                              std::vector<double> {0.0, 1.0, -1.0, 0.0});
      const auto balanced
        = octave_mplapack::mplapack_mpfr_matrix_general_eig (real, true);
      const auto unbalanced
        = octave_mplapack::mplapack_mpfr_matrix_general_eig (real, false);
      require (balanced.eigenvalues.rows () == 2
                 && balanced.right_vectors.rows () == 2
                 && balanced.left_vectors.columns () == 2,
               "real general eig shape mismatch");
      require (balanced.eigenvalues.precision_bits () == 256
                 && balanced.right_vectors.precision_bits () == 256,
               "real general eig precision mismatch");
      for (std::size_t index = 0; index < 2; ++index)
        {
          require (std::abs (component_double (
                     balanced.eigenvalues.at (index, 0), false)) < 1e-12,
                   "real conjugate-pair real part mismatch");
          require (std::abs (std::abs (component_double (
                     balanced.eigenvalues.at (index, 0), true)) - 1.0) < 1e-12,
                   "real conjugate-pair imaginary part mismatch");
        }
      require (real.element_exactly_equal_double (0, 1, -1.0),
               "real general eig modified its input");
      require (unbalanced.eigenvalues.rows () == 2,
               "Rgeevx nobalance path did not return eigenvalues");

      MpfrComplexMatrixStorage complex (2, 2, 256,
        std::vector<std::string> {"(1,0)", "(0,0)",
                                  "(2,1)", "(3,0)"});
      const auto complex_result
        = octave_mplapack::mplapack_mpc_matrix_general_eig (complex, true);
      require (complex_result.eigenvalues.rows () == 2
                 && complex_result.right_vectors.columns () == 2
                 && complex_result.left_vectors.columns () == 2,
               "complex general eig shape mismatch");
      require (complex_result.eigenvalues.precision_bits () == 256,
               "complex general eig precision mismatch");
      require (complex.element_exactly_equal_text (0, 1, "(2,1)"),
               "complex general eig modified its input");

      std::cout << "PASS: real Rgeevx and complex Cgeevx general eig, "
                   "balance/nobalance, conjugate-pair conversion, precision, "
                   "shapes, and immutability\n";
      return 0;
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
}
