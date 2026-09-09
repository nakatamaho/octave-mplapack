// SPDX-License-Identifier: BSD-2-Clause

#include "mp_random.h"

#include <array>
#include <limits>
#include <stdexcept>

#include <gmp.h>

namespace octave_mplapack
{

namespace
{

constexpr std::uint64_t splitmix_increment = 0x9e3779b97f4a7c15ULL;
constexpr std::uint64_t splitmix_multiplier_1 = 0xbf58476d1ce4e5b9ULL;
constexpr std::uint64_t splitmix_multiplier_2 = 0x94d049bb133111ebULL;

std::uint64_t
splitmix_next (std::uint64_t& state) noexcept
{
  state += splitmix_increment;
  std::uint64_t value = state;
  value = (value ^ (value >> 30)) * splitmix_multiplier_1;
  value = (value ^ (value >> 27)) * splitmix_multiplier_2;
  return value ^ (value >> 31);
}

class MpRandomEngine
{
public:
  explicit MpRandomEngine (MpRandomState& state) : m_state (state)
  {
    if (m_state.first == 0 && m_state.second == 0)
      throw std::invalid_argument ("MPLAPACK RNG state must not be all zero");
  }

  std::uint64_t next () noexcept
  {
    // xorshift128+ with the state transition and output function specified
    // using uint64_t operations.  This deliberately does not use C rand(),
    // a floating distribution, or implementation-defined integer widths.
    std::uint64_t x = m_state.first;
    const std::uint64_t y = m_state.second;
    m_state.first = y;
    x ^= x << 23;
    m_state.second = x ^ y ^ (x >> 17) ^ (y >> 26);
    return m_state.second + y;
  }

private:
  MpRandomState& m_state;
};

void
set_mpz_from_u64 (mpz_ptr destination, std::uint64_t value)
{
  std::array<unsigned char, 8> bytes {};
  for (std::size_t index = 0; index < bytes.size (); ++index)
    bytes[index] = static_cast<unsigned char> (
      value >> (8 * (bytes.size () - index - 1)));
  mpz_import (destination, bytes.size (), 1, 1, 1, 0, bytes.data ());
}

void
random_bits (mpz_ptr destination, std::size_t bit_count,
             MpRandomEngine& engine)
{
  mpz_set_ui (destination, 0);
  mpz_t word;
  mpz_init (word);

  std::size_t consumed = 0;
  while (consumed < bit_count)
    {
      const std::size_t remaining = bit_count - consumed;
      const std::size_t take = remaining < 64 ? remaining : 64;
      std::uint64_t raw = engine.next ();
      if (take < 64)
        raw &= (std::uint64_t (1) << take) - 1;
      set_mpz_from_u64 (word, raw);
      mpz_mul_2exp (destination, destination, take);
      mpz_add (destination, destination, word);
      consumed += take;
    }

  mpz_clear (word);
}

void
set_uniform_from_bits (mpfr_ptr destination, mpfr_prec_t precision_bits,
                       MpRandomEngine& engine)
{
  mpz_t integer;
  mpz_init (integer);
  random_bits (integer, static_cast<std::size_t> (precision_bits), engine);
  if (static_cast<std::uintmax_t> (precision_bits)
      > static_cast<std::uintmax_t> (std::numeric_limits<mpfr_exp_t>::max ()))
    {
      mpz_clear (integer);
      throw std::overflow_error ("MPFR precision exceeds exponent range");
    }
  mpfr_set_z_2exp (destination, integer,
                   -static_cast<mpfr_exp_t> (precision_bits), MPFR_RNDN);
  mpz_clear (integer);
}

void
set_integer_from_z (mpfr_ptr destination, mpfr_prec_t precision_bits,
                    mpz_srcptr integer)
{
  mpfr_set_z (destination, integer, MPFR_RNDN);
  mpz_t round_trip;
  mpz_init (round_trip);
  mpfr_get_z (round_trip, destination, MPFR_RNDZ);
  const bool exact = mpz_cmp (round_trip, integer) == 0;
  mpz_clear (round_trip);
  if (! exact)
    throw std::range_error (
      "integer result cannot be represented exactly at current mpbits");
  (void) precision_bits;
}

} // namespace

MpRandomState
mp_random_seed (std::uint64_t seed) noexcept
{
  std::uint64_t expansion = seed;
  MpRandomState result {splitmix_next (expansion), splitmix_next (expansion)};
  if (result.first == 0 && result.second == 0)
    result.second = 1;
  return result;
}

MpfrMatrixStorage
mp_random_uniform (std::size_t rows, std::size_t columns,
                   mpfr_prec_t precision_bits, MpRandomState& state)
{
  MpRandomEngine engine (state);
  MpfrMatrixStorage result (rows, columns, precision_bits);
  for (std::size_t index = 0; index < result.numel (); ++index)
    set_uniform_from_bits (result.data ()[index].mpfr_data (),
                           precision_bits, engine);
  return result;
}

MpfrMatrixStorage
mp_random_normal (std::size_t rows, std::size_t columns,
                  mpfr_prec_t precision_bits, MpRandomState& state)
{
  MpRandomEngine engine (state);
  MpfrMatrixStorage result (rows, columns, precision_bits);
  mpfr_t u1;
  mpfr_t u2;
  mpfr_t pi;
  mpfr_t two_pi;
  mpfr_t radius;
  mpfr_t angle;
  mpfr_init2 (u1, precision_bits);
  mpfr_init2 (u2, precision_bits);
  mpfr_init2 (pi, precision_bits);
  mpfr_init2 (two_pi, precision_bits);
  mpfr_init2 (radius, precision_bits);
  mpfr_init2 (angle, precision_bits);
  mpfr_const_pi (pi, MPFR_RNDN);
  mpfr_mul_ui (two_pi, pi, 2, MPFR_RNDN);

  for (std::size_t index = 0; index < result.numel (); ++index)
    {
      do
        set_uniform_from_bits (u1, precision_bits, engine);
      while (mpfr_zero_p (u1));
      set_uniform_from_bits (u2, precision_bits, engine);
      mpfr_log (radius, u1, MPFR_RNDN);
      mpfr_neg (radius, radius, MPFR_RNDN);
      mpfr_mul_ui (radius, radius, 2, MPFR_RNDN);
      mpfr_sqrt (radius, radius, MPFR_RNDN);
      mpfr_mul (angle, two_pi, u2, MPFR_RNDN);
      mpfr_cos (angle, angle, MPFR_RNDN);
      mpfr_mul (result.data ()[index].mpfr_data (), radius, angle,
                MPFR_RNDN);
    }

  mpfr_clear (u1);
  mpfr_clear (u2);
  mpfr_clear (pi);
  mpfr_clear (two_pi);
  mpfr_clear (radius);
  mpfr_clear (angle);
  return result;
}

MpfrMatrixStorage
mp_random_integer (std::size_t rows, std::size_t columns,
                   mpfr_prec_t precision_bits,
                   const MpfrScalarStorage& lower,
                   const MpfrScalarStorage& upper,
                   MpRandomState& state)
{
  const mpfr_srcptr lower_value = lower.native_value ().mpfr_data ();
  const mpfr_srcptr upper_value = upper.native_value ().mpfr_data ();
  if (! mpfr_integer_p (lower_value) || ! mpfr_integer_p (upper_value))
    throw std::invalid_argument ("mprandi bounds must be exact integers");
  if (mpfr_cmp (lower_value, upper_value) > 0)
    throw std::invalid_argument ("mprandi lower bound exceeds upper bound");

  mpz_t lower_integer;
  mpz_t upper_integer;
  mpz_t span;
  mpz_t candidate;
  mpz_init (lower_integer);
  mpz_init (upper_integer);
  mpz_init (span);
  mpz_init (candidate);
  mpfr_get_z (lower_integer, lower_value, MPFR_RNDZ);
  mpfr_get_z (upper_integer, upper_value, MPFR_RNDZ);
  mpz_sub (span, upper_integer, lower_integer);
  mpz_add_ui (span, span, 1);
  const std::size_t bit_count = mpz_sizeinbase (span, 2);
  MpRandomEngine engine (state);
  MpfrMatrixStorage result (rows, columns, precision_bits);
  for (std::size_t index = 0; index < result.numel (); ++index)
    {
      do
        random_bits (candidate, bit_count, engine);
      while (mpz_cmp (candidate, span) >= 0);
      mpz_add (candidate, candidate, lower_integer);
      set_integer_from_z (result.data ()[index].mpfr_data (),
                          precision_bits, candidate);
      mpz_sub (candidate, candidate, lower_integer);
    }

  mpz_clear (lower_integer);
  mpz_clear (upper_integer);
  mpz_clear (span);
  mpz_clear (candidate);
  return result;
}

} // namespace octave_mplapack
