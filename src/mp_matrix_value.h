// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_MATRIX_VALUE_H
#define OCTAVE_MPLAPACK_MP_MATRIX_VALUE_H

#include <iosfwd>

#include <octave/ov-base.h>

#include "mp_matrix_storage.h"

class octave_value;

class octave_mplapack_mpfr_matrix_internal : public octave_base_dld_value
{
public:
  octave_mplapack_mpfr_matrix_internal ();
  explicit octave_mplapack_mpfr_matrix_internal (
    octave_mplapack::MpfrMatrixStorage storage);
  octave_mplapack_mpfr_matrix_internal (
    const octave_mplapack_mpfr_matrix_internal&) = default;
  ~octave_mplapack_mpfr_matrix_internal () override = default;

  octave_base_value * clone () const override;
  octave_base_value * empty_clone () const override;

  dim_vector dims () const override;
  bool is_defined () const override;
  bool is_storable () const override;
  bool is_real_matrix () const override;
  bool isreal () const override;
  bool is_matrix_type () const override;

  void print (std::ostream& os,
              bool pr_as_read_syntax = false) override;
  void print_raw (std::ostream& os,
                  bool pr_as_read_syntax = false) const override;

  const octave_mplapack::MpfrMatrixStorage& storage () const noexcept;

  static const octave_mplapack_mpfr_matrix_internal&
  checked_value (const octave_value& value);

  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA

private:
  octave_mplapack::MpfrMatrixStorage m_storage;
};

#endif
