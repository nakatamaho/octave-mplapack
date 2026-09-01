// SPDX-License-Identifier: BSD-2-Clause

#include <cassert>
#include <cmath>
#include <cstddef>
#include <limits>
#include <string>

#include "mp_scalar_storage.h"

using octave_mplapack::MpfrScalarStorage;

namespace
{

class DirectMpfrValue
{
public:
  explicit DirectMpfrValue (mpfr_prec_t precision)
  {
    mpfr_init2 (m_value, precision);
  }

  ~DirectMpfrValue ()
  {
    mpfr_clear (m_value);
  }

  DirectMpfrValue (const DirectMpfrValue&) = delete;
  DirectMpfrValue& operator= (const DirectMpfrValue&) = delete;

  mpfr_ptr get () noexcept
  {
    return m_value;
  }

  mpfr_srcptr get () const noexcept
  {
    return m_value;
  }

private:
  mpfr_t m_value;
};

enum class Operation
{
  add,
  subtract,
  multiply,
  divide
};

bool
same_native_value (mpfr_srcptr lhs, mpfr_srcptr rhs)
{
  if (mpfr_nan_p (lhs) || mpfr_nan_p (rhs))
    return mpfr_nan_p (lhs) && mpfr_nan_p (rhs);
  if (mpfr_zero_p (lhs) || mpfr_zero_p (rhs))
    return (mpfr_zero_p (lhs) && mpfr_zero_p (rhs)
            && mpfr_signbit (lhs) == mpfr_signbit (rhs));
  return mpfr_equal_p (lhs, rhs) != 0;
}

MpfrScalarStorage
project_operation (Operation operation, const MpfrScalarStorage& lhs,
                   const MpfrScalarStorage& rhs)
{
  switch (operation)
    {
    case Operation::add:
      return lhs.add (rhs);
    case Operation::subtract:
      return lhs.subtract (rhs);
    case Operation::multiply:
      return lhs.multiply (rhs);
    case Operation::divide:
      return lhs.divide (rhs);
    }
  assert (false);
  return lhs;
}

void
direct_operation (Operation operation, mpfr_ptr result, mpfr_srcptr lhs,
                  mpfr_srcptr rhs)
{
  switch (operation)
    {
    case Operation::add:
      mpfr_add (result, lhs, rhs, MPFR_RNDN);
      return;
    case Operation::subtract:
      mpfr_sub (result, lhs, rhs, MPFR_RNDN);
      return;
    case Operation::multiply:
      mpfr_mul (result, lhs, rhs, MPFR_RNDN);
      return;
    case Operation::divide:
      mpfr_div (result, lhs, rhs, MPFR_RNDN);
      return;
    }
  assert (false);
}

void
compare_text_operation (Operation operation, const char *lhs_text,
                        mpfr_prec_t lhs_precision, const char *rhs_text,
                        mpfr_prec_t rhs_precision)
{
  MpfrScalarStorage lhs (lhs_text, lhs_precision);
  MpfrScalarStorage rhs (rhs_text, rhs_precision);
  MpfrScalarStorage result = project_operation (operation, lhs, rhs);
  const mpfr_prec_t result_precision
    = lhs_precision > rhs_precision ? lhs_precision : rhs_precision;
  assert (result.precision_bits () == result_precision);

  DirectMpfrValue direct_lhs (lhs_precision);
  DirectMpfrValue direct_rhs (rhs_precision);
  DirectMpfrValue direct_result (result_precision);
  assert (mpfr_set_str (direct_lhs.get (), lhs_text, 10, MPFR_RNDN) == 0);
  assert (mpfr_set_str (direct_rhs.get (), rhs_text, 10, MPFR_RNDN) == 0);
  direct_operation (operation, direct_result.get (), direct_lhs.get (),
                    direct_rhs.get ());
  assert (same_native_value (
    result.native_value ().mpfr_data (), direct_result.get ()));
  assert (lhs.precision_bits () == lhs_precision);
  assert (rhs.precision_bits () == rhs_precision);
}

void
compare_double_operation (Operation operation, const char *mp_text,
                          double binary64, mpfr_prec_t precision,
                          bool double_on_left)
{
  MpfrScalarStorage mp_operand (mp_text, precision);
  MpfrScalarStorage double_operand (binary64, precision);
  MpfrScalarStorage result
    = double_on_left
      ? project_operation (operation, double_operand, mp_operand)
      : project_operation (operation, mp_operand, double_operand);
  assert (result.precision_bits () == precision);

  DirectMpfrValue direct_mp (precision);
  DirectMpfrValue direct_double (precision);
  DirectMpfrValue direct_result (precision);
  assert (mpfr_set_str (direct_mp.get (), mp_text, 10, MPFR_RNDN) == 0);
  mpfr_set_d (direct_double.get (), binary64, MPFR_RNDN);
  if (double_on_left)
    direct_operation (operation, direct_result.get (), direct_double.get (),
                      direct_mp.get ());
  else
    direct_operation (operation, direct_result.get (), direct_mp.get (),
                      direct_double.get ());
  assert (same_native_value (
    result.native_value ().mpfr_data (), direct_result.get ()));
}

void
test_exact_and_mixed_precision ()
{
  compare_text_operation (Operation::add, "0.125", 128, "0.25", 256);
  compare_text_operation (Operation::subtract, "0.5", 256, "0.125", 128);
  compare_text_operation (Operation::multiply, "0.125", 128, "0.5", 512);
  compare_text_operation (Operation::divide, "0.5", 512, "0.125", 256);

  const mpfr_prec_t precisions[] = {2, 8, 32, 128, 256, 333, 512, 1024};
  for (const mpfr_prec_t lhs_precision : precisions)
    for (const mpfr_prec_t rhs_precision : precisions)
      {
        compare_text_operation (Operation::add, "0.1", lhs_precision,
                                "0.2", rhs_precision);
        compare_text_operation (Operation::subtract, "0.1", lhs_precision,
                                "0.2", rhs_precision);
        compare_text_operation (Operation::multiply, "0.1", lhs_precision,
                                "0.2", rhs_precision);
        compare_text_operation (Operation::divide, "0.1", lhs_precision,
                                "0.2", rhs_precision);
      }
}

void
test_rounding_and_global_independence ()
{
  compare_text_operation (Operation::add, "1", 2, "0.25", 2);
  MpfrScalarStorage lhs ("1", 2);
  MpfrScalarStorage rhs ("0.25", 2);
  const MpfrScalarStorage tied = lhs.add (rhs);
  assert (tied.exactly_equal_string ("1"));

  const mpfr_rnd_t saved_rounding = mpfr_get_default_rounding_mode ();
  mpfr_set_default_rounding_mode (MPFR_RNDD);
  const MpfrScalarStorage downward = lhs.divide (MpfrScalarStorage ("3", 2));
  mpfr_set_default_rounding_mode (MPFR_RNDU);
  const MpfrScalarStorage upward = lhs.divide (MpfrScalarStorage ("3", 2));
  mpfr_set_default_rounding_mode (saved_rounding);
  assert (downward.exactly_equal (upward));
}

void
test_double_temporaries ()
{
  const mpfr_prec_t precisions[] = {2, 8, 32, 128, 256, 333, 512, 1024};
  for (const mpfr_prec_t precision : precisions)
    for (const Operation operation : {Operation::add, Operation::subtract,
                                      Operation::multiply,
                                      Operation::divide})
      {
        compare_double_operation (operation, "1.25", 0.1, precision,
                                  false);
        compare_double_operation (operation, "1.25", 0.1, precision,
                                  true);
      }

  MpfrScalarStorage base ("1", 128);
  assert (! base.add (MpfrScalarStorage ("0.1", 128)).exactly_equal (
    base.add (MpfrScalarStorage (0.1, 128))));
  assert (base.add (MpfrScalarStorage ("0.125", 128)).exactly_equal (
    base.add (MpfrScalarStorage (0.125, 128))));
}

void
test_special_values_and_negation ()
{
  const char *values[] = {"0", "-0", "1", "-1", "Inf", "-Inf", "NaN"};
  for (const Operation operation : {Operation::add, Operation::subtract,
                                    Operation::multiply, Operation::divide})
    for (const char *lhs : values)
      for (const char *rhs : values)
        compare_text_operation (operation, lhs, 128, rhs, 256);

  MpfrScalarStorage positive_zero ("0", 128);
  MpfrScalarStorage negative_zero ("-0", 128);
  MpfrScalarStorage positive_infinity ("Inf", 128);
  MpfrScalarStorage negative_infinity ("-Inf", 128);
  MpfrScalarStorage not_a_number ("NaN", 128);
  assert (positive_zero.negate ().is_zero ());
  assert (positive_zero.negate ().signbit ());
  assert (negative_zero.negate ().is_zero ());
  assert (! negative_zero.negate ().signbit ());
  assert (positive_infinity.negate ().is_infinite ());
  assert (positive_infinity.negate ().signbit ());
  assert (negative_infinity.negate ().is_infinite ());
  assert (! negative_infinity.negate ().signbit ());
  assert (not_a_number.negate ().is_nan ());
  assert (not_a_number.negate ().precision_bits () == 128);
}

void
test_stress ()
{
  constexpr std::size_t iterations = 10000;
  const mpfr_prec_t precisions[] = {2, 8, 32, 128, 256, 333, 512, 1024};
  MpfrScalarStorage accumulator ("1", 128);
  for (std::size_t i = 0; i < iterations; ++i)
    {
      const mpfr_prec_t precision = precisions[i % 8];
      MpfrScalarStorage value ((i % 29) == 0 ? "0" : "0.125", precision);
      switch (i % 4)
        {
        case 0:
          accumulator = accumulator.add (value);
          break;
        case 1:
          accumulator = accumulator.subtract (value);
          break;
        case 2:
          accumulator = accumulator.multiply (value);
          break;
        default:
          accumulator = accumulator.divide (value);
          break;
        }
      MpfrScalarStorage binary64 (0.1, accumulator.precision_bits ());
      accumulator = accumulator.add (binary64).negate ().negate ();
      assert (accumulator.precision_bits () >= precision);
    }
}

} // namespace

int
main ()
{
  test_exact_and_mixed_precision ();
  test_rounding_and_global_independence ();
  test_double_temporaries ();
  test_special_values_and_negation ();
  test_stress ();
  return 0;
}
