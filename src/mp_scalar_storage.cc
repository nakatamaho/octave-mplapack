// SPDX-License-Identifier: BSD-2-Clause

#include "mp_scalar_storage.h"

#include <array>
#include <charconv>
#include <limits>
#include <memory>
#include <stdexcept>
#include <string>

namespace
{

struct MpfrStringDeleter
{
  void operator() (char *value) const noexcept
  {
    if (value)
      mpfr_free_str (value);
  }
};

using MpfrString = std::unique_ptr<char, MpfrStringDeleter>;

std::size_t
checked_add (std::size_t lhs, std::size_t rhs)
{
  if (rhs > std::numeric_limits<std::size_t>::max () - lhs)
    throw std::overflow_error ("canonical string size overflow");

  return lhs + rhs;
}

std::string
canonical_exponent (mpfr_exp_t exponent)
{
  if (exponent == std::numeric_limits<mpfr_exp_t>::min ())
    throw std::overflow_error ("canonical exponent overflow");

  const mpfr_exp_t normalized = exponent - 1;
  std::array<char, std::numeric_limits<mpfr_exp_t>::digits10 + 4> buffer {};
  auto result = std::to_chars (buffer.data (),
                               buffer.data () + buffer.size (), normalized);
  if (result.ec != std::errc ())
    throw std::overflow_error ("canonical exponent conversion failed");

  std::string text;
  if (normalized >= 0)
    text.push_back ('+');
  text.append (buffer.data (), result.ptr);
  return text;
}

} // namespace

namespace octave_mplapack
{

MpfrScalarStorage::MpfrScalarStorage (const std::string& text,
                                      mpfr_prec_t precision_bits)
  : m_value (NativeScalar::with_precision (precision_bits))
{
  if (mpfr_set_str (m_value.mpfr_data (), text.c_str (), 10, MPFR_RNDN) != 0)
    throw std::invalid_argument ("invalid scalar text");
}

MpfrScalarStorage::MpfrScalarStorage (double value,
                                      mpfr_prec_t precision_bits)
  : m_value (NativeScalar::with_precision (precision_bits))
{
  mpfr_set_d (m_value.mpfr_data (), value, MPFR_RNDN);
}

MpfrScalarStorage::MpfrScalarStorage (mpfr_prec_t precision_bits,
                                      UninitializedTag)
  : m_value (NativeScalar::with_precision (precision_bits))
{
}

MpfrScalarStorage&
MpfrScalarStorage::operator= (MpfrScalarStorage other) noexcept
{
  swap (other);
  return *this;
}

void
MpfrScalarStorage::swap (MpfrScalarStorage& other) noexcept
{
  m_value.swap (other.m_value);
}

mpfr_prec_t
MpfrScalarStorage::precision_bits () const noexcept
{
  return m_value.precision ();
}

bool
MpfrScalarStorage::exactly_equal (const MpfrScalarStorage& other) const noexcept
{
  return mpfr_equal_p (m_value.mpfr_data (),
                       other.m_value.mpfr_data ()) != 0;
}

bool
MpfrScalarStorage::exactly_equal_string (const std::string& text) const
{
  const MpfrScalarStorage expected (text, precision_bits ());
  return exactly_equal (expected);
}

bool
MpfrScalarStorage::exactly_equal_double (double value) const noexcept
{
  return mpfr_cmp_d (m_value.mpfr_data (), value) == 0;
}

bool
MpfrScalarStorage::is_nan () const noexcept
{
  return mpfr_nan_p (m_value.mpfr_data ()) != 0;
}

bool
MpfrScalarStorage::is_infinite () const noexcept
{
  return mpfr_inf_p (m_value.mpfr_data ()) != 0;
}

bool
MpfrScalarStorage::is_zero () const noexcept
{
  return mpfr_zero_p (m_value.mpfr_data ()) != 0;
}

bool
MpfrScalarStorage::signbit () const noexcept
{
  return mpfr_signbit (m_value.mpfr_data ()) != 0;
}

std::string
MpfrScalarStorage::to_canonical_string () const
{
  if (is_nan ())
    return "NaN";
  if (is_infinite ())
    return signbit () ? "-Inf" : "Inf";
  if (is_zero ())
    return signbit () ? "-0" : "0";

  const std::size_t digit_count
    = mpfr_get_str_ndigits (10, precision_bits ());
  std::string capacity_probe;
  if (digit_count > std::numeric_limits<std::size_t>::max () - 2
      || digit_count > capacity_probe.max_size ())
    throw std::overflow_error ("canonical digit buffer size overflow");

  mpfr_exp_t exponent = 0;
  MpfrString raw_digits (
    mpfr_get_str (nullptr, &exponent, 10, 0, m_value.mpfr_data (),
                  MPFR_RNDN));
  if (! raw_digits)
    throw std::runtime_error ("mpfr_get_str failed");

  std::string digits (raw_digits.get ());
  const bool negative = ! digits.empty () && digits.front () == '-';
  if (negative)
    digits.erase (digits.begin ());
  if (digits.empty () || digits.front () == '0')
    throw std::runtime_error ("invalid finite MPFR significand");

  while (digits.size () > 1 && digits.back () == '0')
    digits.pop_back ();

  const std::string exponent_text = canonical_exponent (exponent);
  std::size_t output_size = negative ? 1 : 0;
  output_size = checked_add (output_size, digits.size ());
  if (digits.size () > 1)
    output_size = checked_add (output_size, 1);
  output_size = checked_add (output_size, 1);
  output_size = checked_add (output_size, exponent_text.size ());

  std::string output;
  if (output_size > output.max_size ())
    throw std::length_error ("canonical string exceeds std::string capacity");
  output.reserve (output_size);
  if (negative)
    output.push_back ('-');
  output.push_back (digits.front ());
  if (digits.size () > 1)
    {
      output.push_back ('.');
      output.append (digits.begin () + 1, digits.end ());
    }
  output.push_back ('e');
  output.append (exponent_text);
  return output;
}

double
MpfrScalarStorage::to_double () const noexcept
{
  return mpfr_get_d (m_value.mpfr_data (), MPFR_RNDN);
}

const MpfrScalarStorage::NativeScalar&
MpfrScalarStorage::native_value () const noexcept
{
  return m_value;
}

void
swap (MpfrScalarStorage& lhs, MpfrScalarStorage& rhs) noexcept
{
  lhs.swap (rhs);
}

} // namespace octave_mplapack
