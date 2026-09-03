// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_COMPLEX_STRUCTURE_H
#define OCTAVE_MPLAPACK_MP_COMPLEX_STRUCTURE_H

#include "mp_complex_scalar_storage.h"
#include "mp_scalar_storage.h"

namespace octave_mplapack
{

MpfrScalarStorage mpfr_complex_scalar_real (
  const MpfrComplexScalarStorage& source);

MpfrScalarStorage mpfr_complex_scalar_imag (
  const MpfrComplexScalarStorage& source);

MpfrComplexScalarStorage mpfr_complex_scalar_conj (
  const MpfrComplexScalarStorage& source);

MpfrComplexScalarStorage mpfr_complex_scalar_transpose (
  const MpfrComplexScalarStorage& source);

MpfrComplexScalarStorage mpfr_complex_scalar_ctranspose (
  const MpfrComplexScalarStorage& source);

} // namespace octave_mplapack

#endif
