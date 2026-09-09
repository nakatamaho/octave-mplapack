// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_COMPLEX_SCALAR_STORAGE_H
#define OCTAVE_MPLAPACK_MP_COMPLEX_SCALAR_STORAGE_H

#include <complex>
#include <string>

#include <mplapack_gmpfrxx_mkII_config.h>
#include <mpcxx_mkII.h>

namespace octave_mplapack
{

class MpfrComplexScalarStorage
{
public:
  using NativeScalar = mpfrxx::mpc_class;

  MpfrComplexScalarStorage (const std::string& text,
                            mpfr_prec_t precision_bits);
  MpfrComplexScalarStorage (double real, double imag,
                            mpfr_prec_t precision_bits);
  MpfrComplexScalarStorage (const std::complex<double>& value,
                            mpfr_prec_t precision_bits);
  explicit MpfrComplexScalarStorage (NativeScalar value);
  MpfrComplexScalarStorage (const MpfrComplexScalarStorage&) = default;
  MpfrComplexScalarStorage (MpfrComplexScalarStorage&&) noexcept = default;
  ~MpfrComplexScalarStorage () = default;

  MpfrComplexScalarStorage& operator= (MpfrComplexScalarStorage other) noexcept;
  void swap (MpfrComplexScalarStorage& other) noexcept;

  mpfr_prec_t precision_bits () const noexcept;
  bool exactly_equal (const MpfrComplexScalarStorage& other) const noexcept;
  bool is_nan () const noexcept;
  bool is_infinite () const noexcept;
  bool is_zero () const noexcept;
  bool real_signbit () const noexcept;
  bool imag_signbit () const noexcept;
  std::string to_canonical_string () const;
  std::complex<double> to_double () const;

  const NativeScalar& native_value () const noexcept;

private:
  NativeScalar m_value;
};

void swap (MpfrComplexScalarStorage& lhs,
           MpfrComplexScalarStorage& rhs) noexcept;

} // namespace octave_mplapack

#endif
