// SPDX-License-Identifier: BSD-2-Clause

#include "mp_complex_value.h"

#include <ostream>
#include <utility>

#include <octave/error.h>
#include <octave/ov-typeinfo.h>
#include <octave/ov.h>

DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (
  octave_mplapack_mpc_scalar_internal,
  "mplapack_mpc_scalar_internal", "mplapack_mpc_scalar_internal");

octave_mplapack_mpc_scalar_internal::octave_mplapack_mpc_scalar_internal ()
  : m_storage (0.0, 0.0, MPFR_PREC_MIN)
{
}

octave_mplapack_mpc_scalar_internal::octave_mplapack_mpc_scalar_internal (
  const std::string& text, mpfr_prec_t precision_bits)
  : m_storage (text, precision_bits)
{
}

octave_mplapack_mpc_scalar_internal::octave_mplapack_mpc_scalar_internal (
  double real, double imag, mpfr_prec_t precision_bits)
  : m_storage (real, imag, precision_bits)
{
}

octave_mplapack_mpc_scalar_internal::octave_mplapack_mpc_scalar_internal (
  octave_mplapack::MpfrComplexScalarStorage storage)
  : m_storage (std::move (storage))
{
}

octave_base_value *octave_mplapack_mpc_scalar_internal::clone () const
{ return new octave_mplapack_mpc_scalar_internal (*this); }

octave_base_value *octave_mplapack_mpc_scalar_internal::empty_clone () const
{ return clone (); }

dim_vector octave_mplapack_mpc_scalar_internal::dims () const
{ return dim_vector (1, 1); }

bool octave_mplapack_mpc_scalar_internal::is_defined () const { return true; }
bool octave_mplapack_mpc_scalar_internal::is_storable () const { return false; }
bool octave_mplapack_mpc_scalar_internal::is_complex_scalar () const { return true; }
bool octave_mplapack_mpc_scalar_internal::isreal () const { return false; }
bool octave_mplapack_mpc_scalar_internal::is_scalar_type () const { return true; }

void octave_mplapack_mpc_scalar_internal::print (std::ostream& os, bool)
{ print_raw (os); }

void octave_mplapack_mpc_scalar_internal::print_raw (std::ostream& os, bool) const
{
  os << "[internal MPLAPACK MPC scalar; " << m_storage.precision_bits ()
     << " bits]";
}

const octave_mplapack::MpfrComplexScalarStorage&
octave_mplapack_mpc_scalar_internal::storage () const noexcept
{ return m_storage; }

const octave_mplapack_mpc_scalar_internal&
octave_mplapack_mpc_scalar_internal::checked_value (const octave_value& value)
{
  if (value.type_id () != static_type_id ())
    error_with_id ("mplapack:InvalidNativeValue",
                   "expected an internal MPLAPACK MPC scalar");
  const auto *native_value
    = dynamic_cast<const octave_mplapack_mpc_scalar_internal *> (
        value.internal_rep ());
  if (! native_value)
    error_with_id ("mplapack:InvalidNativeValue",
                   "invalid internal MPLAPACK MPC scalar representation");
  return *native_value;
}
