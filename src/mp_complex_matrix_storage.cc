// SPDX-License-Identifier: BSD-2-Clause

#include "mp_complex_matrix_storage.h"

#include <algorithm>
#include <limits>
#include <stdexcept>
#include <type_traits>

namespace octave_mplapack
{

namespace
{

void
validate_precision (mpfr_prec_t precision_bits)
{
  if (precision_bits < MPFR_PREC_MIN || precision_bits > MPFR_PREC_MAX)
    throw std::invalid_argument ("complex matrix precision is outside MPFR limits");
}

} // namespace

static_assert (std::is_same_v<MpfrComplexMatrixStorage::NativeScalar,
                              mpfrxx::mpc_class>);
static_assert (sizeof (MpfrComplexMatrixStorage::NativeScalar) == sizeof (mpc_t));
static_assert (alignof (MpfrComplexMatrixStorage::NativeScalar) == alignof (mpc_t));

MpfrComplexMatrixStorage::MpfrComplexMatrixStorage (
  std::size_t rows, std::size_t columns, mpfr_prec_t precision_bits)
  : m_rows (rows), m_columns (columns), m_precision_bits (precision_bits),
    m_values (make_elements (checked_element_count (rows, columns),
                             precision_bits))
{
  checked_mplapack_dimension (rows);
  checked_mplapack_dimension (columns);
}

MpfrComplexMatrixStorage::MpfrComplexMatrixStorage (
  std::size_t rows, std::size_t columns, mpfr_prec_t precision_bits,
  const std::vector<std::complex<double>>& values)
  : MpfrComplexMatrixStorage (rows, columns, precision_bits)
{
  if (values.size () != m_values.size ())
    throw std::invalid_argument ("complex matrix element count mismatch");
  for (std::size_t i = 0; i < values.size (); ++i)
    mpc_set_d_d (m_values[i].mpc_data (), values[i].real (), values[i].imag (),
                 MPC_RND (MPFR_RNDN, MPFR_RNDN));
}

MpfrComplexMatrixStorage::MpfrComplexMatrixStorage (
  std::size_t rows, std::size_t columns, mpfr_prec_t precision_bits,
  const std::vector<std::string>& values)
  : MpfrComplexMatrixStorage (rows, columns, precision_bits)
{
  if (values.size () != m_values.size ())
    throw std::invalid_argument ("complex matrix element count mismatch");
  for (std::size_t i = 0; i < values.size (); ++i)
    if (m_values[i].set_str (values[i], 10) != 0)
      throw std::invalid_argument ("invalid complex matrix element text");
}

MpfrComplexMatrixStorage&
MpfrComplexMatrixStorage::operator= (MpfrComplexMatrixStorage other) noexcept
{
  swap (other);
  return *this;
}

void
MpfrComplexMatrixStorage::swap (MpfrComplexMatrixStorage& other) noexcept
{
  using std::swap;
  swap (m_rows, other.m_rows);
  swap (m_columns, other.m_columns);
  swap (m_precision_bits, other.m_precision_bits);
  m_values.swap (other.m_values);
}

std::size_t MpfrComplexMatrixStorage::rows () const noexcept { return m_rows; }
std::size_t MpfrComplexMatrixStorage::columns () const noexcept { return m_columns; }
std::size_t MpfrComplexMatrixStorage::numel () const noexcept { return m_values.size (); }
mpfr_prec_t MpfrComplexMatrixStorage::precision_bits () const noexcept { return m_precision_bits; }

MpfrComplexMatrixStorage::MplapackInteger
MpfrComplexMatrixStorage::leading_dimension () const
{
  return checked_mplapack_dimension (std::max<std::size_t> (1, m_rows));
}

MpfrComplexMatrixStorage::NativeScalar* MpfrComplexMatrixStorage::data () noexcept
{ return m_values.data (); }

const MpfrComplexMatrixStorage::NativeScalar* MpfrComplexMatrixStorage::data () const noexcept
{ return m_values.data (); }

MpfrComplexMatrixStorage::NativeScalar&
MpfrComplexMatrixStorage::at (std::size_t row, std::size_t column)
{ return m_values.at (offset (row, column)); }

const MpfrComplexMatrixStorage::NativeScalar&
MpfrComplexMatrixStorage::at (std::size_t row, std::size_t column) const
{ return m_values.at (offset (row, column)); }

bool
MpfrComplexMatrixStorage::all_elements_have_uniform_precision () const noexcept
{
  return std::all_of (m_values.begin (), m_values.end (), [this] (const NativeScalar& value)
  { return value.real_precision () == m_precision_bits
           && value.imag_precision () == m_precision_bits; });
}

bool
MpfrComplexMatrixStorage::element_exactly_equal_text (
  std::size_t row, std::size_t column, const std::string& text) const
{
  NativeScalar expected = NativeScalar::with_precision (m_precision_bits);
  if (expected.set_str (text, 10) != 0)
    throw std::invalid_argument ("invalid complex matrix comparison text");
  const NativeScalar& actual = at (row, column);
  return mpfr_equal_p (mpc_realref (actual.mpc_data ()),
                       mpc_realref (expected.mpc_data ())) != 0
         && mpfr_equal_p (mpc_imagref (actual.mpc_data ()),
                          mpc_imagref (expected.mpc_data ())) != 0;
}

bool
MpfrComplexMatrixStorage::element_exactly_equal_double (
  std::size_t row, std::size_t column,
  const std::complex<double>& value) const noexcept
{
  try
    {
      NativeScalar expected = NativeScalar::with_precision (m_precision_bits,
                                                              value.real (),
                                                              value.imag ());
      const NativeScalar& actual = at (row, column);
      return mpfr_equal_p (mpc_realref (actual.mpc_data ()),
                           mpc_realref (expected.mpc_data ())) != 0
             && mpfr_equal_p (mpc_imagref (actual.mpc_data ()),
                              mpc_imagref (expected.mpc_data ())) != 0;
    }
  catch (...)
    { return false; }
}

bool
MpfrComplexMatrixStorage::element_exactly_equal (
  std::size_t row, std::size_t column,
  const MpfrComplexMatrixStorage& other, std::size_t other_row,
  std::size_t other_column) const
{
  const NativeScalar& lhs = at (row, column);
  const NativeScalar& rhs = other.at (other_row, other_column);
  return mpfr_equal_p (mpc_realref (lhs.mpc_data ()),
                       mpc_realref (rhs.mpc_data ())) != 0
         && mpfr_equal_p (mpc_imagref (lhs.mpc_data ()),
                          mpc_imagref (rhs.mpc_data ())) != 0;
}

std::size_t
MpfrComplexMatrixStorage::checked_element_count (std::size_t rows,
                                                 std::size_t columns)
{
  checked_mplapack_dimension (rows);
  checked_mplapack_dimension (columns);
  if (rows != 0 && columns > std::numeric_limits<std::size_t>::max () / rows)
    throw std::overflow_error ("complex matrix element count overflow");
  return rows * columns;
}

MpfrComplexMatrixStorage::MplapackInteger
MpfrComplexMatrixStorage::checked_mplapack_dimension (std::size_t value)
{
  using Limit = std::numeric_limits<MplapackInteger>;
  if (value > static_cast<std::size_t> (Limit::max ()))
    throw std::overflow_error ("complex matrix dimension exceeds MPLAPACK INTEGER");
  return static_cast<MplapackInteger> (value);
}

std::vector<MpfrComplexMatrixStorage::NativeScalar>
MpfrComplexMatrixStorage::make_elements (std::size_t count,
                                         mpfr_prec_t precision_bits)
{
  validate_precision (precision_bits);
  std::vector<NativeScalar> values;
  values.reserve (count);
  for (std::size_t i = 0; i < count; ++i)
    values.emplace_back (NativeScalar::with_precision (precision_bits));
  return values;
}

std::size_t
MpfrComplexMatrixStorage::offset (std::size_t row, std::size_t column) const
{
  if (row >= m_rows || column >= m_columns)
    throw std::out_of_range ("complex matrix element index out of range");
  return row + column * m_rows;
}

void swap (MpfrComplexMatrixStorage& lhs,
           MpfrComplexMatrixStorage& rhs) noexcept
{ lhs.swap (rhs); }

} // namespace octave_mplapack
