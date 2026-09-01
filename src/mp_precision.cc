// SPDX-License-Identifier: BSD-2-Clause

#include "mp_precision.h"

#include <atomic>
#include <cstdint>
#include <stdexcept>

#include <mplapack_gmpfrxx_mkII_config.h>
#include <mpfrxx_mkII.h>

namespace octave_mplapack
{

namespace
{

std::atomic<mpfr_prec_t> current_default_precision_bits {
  initial_default_precision_bits
};

class MpfrIntervalValue
{
public:
  explicit MpfrIntervalValue (mpfr_prec_t precision_bits)
  {
    mpfr_init2 (m_value, precision_bits);
  }

  ~MpfrIntervalValue ()
  {
    mpfr_clear (m_value);
  }

  MpfrIntervalValue (const MpfrIntervalValue&) = delete;
  MpfrIntervalValue& operator= (const MpfrIntervalValue&) = delete;

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

void
require_valid_precision (mpfr_prec_t precision_bits)
{
  if (precision_bits < MPFR_PREC_MIN || precision_bits > MPFR_PREC_MAX)
    throw std::invalid_argument ("precision is outside the MPFR range");
}

template <typename ComputeBounds, typename ExtractInteger>
precision_count_t
certified_integer_conversion (ComputeBounds compute_bounds,
                              ExtractInteger extract_integer)
{
  // The input is at most 64 bits.  Directed MPFR bounds certify the result;
  // increasing working precision is only needed when an integer boundary is
  // still enclosed.  Failure is reported rather than returning an unproven
  // rounded value.
  for (mpfr_prec_t working_precision = 128;
       working_precision <= 16384;
       working_precision *= 2)
    {
      MpfrIntervalValue lower (working_precision);
      MpfrIntervalValue upper (working_precision);
      compute_bounds (lower.get (), upper.get (), working_precision);

      const precision_count_t lower_integer = extract_integer (lower.get ());
      const precision_count_t upper_integer = extract_integer (upper.get ());
      if (lower_integer == upper_integer)
        return lower_integer;
    }

  throw std::runtime_error ("unable to certify precision conversion");
}

} // namespace

mpfr_prec_t
default_precision_bits () noexcept
{
  return current_default_precision_bits.load (std::memory_order_relaxed);
}

void
set_default_precision_bits (mpfr_prec_t precision_bits)
{
  require_valid_precision (precision_bits);
  mpfrxx::set_default_precision_bits (precision_bits);
  if (mpfrxx::default_precision_bits () != precision_bits)
    throw std::runtime_error (
      "failed to synchronize the current-thread MPFR default precision");
  current_default_precision_bits.store (precision_bits,
                                        std::memory_order_relaxed);
}

void
synchronize_current_thread_precision ()
{
  const mpfr_prec_t precision_bits = default_precision_bits ();
  require_valid_precision (precision_bits);
  mpfrxx::set_default_precision_bits (precision_bits);
  if (mpfrxx::default_precision_bits () != precision_bits)
    throw std::runtime_error (
      "failed to synchronize the current-thread MPFR default precision");
}

mpfr_prec_t
bits_for_decimal_digits (precision_count_t decimal_digits)
{
  if (decimal_digits == 0)
    throw std::invalid_argument ("decimal digits must be positive");

  for (mpfr_prec_t working_precision = 128;
       working_precision <= 16384;
       working_precision *= 2)
    {
      MpfrIntervalValue lower (working_precision);
      MpfrIntervalValue upper (working_precision);
      MpfrIntervalValue ten (working_precision);
      MpfrIntervalValue digits (working_precision);
      mpfr_set_ui (ten.get (), 10, MPFR_RNDN);
      mpfr_set_uj (digits.get (), decimal_digits, MPFR_RNDN);
      mpfr_log2 (lower.get (), ten.get (), MPFR_RNDD);
      mpfr_log2 (upper.get (), ten.get (), MPFR_RNDU);
      mpfr_mul (lower.get (), lower.get (), digits.get (), MPFR_RNDD);
      mpfr_mul (upper.get (), upper.get (), digits.get (), MPFR_RNDU);

      if (mpfr_cmp_si (lower.get (), MPFR_PREC_MAX) > 0)
        throw std::overflow_error ("decimal precision exceeds MPFR_PREC_MAX");

      // If only the upper bound exceeds MPFR_PREC_MAX, refine the interval
      // before deciding whether the exact value is in range.
      if (mpfr_cmp_si (upper.get (), MPFR_PREC_MAX) > 0)
        continue;

      const precision_count_t lower_bits = static_cast<precision_count_t> (
        mpfr_get_uj (lower.get (), MPFR_RNDU));
      const precision_count_t upper_bits = static_cast<precision_count_t> (
        mpfr_get_uj (upper.get (), MPFR_RNDU));
      if (lower_bits == upper_bits)
        return static_cast<mpfr_prec_t> (lower_bits);
    }

  throw std::runtime_error ("unable to certify decimal precision conversion");
}

precision_count_t
decimal_digits_for_bits (mpfr_prec_t precision_bits)
{
  require_valid_precision (precision_bits);

  return certified_integer_conversion (
    [precision_bits] (mpfr_ptr lower, mpfr_ptr upper,
                      mpfr_prec_t working_precision)
    {
      MpfrIntervalValue two (working_precision);
      MpfrIntervalValue bits (working_precision);
      mpfr_set_ui (two.get (), 2, MPFR_RNDN);
      mpfr_set_si (bits.get (), precision_bits, MPFR_RNDN);
      mpfr_log10 (lower, two.get (), MPFR_RNDD);
      mpfr_log10 (upper, two.get (), MPFR_RNDU);
      mpfr_mul (lower, lower, bits.get (), MPFR_RNDD);
      mpfr_mul (upper, upper, bits.get (), MPFR_RNDU);
    },
    [] (mpfr_srcptr value)
    {
      return static_cast<precision_count_t> (
        mpfr_get_uj (value, MPFR_RNDD));
    });
}

} // namespace octave_mplapack
