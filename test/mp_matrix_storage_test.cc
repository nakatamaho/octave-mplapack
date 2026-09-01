// SPDX-License-Identifier: BSD-2-Clause

#include "mp_matrix_storage.h"

#include <cstdint>
#include <iostream>
#include <limits>
#include <stdexcept>
#include <string>
#include <type_traits>
#include <utility>
#include <vector>

#include <mpblas_mpfr.h>
#include <mplapack_mpfr.h>

namespace
{

using Matrix = octave_mplapack::MpfrMatrixStorage;

static_assert (std::is_same_v<Matrix::NativeScalar, mpfrxx::mpfr_class>);
static_assert (std::is_same_v<Matrix::NativeScalar, mpfr_class>);
static_assert (std::is_same_v<decltype (std::declval<Matrix&> ().data ()),
                              mpfr_class *>);
static_assert (
  std::is_same_v<decltype (std::declval<const Matrix&> ().data ()),
                 const mpfr_class *>);
static_assert (std::is_same_v<Matrix::MplapackInteger, mplapackint>);
static_assert (std::is_same_v<mplapackint, std::int64_t>);

void
require (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

void
verify_mplapack_arguments (Matrix& matrix)
{
  mpfr_class *values = matrix.data ();
  mplapackint leading_dimension = matrix.leading_dimension ();
  if (matrix.numel () != 0)
    require (values != nullptr, "nonempty data pointer is null");
  require (leading_dimension
           == static_cast<mplapackint> (
                matrix.rows () == 0 ? 1 : matrix.rows ()),
           "leading dimension mismatch");
}

void
test_layout_and_precision ()
{
  const std::vector<std::string> values {
    "11", "21", "12", "22", "13", "23"
  };
  Matrix matrix (2, 3, 333, values);
  require (matrix.rows () == 2 && matrix.columns () == 3,
           "2x3 shape mismatch");
  require (matrix.numel () == 6, "2x3 element count mismatch");
  require (matrix.leading_dimension () == 2,
           "2x3 leading dimension mismatch");
  require (matrix.all_elements_have_uniform_precision (),
           "matrix element precision is not uniform");
  for (std::size_t index = 0; index < values.size (); ++index)
    {
      const std::size_t row = index % 2;
      const std::size_t column = index / 2;
      require (matrix.element_exactly_equal_text (row, column,
                                                  values[index]),
               "column-major layout mismatch");
    }
  verify_mplapack_arguments (matrix);
}

void
test_copy_move_and_work_buffer ()
{
  Matrix original (2, 2, 256,
                   std::vector<std::string> {"1", "3", "2", "4"});
  Matrix copy (original);
  require (copy.data () != original.data (),
           "deep copy shares a nonempty data buffer");
  require (copy.element_exactly_equal (1, 1, original, 1, 1),
           "deep copy changed an element");

  mpfr_set_si (copy.at (0, 0).mpfr_data (), 99, MPFR_RNDN);
  require (copy.element_exactly_equal_text (0, 0, "99"),
           "work-copy mutation failed");
  require (original.element_exactly_equal_text (0, 0, "1"),
           "work-copy mutation changed the original");

  Matrix assigned (1, 1, 32, std::vector<std::string> {"-1"});
  assigned = original;
  require (assigned.precision_bits () == 256,
           "copy assignment did not preserve precision");
  require (assigned.data () != original.data (),
           "copy assignment shares a nonempty data buffer");

  Matrix moved (std::move (copy));
  require (moved.rows () == 2 && moved.columns () == 2,
           "move construction changed shape");
  require (moved.element_exactly_equal_text (0, 0, "99"),
           "move construction changed values");

  Matrix move_assigned (0, 0, 128);
  move_assigned = std::move (moved);
  require (move_assigned.precision_bits () == 256,
           "move assignment changed precision");
  require (move_assigned.element_exactly_equal_text (0, 0, "99"),
           "move assignment changed values");
}

void
test_empty_and_dimension_checks ()
{
  Matrix empty_00 (0, 0, 128);
  Matrix empty_03 (0, 3, 128);
  Matrix empty_40 (4, 0, 128);
  require (empty_00.numel () == 0 && empty_00.leading_dimension () == 1,
           "0x0 metadata mismatch");
  require (empty_03.numel () == 0 && empty_03.rows () == 0
           && empty_03.columns () == 3
           && empty_03.leading_dimension () == 1,
           "0x3 metadata mismatch");
  require (empty_40.numel () == 0 && empty_40.rows () == 4
           && empty_40.columns () == 0
           && empty_40.leading_dimension () == 4,
           "4x0 metadata mismatch");

  Matrix empty_copy (empty_03);
  Matrix empty_move (std::move (empty_copy));
  require (empty_move.rows () == 0 && empty_move.columns () == 3,
           "empty copy/move changed shape");

  bool overflow_detected = false;
  try
    {
      Matrix::checked_element_count (
        std::numeric_limits<std::size_t>::max (), 2);
    }
  catch (const std::overflow_error&)
    {
      overflow_detected = true;
    }
  require (overflow_detected, "element-count overflow was not detected");

  if (std::numeric_limits<std::size_t>::max ()
      > static_cast<std::size_t> (
          std::numeric_limits<mplapackint>::max ()))
    {
      bool dimension_overflow_detected = false;
      try
        {
          Matrix::checked_mplapack_dimension (
            static_cast<std::size_t> (
              std::numeric_limits<mplapackint>::max ()) + 1);
        }
      catch (const std::overflow_error&)
        {
          dimension_overflow_detected = true;
        }
      require (dimension_overflow_detected,
               "MPLAPACK dimension overflow was not detected");
    }
}

void
test_precision_matrix ()
{
  for (mpfr_prec_t precision : {32, 128, 256, 333, 512, 1024})
    {
      Matrix matrix (3, 2, precision,
                     std::vector<double> {0.1, 0.125, -2.25,
                                          1.5, 0.0, -0.0});
      require (matrix.precision_bits () == precision,
               "matrix precision metadata mismatch");
      require (matrix.all_elements_have_uniform_precision (),
               "matrix contains default-precision elements");
      if (precision >= std::numeric_limits<double>::digits)
        require (matrix.element_exactly_equal_double (0, 0, 0.1),
                 "double matrix did not preserve binary64 source value");
      require (matrix.element_exactly_equal_double (1, 0, 0.125),
               "dyadic double matrix source value changed");
    }
}

void
test_transactional_error_cleanup ()
{
  bool invalid_text_detected = false;
  try
    {
      Matrix bad (2, 2, 512,
                  std::vector<std::string> {"1", "2", "bad", "4"});
      (void) bad;
    }
  catch (const std::invalid_argument&)
    {
      invalid_text_detected = true;
    }
  require (invalid_text_detected, "malformed matrix text was accepted");
}

void
test_container_reallocation ()
{
  std::vector<Matrix::NativeScalar> values;
  for (int index = 0; index < 1000; ++index)
    {
      auto value = Matrix::NativeScalar::with_precision (333);
      mpfr_set_si (value.mpfr_data (), index, MPFR_RNDN);
      values.push_back (std::move (value));
    }
  for (int index = 0; index < 1000; ++index)
    {
      require (values[static_cast<std::size_t> (index)].precision () == 333,
               "container reallocation changed element precision");
      require (mpfr_cmp_si (
                 values[static_cast<std::size_t> (index)].mpfr_data (),
                 index) == 0,
               "container reallocation changed element value");
    }
}

void
test_smoke_and_stress ()
{
  const std::vector<double> large_values (64 * 64, 0.125);
  Matrix large (64, 64, 512, large_values);
  Matrix large_copy (large);
  require (large_copy.data () != large.data (),
           "64x64 copy shares its data buffer");
  require (large_copy.all_elements_have_uniform_precision (),
           "64x64 copy lost uniform precision");

  for (std::size_t iteration = 0; iteration < 1000; ++iteration)
    {
      const std::size_t rows = iteration % 7;
      const std::size_t columns = (iteration * 3) % 9;
      const mpfr_prec_t precision
        = static_cast<mpfr_prec_t> (32 + (iteration % 5) * 64);
      Matrix matrix (rows, columns, precision);
      require (matrix.rows () == rows && matrix.columns () == columns,
               "lifecycle stress changed shape");
      require (matrix.all_elements_have_uniform_precision (),
               "lifecycle stress lost uniform precision");
    }
}

} // namespace

int
main ()
{
  try
    {
      test_layout_and_precision ();
      test_copy_move_and_work_buffer ();
      test_empty_and_dimension_checks ();
      test_precision_matrix ();
      test_transactional_error_cleanup ();
      test_container_reallocation ();
      test_smoke_and_stress ();
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }

  std::cout
    << "PASS: native matrix column-major/REAL* compatibility, "
       "uniform precision, deep copy, empty shapes, and 1000-matrix stress\n";
  return 0;
}
