// SPDX-License-Identifier: BSD-2-Clause

#include "mp_lapack.h"

#include <stdexcept>
#include <iostream>
#include <string>
#include <vector>

#include <mpfrxx_mkII.h>

namespace
{

using octave_mplapack::MpfrMatrixStorage;
using Real = mpfrxx::mpfr_class;

void
check (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

bool
same (const MpfrMatrixStorage& lhs, const MpfrMatrixStorage& rhs)
{
  if (lhs.rows () != rhs.rows () || lhs.columns () != rhs.columns ()
      || lhs.precision_bits () != rhs.precision_bits ())
    return false;
  for (std::size_t column = 0; column < lhs.columns (); ++column)
    for (std::size_t row = 0; row < lhs.rows (); ++row)
      if (! lhs.element_exactly_equal (row, column, rhs, row, column))
        return false;
  return true;
}

void
check_text (const MpfrMatrixStorage& value,
            const std::vector<std::string>& expected)
{
  check (value.numel () == expected.size (), "unexpected result element count");
  for (std::size_t index = 0; index < expected.size (); ++index)
    {
      Real expected_value = Real::with_precision (value.precision_bits ());
      check (mpfr_set_str (expected_value.mpfr_data (), expected[index].c_str (),
                           10, MPFR_RNDN) == 0,
             "invalid expected test text");
      check (mpfr_equal_p (value.data ()[index].mpfr_data (),
                           expected_value.mpfr_data ()) != 0,
             "unexpected solve value");
    }
}

void
set_power_two_plus_one (Real& value, mpfr_exp_t exponent)
{
  mpfr_set_ui (value.mpfr_data (), 1, MPFR_RNDN);
  Real epsilon = Real::with_precision (value.precision ());
  mpfr_set_ui (epsilon.mpfr_data (), 1, MPFR_RNDN);
  mpfr_mul_2si (epsilon.mpfr_data (), epsilon.mpfr_data (), exponent,
                MPFR_RNDN);
  mpfr_add (value.mpfr_data (), value.mpfr_data (), epsilon.mpfr_data (),
            MPFR_RNDN);
}

void
test_basic_and_multiple_rhs ()
{
  const MpfrMatrixStorage a (2, 2, 256,
                             std::vector<std::string> {"3", "1", "1", "2"});
  const MpfrMatrixStorage b (2, 2, 256,
                             std::vector<std::string> {"9", "8", "7", "9"});
  const auto original_a = a;
  const auto original_b = b;
  const auto x = octave_mplapack::mplapack_mpfr_matrix_solve (a, b);
  check (x.rows () == 2 && x.columns () == 2, "multiple RHS shape mismatch");
  check (x.precision_bits () == 256, "multiple RHS precision mismatch");
  check_text (x, {"2", "3", "1", "4"});
  check (same (a, original_a) && same (b, original_b),
         "Rgesv modified public input storage");
}

void
test_pivoting ()
{
  const MpfrMatrixStorage a (2, 2, 256,
                             std::vector<std::string> {"0", "1", "1", "1"});
  const MpfrMatrixStorage b (2, 1, 256,
                             std::vector<std::string> {"2", "3"});
  const auto x = octave_mplapack::mplapack_mpfr_matrix_solve (a, b);
  check_text (x, {"1", "2"});
}

MpfrMatrixStorage
precision_sensitive_system (mpfr_prec_t precision, mpfr_exp_t exponent)
{
  MpfrMatrixStorage matrix (2, 2, precision);
  mpfr_set_ui (matrix.at (0, 0).mpfr_data (), 1, MPFR_RNDN);
  mpfr_set_ui (matrix.at (1, 0).mpfr_data (), 1, MPFR_RNDN);
  mpfr_set_ui (matrix.at (0, 1).mpfr_data (), 1, MPFR_RNDN);
  set_power_two_plus_one (matrix.at (1, 1), exponent);
  return matrix;
}

void
test_precision_and_scope ()
{
  const auto previous = mpfrxx::default_precision_bits ();
  mpfrxx::set_default_precision_bits (128);
  const auto a = precision_sensitive_system (1024, -700);
  MpfrMatrixStorage b (2, 1, 1024);
  mpfr_set_ui (b.at (0, 0).mpfr_data (), 2, MPFR_RNDN);
  Real epsilon = Real::with_precision (1024);
  mpfr_set_ui (epsilon.mpfr_data (), 1, MPFR_RNDN);
  mpfr_mul_2si (epsilon.mpfr_data (), epsilon.mpfr_data (), -700,
                MPFR_RNDN);
  mpfr_add (b.at (1, 0).mpfr_data (), b.at (0, 0).mpfr_data (),
            epsilon.mpfr_data (), MPFR_RNDN);
  const auto x = octave_mplapack::mplapack_mpfr_matrix_solve (a, b);
  check (x.precision_bits () == 1024, "precision-sensitive result precision");
  check_text (x, {"1", "1"});
  check (mpfrxx::default_precision_bits () == 128,
         "Rgesv precision scope leaked");

  const auto a2048 = precision_sensitive_system (2048, -1500);
  MpfrMatrixStorage b2048 (2, 1, 2048);
  mpfr_set_ui (b2048.at (0, 0).mpfr_data (), 2, MPFR_RNDN);
  Real eps2048 = Real::with_precision (2048);
  mpfr_set_ui (eps2048.mpfr_data (), 1, MPFR_RNDN);
  mpfr_mul_2si (eps2048.mpfr_data (), eps2048.mpfr_data (), -1500,
                MPFR_RNDN);
  mpfr_add (b2048.at (1, 0).mpfr_data (), b2048.at (0, 0).mpfr_data (),
            eps2048.mpfr_data (), MPFR_RNDN);
  const auto x2048 = octave_mplapack::mplapack_mpfr_matrix_solve (a2048,
                                                                   b2048);
  check (x2048.precision_bits () == 2048, "2048-bit result precision");
  check_text (x2048, {"1", "1"});
  check (mpfrxx::default_precision_bits () == 128,
         "2048-bit Rgesv precision scope leaked");
  mpfrxx::set_default_precision_bits (previous);
}

void
test_mixed_precision_and_empty ()
{
  const MpfrMatrixStorage a (2, 2, 256,
                             std::vector<std::string> {"3", "1", "1", "2"});
  const MpfrMatrixStorage b (2, 1, 1024,
                             std::vector<std::string> {"9", "8"});
  const auto x = octave_mplapack::mplapack_mpfr_matrix_solve (a, b);
  check (x.precision_bits () == 1024, "mixed solve precision mismatch");
  check_text (x, {"2", "3"});

  const MpfrMatrixStorage a_high (
    2, 2, 1024, std::vector<std::string> {"3", "1", "1", "2"});
  const MpfrMatrixStorage b_low (
    2, 1, 256, std::vector<std::string> {"9", "8"});
  const auto reverse
    = octave_mplapack::mplapack_mpfr_matrix_solve (a_high, b_low);
  check (reverse.precision_bits () == 1024,
         "reverse mixed solve precision mismatch");
  check_text (reverse, {"2", "3"});

  const MpfrMatrixStorage empty_a (0, 0, 512);
  const MpfrMatrixStorage empty_b (0, 3, 256);
  const auto empty_x
    = octave_mplapack::mplapack_mpfr_matrix_solve (empty_a, empty_b);
  check (empty_x.rows () == 0 && empty_x.columns () == 3,
         "empty solve shape mismatch");
  check (empty_x.precision_bits () == 512, "empty solve precision mismatch");
}

void
test_errors ()
{
  const MpfrMatrixStorage nonsquare (2, 1, 256);
  const MpfrMatrixStorage rhs (2, 1, 256);
  bool caught = false;
  try
    {
      octave_mplapack::mplapack_mpfr_matrix_solve (nonsquare, rhs);
    }
  catch (const std::invalid_argument&)
    {
      caught = true;
    }
  check (caught, "non-square solve did not fail");

  const MpfrMatrixStorage singular (2, 2, 256,
                                    std::vector<std::string> {"1", "2", "2", "4"});
  caught = false;
  try
    {
      octave_mplapack::mplapack_mpfr_matrix_solve (singular, rhs);
    }
  catch (const octave_mplapack::MpfrRgesvError& error)
    {
      caught = error.kind ()
               == octave_mplapack::MpfrRgesvError::Kind::singular;
    }
  check (caught, "singular solve did not report Rgesv failure");
}

void
test_precision_contract_mismatch ()
{
  const auto previous = mpfrxx::default_precision_bits ();
  mpfrxx::set_default_precision_bits (128);
  const MpfrMatrixStorage a (1, 1, 256);
  const MpfrMatrixStorage b (1, 1, 256);
  bool caught = false;
  try
    {
      octave_mplapack::require_mplapack_mpfr_solve_precision_contract (
        256, a, b);
    }
  catch (const std::runtime_error& exception)
    {
      caught = std::string (exception.what ()).find ("precision contract")
               != std::string::npos;
    }
  check (caught, "precision contract mismatch was not rejected");
  check (mpfrxx::default_precision_bits () == 128,
         "precision contract checker modified TLS");
  mpfrxx::set_default_precision_bits (previous);
}

} // namespace

int
main ()
{
  try
    {
      test_basic_and_multiple_rhs ();
      test_pivoting ();
      test_precision_and_scope ();
      test_mixed_precision_and_empty ();
      test_errors ();
      test_precision_contract_mismatch ();
      return 0;
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
}
