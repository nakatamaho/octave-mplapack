// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_VALUE_H
#define OCTAVE_MPLAPACK_MP_VALUE_H

#include <iosfwd>
#include <string>

#include <octave/ov-base.h>

#include "mp_scalar_storage.h"

class octave_value;

class octave_mplapack_mpfr_scalar_internal : public octave_base_dld_value
{
public:
  octave_mplapack_mpfr_scalar_internal ();
  octave_mplapack_mpfr_scalar_internal (const std::string& text,
                                        mpfr_prec_t precision_bits);
  octave_mplapack_mpfr_scalar_internal (
    const octave_mplapack_mpfr_scalar_internal&) = default;
  ~octave_mplapack_mpfr_scalar_internal () override = default;

  octave_base_value * clone () const override;
  octave_base_value * empty_clone () const override;

  dim_vector dims () const override;
  bool is_defined () const override;
  bool is_storable () const override;
  bool is_real_scalar () const override;
  bool isreal () const override;
  bool is_scalar_type () const override;

  void print (std::ostream& os,
              bool pr_as_read_syntax = false) override;
  void print_raw (std::ostream& os,
                  bool pr_as_read_syntax = false) const override;

  const octave_mplapack::MpfrScalarStorage& storage () const noexcept;

  static const octave_mplapack_mpfr_scalar_internal&
  checked_value (const octave_value& value);

  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA

private:
  octave_mplapack::MpfrScalarStorage m_storage;
};

#endif
