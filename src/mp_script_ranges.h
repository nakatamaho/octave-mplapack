// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_SCRIPT_RANGES_H
#define OCTAVE_MPLAPACK_MP_SCRIPT_RANGES_H

#include <cstddef>

#include "mp_matrix_storage.h"
#include "mp_scalar_storage.h"
#include "mp_complex_matrix_storage.h"
#include "mp_complex_scalar_storage.h"

namespace octave_mplapack
{

enum class MpScriptRoundingOperation
{
  floor,
  ceil,
  fix,
  round
};

MpfrMatrixStorage mpfr_script_colon (const MpfrScalarStorage& first,
                                     const MpfrScalarStorage& step,
                                     const MpfrScalarStorage& last);

MpfrMatrixStorage mpfr_script_linspace (const MpfrScalarStorage& first,
                                        const MpfrScalarStorage& last,
                                        std::size_t count);
MpfrComplexMatrixStorage mpc_script_linspace (
  const MpfrComplexScalarStorage& first,
  const MpfrComplexScalarStorage& last, std::size_t count);

MpfrMatrixStorage mpfr_script_logspace (const MpfrScalarStorage& first,
                                        const MpfrScalarStorage& last,
                                        std::size_t count);

MpfrMatrixStorage mpfr_script_round (
  const MpfrMatrixStorage& source, MpScriptRoundingOperation operation);

MpfrMatrixStorage mpfr_script_remainder (
  const MpfrMatrixStorage& lhs, const MpfrMatrixStorage& rhs, bool modulus);
MpfrMatrixStorage mpfr_script_hypot (const MpfrMatrixStorage& lhs,
                                    const MpfrMatrixStorage& rhs);
MpfrMatrixStorage mpfr_script_atan2 (const MpfrMatrixStorage& y,
                                     const MpfrMatrixStorage& x);
MpfrMatrixStorage mpfr_script_eps (const MpfrMatrixStorage& source);

} // namespace octave_mplapack

#endif
