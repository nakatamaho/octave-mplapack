// SPDX-License-Identifier: BSD-2-Clause

#include <cassert>
#include <cstddef>
#include <stdexcept>
#include <string>
#include <type_traits>
#include <utility>
#include <vector>

#include <mplapack_mpfr.h>

#include "mp_scalar_storage.h"

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
  test_contiguous_container_and_stress ();
  return 0;
}
