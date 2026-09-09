// SPDX-License-Identifier: BSD-2-Clause

#include "mp_svd.h"

#include <algorithm>
#include <complex>
#include <cstdlib>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

#include <mpc.h>
#include <mpfr.h>

#include "mp_complex_precision.h"
#include "mp_norm.h"
#include "mp_precision.h"

namespace
{

using octave_mplapack::MpfrComplexMatrixStorage;
using octave_mplapack::MpfrMatrixStorage;

void
require (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

void
require_real_shape (const MpfrMatrixStorage& value, std::size_t rows,
                    std::size_t columns, mpfr_prec_t precision)
{
  require (value.rows () == rows && value.columns () == columns,
           (std::string ("unexpected real SVD shape: got ")
            + std::to_string (value.rows ()) + "x"
            + std::to_string (value.columns ()) + ", expected "
            + std::to_string (rows) + "x" + std::to_string (columns)).c_str ());
  require (value.precision_bits () == precision
           && value.all_elements_have_uniform_precision (),
           "real SVD precision contract failed");
}

void
require_complex_shape (const MpfrComplexMatrixStorage& value,
                       std::size_t rows, std::size_t columns,
                       mpfr_prec_t precision)
{
  require (value.rows () == rows && value.columns () == columns,
           (std::string ("unexpected complex SVD shape: got ")
            + std::to_string (value.rows ()) + "x"
            + std::to_string (value.columns ()) + ", expected "
            + std::to_string (rows) + "x" + std::to_string (columns)).c_str ());
  require (value.precision_bits () == precision
           && value.all_elements_have_uniform_precision (),
           "complex SVD precision contract failed");
}

void
require_nonnegative_singular_values (const MpfrMatrixStorage& value)
{
  for (std::size_t index = 0; index < value.numel (); ++index)
    require (mpfr_sgn (value.data ()[index].mpfr_data ()) >= 0,
             "SVD singular value is negative");
}

void
test_real ()
{
  const mpfr_prec_t precision = 512;
  const MpfrMatrixStorage input (3, 2, precision,
                                 std::vector<std::string> {
                                   "1", "3", "5", "2", "4", "6"
                                 });
  const auto original = input;
  const auto full = octave_mplapack::mplapack_mpfr_matrix_svd (input, false);
  require_real_shape (full.u, 3, 3, precision);
  require_real_shape (full.s, 3, 2, precision);
  require_real_shape (full.v, 2, 2, precision);
  require_nonnegative_singular_values (full.s);

  const auto economy =
    octave_mplapack::mplapack_mpfr_matrix_svd (input, true);
  require_real_shape (economy.u, 3, 2, precision);
  require_real_shape (economy.s, 2, 2, precision);
  require_real_shape (economy.v, 2, 2, precision);
  require_nonnegative_singular_values (economy.s);
  require (input.element_exactly_equal (0, 0, original, 0, 0),
           "real SVD changed its input");
  require (input.element_exactly_equal (2, 1, original, 2, 1),
           "real SVD changed its input tail");

  const auto values = octave_mplapack::mplapack_mpfr_singular_values (input);
  require_real_shape (values, 2, 1, precision);
  require_nonnegative_singular_values (values);
}

void
test_complex ()
{
  const mpfr_prec_t precision = 512;
  const MpfrComplexMatrixStorage input (2, 3, precision,
                                        std::vector<std::string> {
                                          "(1,1)", "(3,-2)", "(2,-1)",
                                          "(4,2)", "(5,0)", "(6,3)"
                                        });
  const auto full = octave_mplapack::mplapack_mpc_matrix_svd (input, false);
  require_complex_shape (full.u, 2, 2, precision);
  require_real_shape (full.s, 2, 3, precision);
  require_complex_shape (full.v, 3, 3, precision);
  require_nonnegative_singular_values (full.s);

  const auto economy =
    octave_mplapack::mplapack_mpc_matrix_svd (input, true);
  require_complex_shape (economy.u, 2, 2, precision);
  require_real_shape (economy.s, 2, 2, precision);
  require_complex_shape (economy.v, 3, 2, precision);

  const auto values = octave_mplapack::mplapack_mpc_singular_values (input);
  require_real_shape (values, 2, 1, precision);
  require_nonnegative_singular_values (values);
}

void
test_shapes_and_precision ()
{
  const MpfrMatrixStorage empty (0, 3, 1024);
  const auto full = octave_mplapack::mplapack_mpfr_matrix_svd (empty, false);
  require_real_shape (full.u, 0, 0, 1024);
  require_real_shape (full.s, 0, 3, 1024);
  require_real_shape (full.v, 3, 3, 1024);
  const auto economy = octave_mplapack::mplapack_mpfr_matrix_svd (empty, true);
  require_real_shape (economy.u, 0, 0, 1024);
  require_real_shape (economy.s, 0, 0, 1024);
  require_real_shape (economy.v, 3, 0, 1024);

  const MpfrMatrixStorage high_precision (2, 2, 2048,
                                           std::vector<std::string> {
                                             "1e-1500", "0", "0", "1"
                                           });
  const auto values =
    octave_mplapack::mplapack_mpfr_singular_values (high_precision);
  require_real_shape (values, 2, 1, 2048);
  require_nonnegative_singular_values (values);

  const mpfr_prec_t ambient = mpfrxx::default_precision_bits ();
  mpfrxx::set_default_precision_bits (128);
  (void) octave_mplapack::mplapack_mpfr_matrix_svd (high_precision, true);
  require (mpfrxx::default_precision_bits () == 128,
           "real SVD did not restore ambient precision");
  mpfrxx::set_default_precision_bits (ambient);
}

} // namespace

int
main ()
{
  try
    {
      test_real ();
      test_complex ();
      test_shapes_and_precision ();
      std::cout << "PASS: MPLAPACK MPFR/MPC SVD tests\n";
      return EXIT_SUCCESS;
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return EXIT_FAILURE;
    }
}
