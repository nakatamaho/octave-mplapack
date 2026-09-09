// SPDX-License-Identifier: BSD-2-Clause

#include "mp_native_serialization.h"

#include <charconv>
#include <cstdint>
#include <limits>
#include <ostream>
#include <stdexcept>
#include <string>
#include <type_traits>
#include <utility>
#include <vector>

namespace octave_mplapack
{

namespace
{

constexpr const char *native_magic = "MPLAPACK_MP_NATIVE_V1";
constexpr std::uint64_t max_text_length = 64ULL * 1024ULL * 1024ULL;
constexpr std::uint64_t max_element_count = 100000000ULL;

bool
write_line (std::ostream& stream, const std::string& value) noexcept
{
  stream << value << '\n';
  return static_cast<bool> (stream);
}

bool
write_uint_line (std::ostream& stream, std::uint64_t value) noexcept
{
  return write_line (stream, std::to_string (value));
}

bool
write_value (std::ostream& stream, const std::string& value) noexcept
{
  if (value.size () > max_text_length)
    return false;
  stream << value.size () << ':' << value << '\n';
  return static_cast<bool> (stream);
}

bool
read_line (std::istream& stream, std::string& value,
           std::size_t max_length = 128) noexcept
{
  value.clear ();
  if (! std::getline (stream, value) || value.size () > max_length)
    return false;
  return true;
}

bool
parse_uint (const std::string& text, std::uint64_t& value) noexcept
{
  if (text.empty ())
    return false;
  const char *first = text.data ();
  const char *last = first + text.size ();
  const auto parsed = std::from_chars (first, last, value);
  return parsed.ec == std::errc () && parsed.ptr == last;
}

bool
read_uint_line (std::istream& stream, std::uint64_t& value) noexcept
{
  std::string line;
  return read_line (stream, line) && parse_uint (line, value);
}

bool
read_value (std::istream& stream, std::string& value) noexcept
{
  std::string length_text;
  value.clear ();
  if (! std::getline (stream, length_text, ':')
      || length_text.empty () || length_text.size () > 20)
    return false;

  std::uint64_t length = 0;
  if (! parse_uint (length_text, length) || length > max_text_length)
    return false;
  value.resize (static_cast<std::size_t> (length));
  if (length != 0)
    stream.read (value.data (), static_cast<std::streamsize> (length));
  if (! stream || stream.get () != '\n')
    return false;
  return true;
}

bool
write_header (std::ostream& stream, const char *kind,
              mpfr_prec_t precision, std::size_t rows,
              std::size_t columns, std::size_t count) noexcept
{
  if (rows > std::numeric_limits<std::uint64_t>::max ()
      || columns > std::numeric_limits<std::uint64_t>::max ()
      || count > std::numeric_limits<std::uint64_t>::max ()
      || static_cast<std::uint64_t> (precision)
           > std::numeric_limits<std::uint64_t>::max ())
    return false;
  return write_line (stream, native_magic)
         && write_line (stream, kind)
         && write_uint_line (stream, static_cast<std::uint64_t> (precision))
         && write_uint_line (stream, static_cast<std::uint64_t> (rows))
         && write_uint_line (stream, static_cast<std::uint64_t> (columns))
         && write_uint_line (stream, static_cast<std::uint64_t> (count));
}

bool
read_header (std::istream& stream, const char *expected_kind,
             mpfr_prec_t& precision, std::size_t& rows,
             std::size_t& columns, std::size_t& count) noexcept
{
  std::string magic;
  std::string kind;
  std::uint64_t precision_value = 0;
  std::uint64_t rows_value = 0;
  std::uint64_t columns_value = 0;
  std::uint64_t count_value = 0;
  if (! read_line (stream, magic) || magic != native_magic
      || ! read_line (stream, kind) || kind != expected_kind
      || ! read_uint_line (stream, precision_value)
      || ! read_uint_line (stream, rows_value)
      || ! read_uint_line (stream, columns_value)
      || ! read_uint_line (stream, count_value))
    return false;

  const mpfr_prec_t converted_precision
    = static_cast<mpfr_prec_t> (precision_value);
  if (static_cast<std::uint64_t> (converted_precision) != precision_value
      || converted_precision < MPFR_PREC_MIN
      || converted_precision > MPFR_PREC_MAX
      || rows_value > std::numeric_limits<std::size_t>::max ()
      || columns_value > std::numeric_limits<std::size_t>::max ()
      || count_value > std::numeric_limits<std::size_t>::max ()
      || count_value > max_element_count)
    return false;

  const std::size_t converted_rows = static_cast<std::size_t> (rows_value);
  const std::size_t converted_columns
    = static_cast<std::size_t> (columns_value);
  const std::size_t converted_count = static_cast<std::size_t> (count_value);
  try
    {
      if (MpfrMatrixStorage::checked_element_count (converted_rows,
                                                    converted_columns)
          != converted_count)
        return false;
    }
  catch (...)
    {
      return false;
    }

  precision = converted_precision;
  rows = converted_rows;
  columns = converted_columns;
  count = converted_count;
  return true;
}

template <typename Storage>
bool
write_elements (std::ostream& stream, const Storage& storage) noexcept
{
  for (std::size_t column = 0; column < storage.columns (); ++column)
    for (std::size_t row = 0; row < storage.rows (); ++row)
      {
        std::string text;
        if constexpr (std::is_same_v<Storage, MpfrMatrixStorage>)
          text = MpfrScalarStorage (storage.at (row, column))
                   .to_canonical_string ();
        else
          text = MpfrComplexScalarStorage (storage.at (row, column))
                   .to_canonical_string ();
        if (! write_value (stream, text))
          return false;
      }
  return true;
}

template <typename Storage>
bool
read_elements (std::istream& stream, std::size_t count,
               std::vector<std::string>& values) noexcept
{
  values.clear ();
  try
    {
      values.reserve (count);
      for (std::size_t index = 0; index < count; ++index)
        {
          std::string text;
          if (! read_value (stream, text))
            return false;
          values.push_back (std::move (text));
        }
    }
  catch (...)
    {
      return false;
    }
  return true;
}

} // namespace

bool
save_native_mpfr_scalar (std::ostream& stream,
                         const MpfrScalarStorage& storage) noexcept
{
  return write_header (stream, "real-scalar", storage.precision_bits (),
                       1, 1, 1)
         && write_value (stream, storage.to_canonical_string ());
}

bool
load_native_mpfr_scalar (std::istream& stream,
                         MpfrScalarStorage& storage) noexcept
{
  mpfr_prec_t precision = 0;
  std::size_t rows = 0;
  std::size_t columns = 0;
  std::size_t count = 0;
  std::string text;
  if (! read_header (stream, "real-scalar", precision, rows, columns, count)
      || rows != 1 || columns != 1 || count != 1 || ! read_value (stream, text))
    return false;
  try
    {
      MpfrScalarStorage replacement (text, precision);
      storage = std::move (replacement);
      return true;
    }
  catch (...)
    {
      return false;
    }
}

bool
save_native_mpc_scalar (std::ostream& stream,
                        const MpfrComplexScalarStorage& storage) noexcept
{
  return write_header (stream, "complex-scalar", storage.precision_bits (),
                       1, 1, 1)
         && write_value (stream, storage.to_canonical_string ());
}

bool
load_native_mpc_scalar (std::istream& stream,
                        MpfrComplexScalarStorage& storage) noexcept
{
  mpfr_prec_t precision = 0;
  std::size_t rows = 0;
  std::size_t columns = 0;
  std::size_t count = 0;
  std::string text;
  if (! read_header (stream, "complex-scalar", precision, rows, columns,
                     count)
      || rows != 1 || columns != 1 || count != 1 || ! read_value (stream, text))
    return false;
  try
    {
      MpfrComplexScalarStorage replacement (text, precision);
      storage = std::move (replacement);
      return true;
    }
  catch (...)
    {
      return false;
    }
}

bool
save_native_mpfr_matrix (std::ostream& stream,
                         const MpfrMatrixStorage& storage) noexcept
{
  return write_header (stream, "real-matrix", storage.precision_bits (),
                       storage.rows (), storage.columns (), storage.numel ())
         && write_elements (stream, storage);
}

bool
load_native_mpfr_matrix (std::istream& stream,
                         MpfrMatrixStorage& storage) noexcept
{
  mpfr_prec_t precision = 0;
  std::size_t rows = 0;
  std::size_t columns = 0;
  std::size_t count = 0;
  if (! read_header (stream, "real-matrix", precision, rows, columns, count))
    return false;
  std::vector<std::string> values;
  if (! read_elements<MpfrMatrixStorage> (stream, count, values))
    return false;
  try
    {
      MpfrMatrixStorage replacement (rows, columns, precision, values);
      storage = std::move (replacement);
      return true;
    }
  catch (...)
    {
      return false;
    }
}

bool
save_native_mpc_matrix (std::ostream& stream,
                        const MpfrComplexMatrixStorage& storage) noexcept
{
  return write_header (stream, "complex-matrix", storage.precision_bits (),
                       storage.rows (), storage.columns (), storage.numel ())
         && write_elements (stream, storage);
}

bool
load_native_mpc_matrix (std::istream& stream,
                        MpfrComplexMatrixStorage& storage) noexcept
{
  mpfr_prec_t precision = 0;
  std::size_t rows = 0;
  std::size_t columns = 0;
  std::size_t count = 0;
  if (! read_header (stream, "complex-matrix", precision, rows, columns,
                     count))
    return false;
  std::vector<std::string> values;
  if (! read_elements<MpfrComplexMatrixStorage> (stream, count, values))
    return false;
  try
    {
      MpfrComplexMatrixStorage replacement (rows, columns, precision, values);
      storage = std::move (replacement);
      return true;
    }
  catch (...)
    {
      return false;
    }
}

} // namespace octave_mplapack
