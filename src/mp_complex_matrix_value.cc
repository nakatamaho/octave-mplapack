// SPDX-License-Identifier: BSD-2-Clause

#include "mp_complex_matrix_value.h"

#include <limits>
#include <ostream>
#include <utility>

#include <octave/error.h>
#include <octave/ov-typeinfo.h>
#include <octave/ov.h>

namespace
{
octave_idx_type checked_dimension (std::size_t value)
{
  if (value > static_cast<std::size_t> (
                std::numeric_limits<octave_idx_type>::max ()))
    throw std::overflow_error ("complex matrix dimension exceeds octave_idx_type");
  return static_cast<octave_idx_type> (value);
}
}

DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (
  octave_mplapack_mpc_matrix_internal,
  "mplapack_mpc_matrix_internal", "mplapack_mpc_matrix_internal");

octave_mplapack_mpc_matrix_internal::octave_mplapack_mpc_matrix_internal ()
  : m_storage (0, 0, MPFR_PREC_MIN)
{
}

octave_mplapack_mpc_matrix_internal::octave_mplapack_mpc_matrix_internal (
  octave_mplapack::MpfrComplexMatrixStorage storage)
  : m_storage (std::move (storage))
{
}

octave_base_value *octave_mplapack_mpc_matrix_internal::clone () const
{ return new octave_mplapack_mpc_matrix_internal (*this); }

octave_base_value *octave_mplapack_mpc_matrix_internal::empty_clone () const
{ return clone (); }

dim_vector octave_mplapack_mpc_matrix_internal::dims () const
{ return dim_vector (checked_dimension (m_storage.rows ()),
                     checked_dimension (m_storage.columns ())); }

bool octave_mplapack_mpc_matrix_internal::is_defined () const { return true; }
bool octave_mplapack_mpc_matrix_internal::is_storable () const { return false; }
bool octave_mplapack_mpc_matrix_internal::is_complex_matrix () const { return true; }
bool octave_mplapack_mpc_matrix_internal::isreal () const { return false; }
bool octave_mplapack_mpc_matrix_internal::is_matrix_type () const { return true; }

void octave_mplapack_mpc_matrix_internal::print (std::ostream& os, bool)
{ print_raw (os); }

void octave_mplapack_mpc_matrix_internal::print_raw (std::ostream& os, bool) const
{
  os << "[internal MPLAPACK MPC " << m_storage.rows () << 'x'
     << m_storage.columns () << " matrix; " << m_storage.precision_bits ()
     << " bits]";
}

const octave_mplapack::MpfrComplexMatrixStorage&
octave_mplapack_mpc_matrix_internal::storage () const noexcept
{ return m_storage; }

const octave_mplapack_mpc_matrix_internal&
octave_mplapack_mpc_matrix_internal::checked_value (const octave_value& value)
{
  if (value.type_id () != static_type_id ())
    error_with_id ("mplapack:InvalidNativeValue",
                   "expected an internal MPLAPACK MPC matrix");
  const auto *native_value
    = dynamic_cast<const octave_mplapack_mpc_matrix_internal *> (
        value.internal_rep ());
  if (! native_value)
    error_with_id ("mplapack:InvalidNativeValue",
                   "invalid internal MPLAPACK MPC matrix representation");
  return *native_value;
}
