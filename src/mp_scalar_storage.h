// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_SCALAR_STORAGE_H
#define OCTAVE_MPLAPACK_MP_SCALAR_STORAGE_H

#include <string>

#include <mplapack_gmpfrxx_mkII_config.h>
#include <mpfrxx_mkII.h>

namespace octave_mplapack
{

class MpfrScalarStorage
{
public:
  using NativeScalar = mpfrxx::mpfr_class;

  MpfrScalarStorage (const std::string& text, mpfr_prec_t precision_bits);
  MpfrScalarStorage (const MpfrScalarStorage&) = default;
  MpfrScalarStorage (MpfrScalarStorage&&) noexcept = default;
  ~MpfrScalarStorage () = default;

  MpfrScalarStorage& operator= (MpfrScalarStorage other) noexcept;

  void swap (MpfrScalarStorage& other) noexcept;

  mpfr_prec_t precision_bits () const noexcept;
  bool exactly_equal (const MpfrScalarStorage& other) const noexcept;
  bool exactly_equal_string (const std::string& text) const;

  const NativeScalar& native_value () const noexcept;

private:
  NativeScalar m_value;
};

void swap (MpfrScalarStorage& lhs, MpfrScalarStorage& rhs) noexcept;

} // namespace octave_mplapack

#endif
