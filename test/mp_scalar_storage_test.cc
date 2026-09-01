// SPDX-License-Identifier: BSD-2-Clause

#include <cassert>
#include <cmath>
#include <cstddef>
#include <cstdint>
#include <cstring>
#include <limits>
#include <stdexcept>
#include <string>
#include <type_traits>
#include <utility>
#include <vector>

#include <mplapack_mpfr.h>

#include "mp_scalar_storage.h"
#include "mp_precision.h"

using octave_mplapack::MpfrScalarStorage;
using octave_mplapack::bits_for_decimal_digits;
using octave_mplapack::decimal_digits_for_bits;

static_assert (
  std::is_same_v<MpfrScalarStorage::NativeScalar, mpfrxx::mpfr_class>);
static_assert (
  std::is_same_v<decltype (Rlamch_mpfr ("E")),
                 MpfrScalarStorage::NativeScalar>);
static_assert (std::is_nothrow_move_constructible_v<MpfrScalarStorage>);
static_assert (std::is_nothrow_move_assignable_v<MpfrScalarStorage>);

namespace
{

std::uint64_t
double_bits (double value)
{
  std::uint64_t bits = 0;
  static_assert (sizeof (bits) == sizeof (value));
  std::memcpy (&bits, &value, sizeof (bits));
  return bits;
}

void
test_precision_configuration_and_conversion ()
{
  const mpfr_prec_t mpfr_default = mpfr_get_default_prec ();
  assert (octave_mplapack::initial_default_precision_bits == 512);
  assert (octave_mplapack::default_precision_bits () == 512);
  assert (decimal_digits_for_bits (512) == 154);

  struct Conversion
  {
    octave_mplapack::precision_count_t digits;
    mpfr_prec_t bits;
  };

  const Conversion conversions[] = {
    {1, 4}, {10, 34}, {38, 127}, {100, 333}, {1000, 3322}
  };
  for (const auto& conversion : conversions)
    {
      assert (bits_for_decimal_digits (conversion.digits)
              == conversion.bits);
      assert (decimal_digits_for_bits (conversion.bits)
              == conversion.digits);
    }

  assert (decimal_digits_for_bits (128) == 38);
  assert (decimal_digits_for_bits (332) == 99);
  assert (decimal_digits_for_bits (333) == 100);

  octave_mplapack::set_default_precision_bits (128);
  assert (octave_mplapack::default_precision_bits () == 128);

  bool invalid_rejected = false;
  try
    {
      octave_mplapack::set_default_precision_bits (0);
    }
  catch (const std::invalid_argument&)
    {
      invalid_rejected = true;
    }
  assert (invalid_rejected);
  assert (octave_mplapack::default_precision_bits () == 128);

  bool overflow_rejected = false;
  try
    {
      bits_for_decimal_digits (
        std::numeric_limits<octave_mplapack::precision_count_t>::max ());
    }
  catch (const std::overflow_error&)
    {
      overflow_rejected = true;
    }
  assert (overflow_rejected);
  assert (octave_mplapack::default_precision_bits () == 128);

  octave_mplapack::set_default_precision_bits (512);
  assert (mpfr_get_default_prec () == mpfr_default);
}

void
test_basic_ownership ()
{
  MpfrScalarStorage a ("0.125", 128);
  const mpfr_prec_t initialized_mpfr_default = mpfr_get_default_prec ();
  assert (a.precision_bits () == 128);
  assert (a.exactly_equal_string ("0.125"));

  MpfrScalarStorage copied (a);
  assert (copied.precision_bits () == 128);
  assert (copied.exactly_equal (a));

  MpfrScalarStorage assigned ("-2.25", 512);
  assigned = a;
  assert (assigned.precision_bits () == 128);
  assert (assigned.exactly_equal (a));

  assigned = assigned;
  assert (assigned.precision_bits () == 128);
  assert (assigned.exactly_equal_string ("0.125"));

  MpfrScalarStorage moved (std::move (copied));
  assert (moved.precision_bits () == 128);
  assert (moved.exactly_equal_string ("0.125"));

  MpfrScalarStorage move_assigned ("1.5", 256);
  move_assigned = std::move (moved);
  assert (move_assigned.precision_bits () == 128);
  assert (move_assigned.exactly_equal_string ("0.125"));
  assert (mpfr_get_default_prec () == initialized_mpfr_default);
}

void
test_precision_and_parsing ()
{
  MpfrScalarStorage a ("0.125", 128);
  MpfrScalarStorage b ("1.5", 256);
  MpfrScalarStorage c ("-2.25", 512);
  MpfrScalarStorage decimal ("0.1", 512);

  assert (a.precision_bits () == 128);
  assert (b.precision_bits () == 256);
  assert (c.precision_bits () == 512);
  assert (decimal.precision_bits () == 512);
  assert (decimal.exactly_equal_string ("0.1"));

  bool invalid_text_rejected = false;
  try
    {
      MpfrScalarStorage invalid ("not-a-number", 128);
    }
  catch (const std::invalid_argument&)
    {
      invalid_text_rejected = true;
    }
  assert (invalid_text_rejected);

  bool invalid_precision_rejected = false;
  try
    {
      MpfrScalarStorage invalid ("1", 0);
    }
  catch (const std::invalid_argument&)
    {
      invalid_precision_rejected = true;
    }
  assert (invalid_precision_rejected);

  invalid_precision_rejected = false;
  try
    {
      MpfrScalarStorage invalid ("1", -1);
    }
  catch (const std::invalid_argument&)
    {
      invalid_precision_rejected = true;
    }
  assert (invalid_precision_rejected);

  invalid_precision_rejected = false;
  try
    {
      MpfrScalarStorage invalid ("1", MPFR_PREC_MAX + 1);
    }
  catch (const std::invalid_argument&)
    {
      invalid_precision_rejected = true;
    }
  assert (invalid_precision_rejected);
}

void
test_double_construction_and_special_values ()
{
  const mpfr_prec_t precision
    = octave_mplapack::default_precision_bits ();
  assert (precision == octave_mplapack::initial_default_precision_bits);
  assert (precision == 512);

  MpfrScalarStorage decimal_text ("0.1", precision);
  MpfrScalarStorage binary64 (0.1, precision);
  assert (! decimal_text.exactly_equal (binary64));
  assert (decimal_text.exactly_equal_string ("0.1"));
  assert (! decimal_text.exactly_equal_double (0.1));
  assert (binary64.exactly_equal_double (0.1));

  MpfrScalarStorage dyadic_text ("0.125", precision);
  MpfrScalarStorage dyadic_binary64 (0.125, precision);
  assert (dyadic_text.exactly_equal (dyadic_binary64));
  assert (dyadic_binary64.exactly_equal_double (0.125));

  MpfrScalarStorage smallest_normal (
    std::numeric_limits<double>::min (), precision);
  MpfrScalarStorage largest_finite (
    std::numeric_limits<double>::max (), precision);
  MpfrScalarStorage smallest_subnormal (
    std::numeric_limits<double>::denorm_min (), precision);
  assert (smallest_normal.exactly_equal_double (
    std::numeric_limits<double>::min ()));
  assert (largest_finite.exactly_equal_double (
    std::numeric_limits<double>::max ()));
  assert (smallest_subnormal.exactly_equal_double (
    std::numeric_limits<double>::denorm_min ()));

  MpfrScalarStorage positive_zero (0.0, precision);
  MpfrScalarStorage negative_zero (-0.0, precision);
  assert (positive_zero.is_zero () && ! positive_zero.signbit ());
  assert (negative_zero.is_zero () && negative_zero.signbit ());

  MpfrScalarStorage positive_infinity (
    std::numeric_limits<double>::infinity (), precision);
  MpfrScalarStorage negative_infinity (
    -std::numeric_limits<double>::infinity (), precision);
  MpfrScalarStorage not_a_number (
    std::numeric_limits<double>::quiet_NaN (), precision);
  assert (positive_infinity.is_infinite ()
          && ! positive_infinity.signbit ());
  assert (negative_infinity.is_infinite ()
          && negative_infinity.signbit ());
  assert (not_a_number.is_nan ());

  MpfrScalarStorage copied (negative_zero);
  assert (copied.is_zero () && copied.signbit ());
  MpfrScalarStorage moved (std::move (positive_infinity));
  assert (moved.is_infinite () && ! moved.signbit ());
}

void
test_constructor_rounding_is_explicit ()
{
  const mpfr_rnd_t saved_rounding = mpfr_get_default_rounding_mode ();
  mpfr_set_default_rounding_mode (MPFR_RNDD);
  MpfrScalarStorage downward_text ("0.1", 128);
  MpfrScalarStorage downward_double (0.1, 128);
  mpfr_set_default_rounding_mode (MPFR_RNDU);
  MpfrScalarStorage upward_text ("0.1", 128);
  MpfrScalarStorage upward_double (0.1, 128);
  mpfr_set_default_rounding_mode (saved_rounding);

  assert (downward_text.exactly_equal (upward_text));
  assert (downward_double.exactly_equal (upward_double));
}

void
test_canonical_conversion_and_double_conversion ()
{
  MpfrScalarStorage one ("1", 512);
  MpfrScalarStorage negative_one ("-1", 512);
  MpfrScalarStorage dyadic ("0.125", 512);
  assert (one.to_canonical_string () == "1e+0");
  assert (negative_one.to_canonical_string () == "-1e+0");
  assert (dyadic.to_canonical_string () == "1.25e-1");

  const mpfr_prec_t precisions[] = {128, 256, 333, 512, 1024};
  const char *texts[] = {
    "1", "-1", "0.125", "0.1", "1.234567890123456789",
    "1e100", "1e-100"
  };
  for (const mpfr_prec_t precision : precisions)
    for (const char *text : texts)
      {
        MpfrScalarStorage original (text, precision);
        const std::string canonical = original.to_canonical_string ();
        MpfrScalarStorage reconstructed (canonical, precision);
        assert (original.exactly_equal (reconstructed));
      }

  MpfrScalarStorage positive_zero (0.0, 512);
  MpfrScalarStorage negative_zero (-0.0, 512);
  MpfrScalarStorage positive_infinity (
    std::numeric_limits<double>::infinity (), 512);
  MpfrScalarStorage negative_infinity (
    -std::numeric_limits<double>::infinity (), 512);
  MpfrScalarStorage not_a_number (
    std::numeric_limits<double>::quiet_NaN (), 512);
  assert (positive_zero.to_canonical_string () == "0");
  assert (negative_zero.to_canonical_string () == "-0");
  assert (positive_infinity.to_canonical_string () == "Inf");
  assert (negative_infinity.to_canonical_string () == "-Inf");
  assert (not_a_number.to_canonical_string () == "NaN");
  assert (double_bits (positive_zero.to_double ()) == double_bits (0.0));
  assert (double_bits (negative_zero.to_double ()) == double_bits (-0.0));
  assert (std::isinf (positive_infinity.to_double ())
          && positive_infinity.to_double () > 0.0);
  assert (std::isinf (negative_infinity.to_double ())
          && negative_infinity.to_double () < 0.0);
  assert (std::isnan (not_a_number.to_double ()));

  const double binary64_values[] = {
    0.0,
    -0.0,
    1.0,
    -1.0,
    0.5,
    0.1,
    std::numeric_limits<double>::min (),
    std::numeric_limits<double>::max (),
    std::numeric_limits<double>::denorm_min (),
    std::nextafter (1.0, 2.0)
  };
  for (const double value : binary64_values)
    {
      MpfrScalarStorage stored (value, 512);
      assert (double_bits (stored.to_double ()) == double_bits (value));
    }

  MpfrScalarStorage halfway (
    "1.00000000000000011102230246251565404236316680908203125", 256);
  assert (double_bits (halfway.to_double ()) == double_bits (1.0));

  MpfrScalarStorage overflow ("1e10000", 256);
  MpfrScalarStorage underflow ("1e-10000", 256);
  MpfrScalarStorage negative_underflow ("-1e-10000", 256);
  assert (std::isinf (overflow.to_double ()));
  assert (double_bits (underflow.to_double ()) == double_bits (0.0));
  assert (double_bits (negative_underflow.to_double ())
          == double_bits (-0.0));

  const mpfr_rnd_t saved_rounding = mpfr_get_default_rounding_mode ();
  mpfr_set_default_rounding_mode (MPFR_RNDD);
  const std::string downward_text = halfway.to_canonical_string ();
  const std::uint64_t downward_double = double_bits (halfway.to_double ());
  mpfr_set_default_rounding_mode (MPFR_RNDU);
  assert (halfway.to_canonical_string () == downward_text);
  assert (double_bits (halfway.to_double ()) == downward_double);
  mpfr_set_default_rounding_mode (saved_rounding);

  MpfrScalarStorage large ("0.1", 8192);
  const std::string large_text = large.to_canonical_string ();
  MpfrScalarStorage large_round_trip (large_text, 8192);
  assert (large.exactly_equal (large_round_trip));
  assert (large.to_double () == 0.1);
}

void
test_contiguous_container_and_stress ()
{
  constexpr std::size_t iterations = 10000;
  const mpfr_prec_t precisions[] = {128, 256, 512};
  const char *texts[] = {"0.125", "1.5", "-2.25", "0.1"};

  std::vector<MpfrScalarStorage> values;
  for (std::size_t i = 0; i < iterations; ++i)
    {
      const mpfr_prec_t precision = precisions[i % 3];
      const char *text = texts[i % 4];
      values.emplace_back (text, precision);

      MpfrScalarStorage copy (values.back ());
      assert (copy.precision_bits () == precision);
      assert (copy.exactly_equal (values.back ()));
      const std::string canonical = copy.to_canonical_string ();
      MpfrScalarStorage reconstructed (canonical, precision);
      assert (copy.exactly_equal (reconstructed));
      static_cast<void> (copy.to_double ());

      if ((i % 17) == 0)
        {
          MpfrScalarStorage moved (std::move (copy));
          assert (moved.precision_bits () == precision);
          assert (moved.exactly_equal_string (text));
        }
    }

  assert (values.size () == iterations);
  for (std::size_t i = 0; i < values.size (); i += 97)
    {
      assert (values[i].precision_bits () == precisions[i % 3]);
      assert (values[i].exactly_equal_string (texts[i % 4]));
    }

  std::vector<MpfrScalarStorage> copied = values;
  assert (copied.size () == values.size ());
  values.clear ();
  assert (copied.front ().exactly_equal_string ("0.125"));
}

} // namespace

int
main ()
{
  test_precision_configuration_and_conversion ();
  test_basic_ownership ();
  test_precision_and_parsing ();
  test_double_construction_and_special_values ();
  test_constructor_rounding_is_explicit ();
  test_canonical_conversion_and_double_conversion ();
  test_contiguous_container_and_stress ();
  return 0;
}
