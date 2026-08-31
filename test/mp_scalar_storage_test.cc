// SPDX-License-Identifier: BSD-2-Clause

#include <cassert>
#include <cstddef>
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

static_assert (
  std::is_same_v<MpfrScalarStorage::NativeScalar, mpfrxx::mpfr_class>);
static_assert (
  std::is_same_v<decltype (Rlamch_mpfr ("E")),
                 MpfrScalarStorage::NativeScalar>);
static_assert (std::is_nothrow_move_constructible_v<MpfrScalarStorage>);
static_assert (std::is_nothrow_move_assignable_v<MpfrScalarStorage>);

namespace
{

void
test_basic_ownership ()
{
  MpfrScalarStorage a ("0.125", 128);
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
  assert (precision == 128);

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
  test_basic_ownership ();
  test_precision_and_parsing ();
  test_double_construction_and_special_values ();
  test_constructor_rounding_is_explicit ();
  test_contiguous_container_and_stress ();
  return 0;
}
