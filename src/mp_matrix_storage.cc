// SPDX-License-Identifier: BSD-2-Clause

#include "mp_matrix_storage.h"

#include <algorithm>
#include <limits>
#include <stdexcept>
#include <type_traits>
#include <utility>

#include <mpblas_mpfr.h>

namespace
{

void
validate_precision (mpfr_prec_t precision_bits)
{
  if (precision_bits < MPFR_PREC_MIN || precision_bits > MPFR_PREC_MAX)
    throw std::invalid_argument ("matrix precision is outside MPFR limits");
}

} // namespace

namespace octave_mplapack
{

static_assert (std::is_same_v<MpfrMatrixStorage::NativeScalar,
                              mpfrxx::mpfr_class>);
static_assert (std::is_same_v<MpfrMatrixStorage::NativeScalar, mpfr_class>);
static_assert (std::is_same_v<MpfrMatrixStorage::MplapackInteger,
                              mplapackint>);
static_assert (std::is_integral_v<MpfrMatrixStorage::MplapackInteger>);
static_assert (std::is_signed_v<MpfrMatrixStorage::MplapackInteger>);

MpfrMatrixStorage::MpfrMatrixStorage (std::size_t rows,
                                      std::size_t columns,
                                      mpfr_prec_t precision_bits)
  : m_rows (rows), m_columns (columns),
    m_precision_bits (precision_bits),
    m_values (make_elements (checked_element_count (rows, columns),
                             precision_bits))
{
  checked_mplapack_dimension (rows);
  checked_mplapack_dimension (columns);
}

MpfrMatrixStorage::MpfrMatrixStorage (
  std::size_t rows, std::size_t columns, mpfr_prec_t precision_bits,
  const std::vector<double>& column_major_values)
  : MpfrMatrixStorage (rows, columns, precision_bits)
{
  if (column_major_values.size () != m_values.size ())
    throw std::invalid_argument ("double matrix element count mismatch");

  for (std::size_t index = 0; index < m_values.size (); ++index)
    mpfr_set_d (m_values[index].mpfr_data (), column_major_values[index],
                MPFR_RNDN);
}

MpfrMatrixStorage::MpfrMatrixStorage (
  std::size_t rows, std::size_t columns, mpfr_prec_t precision_bits,
  const std::vector<std::string>& column_major_values)
  : MpfrMatrixStorage (rows, columns, precision_bits)
{
  if (column_major_values.size () != m_values.size ())
    throw std::invalid_argument ("text matrix element count mismatch");

  for (std::size_t index = 0; index < m_values.size (); ++index)
    if (mpfr_set_str (m_values[index].mpfr_data (),
                      column_major_values[index].c_str (), 10,
                      MPFR_RNDN) != 0)
      throw std::invalid_argument ("invalid matrix element text");
}

MpfrMatrixStorage::MpfrMatrixStorage (
  std::size_t rows, std::size_t columns, mpfr_prec_t precision_bits,
  const MpfrMatrixStorage& source)
  : MpfrMatrixStorage (rows, columns, precision_bits)
{
  if (source.rows () != rows || source.columns () != columns)
    throw std::invalid_argument ("matrix promotion shape mismatch");

  for (std::size_t index = 0; index < m_values.size (); ++index)
    mpfr_set (m_values[index].mpfr_data (), source.m_values[index].mpfr_data (),
              MPFR_RNDN);
}

MpfrMatrixStorage&
MpfrMatrixStorage::operator= (MpfrMatrixStorage other) noexcept
{
  swap (other);
  return *this;
}

void
MpfrMatrixStorage::swap (MpfrMatrixStorage& other) noexcept
{
  using std::swap;
  swap (m_rows, other.m_rows);
  swap (m_columns, other.m_columns);
  swap (m_precision_bits, other.m_precision_bits);
  m_values.swap (other.m_values);
}

std::size_t
MpfrMatrixStorage::rows () const noexcept
{
  return m_rows;
}

std::size_t
MpfrMatrixStorage::columns () const noexcept
{
  return m_columns;
}

std::size_t
MpfrMatrixStorage::numel () const noexcept
{
  return m_values.size ();
}

mpfr_prec_t
MpfrMatrixStorage::precision_bits () const noexcept
{
  return m_precision_bits;
}

MpfrMatrixStorage::MplapackInteger
MpfrMatrixStorage::leading_dimension () const
{
  return checked_mplapack_dimension (std::max<std::size_t> (1, m_rows));
}

MpfrMatrixStorage::NativeScalar *
MpfrMatrixStorage::data () noexcept
{
  return m_values.data ();
}

const MpfrMatrixStorage::NativeScalar *
MpfrMatrixStorage::data () const noexcept
{
  return m_values.data ();
}

MpfrMatrixStorage::NativeScalar&
MpfrMatrixStorage::at (std::size_t row, std::size_t column)
{
  return m_values.at (offset (row, column));
}

const MpfrMatrixStorage::NativeScalar&
MpfrMatrixStorage::at (std::size_t row, std::size_t column) const
{
  return m_values.at (offset (row, column));
}

bool
MpfrMatrixStorage::all_elements_have_uniform_precision () const noexcept
{
  return std::all_of (
    m_values.begin (), m_values.end (), [this] (const NativeScalar& value)
    {
      return value.precision () == m_precision_bits;
    });
}

bool
MpfrMatrixStorage::element_exactly_equal_text (
  std::size_t row, std::size_t column, const std::string& text) const
{
  NativeScalar expected = NativeScalar::with_precision (m_precision_bits);
  if (mpfr_set_str (expected.mpfr_data (), text.c_str (), 10, MPFR_RNDN) != 0)
    throw std::invalid_argument ("invalid matrix comparison text");
  return mpfr_equal_p (at (row, column).mpfr_data (),
                       expected.mpfr_data ()) != 0;
}

bool
MpfrMatrixStorage::element_exactly_equal_double (
  std::size_t row, std::size_t column, double value) const noexcept
{
  try
    {
      return mpfr_cmp_d (at (row, column).mpfr_data (), value) == 0;
    }
  catch (...)
    {
      return false;
    }
}

bool
MpfrMatrixStorage::element_exactly_equal (
  std::size_t row, std::size_t column, const MpfrMatrixStorage& other,
  std::size_t other_row, std::size_t other_column) const
{
  return mpfr_equal_p (at (row, column).mpfr_data (),
                       other.at (other_row, other_column).mpfr_data ()) != 0;
}

std::size_t
MpfrMatrixStorage::checked_element_count (std::size_t rows,
                                          std::size_t columns)
{
  checked_mplapack_dimension (rows);
  checked_mplapack_dimension (columns);
  if (rows != 0
      && columns > std::numeric_limits<std::size_t>::max () / rows)
    throw std::overflow_error ("matrix element count overflow");
  return rows * columns;
}

MpfrMatrixStorage::MplapackInteger
MpfrMatrixStorage::checked_mplapack_dimension (std::size_t value)
{
  using Limit = std::numeric_limits<MplapackInteger>;
  if (value > static_cast<std::size_t> (Limit::max ()))
    throw std::overflow_error ("matrix dimension exceeds MPLAPACK INTEGER");
  return static_cast<MplapackInteger> (value);
}

std::vector<MpfrMatrixStorage::NativeScalar>
MpfrMatrixStorage::make_elements (std::size_t count,
                                  mpfr_prec_t precision_bits)
{
  validate_precision (precision_bits);
  std::vector<NativeScalar> values;
  values.reserve (count);
  for (std::size_t index = 0; index < count; ++index)
    values.emplace_back (NativeScalar::with_precision (precision_bits));
  return values;
}

std::size_t
MpfrMatrixStorage::offset (std::size_t row, std::size_t column) const
{
  if (row >= m_rows || column >= m_columns)
    throw std::out_of_range ("matrix element index out of range");
  return row + column * m_rows;
}

void
swap (MpfrMatrixStorage& lhs, MpfrMatrixStorage& rhs) noexcept
{
  lhs.swap (rhs);
}

} // namespace octave_mplapack
