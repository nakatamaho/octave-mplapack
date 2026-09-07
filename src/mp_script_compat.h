// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_SCRIPT_COMPAT_H
#define OCTAVE_MPLAPACK_MP_SCRIPT_COMPAT_H

#include <cstddef>
#include <vector>

#include "mp_complex_matrix_storage.h"
#include "mp_complex_scalar_storage.h"
#include "mp_matrix_storage.h"
#include "mp_scalar_storage.h"

namespace octave_mplapack
{

enum class MpScriptUnaryOperation
{
  absolute,
  angle,
  sign
};

enum class MpScriptPredicate
{
  isnan,
  isinf,
  isfinite
};

struct MpScriptPredicateResult
{
  std::size_t rows = 0;
  std::size_t columns = 0;
  std::vector<unsigned char> values;
};

MpfrScalarStorage mpfr_script_unary (
  const MpfrScalarStorage& source,
  MpScriptUnaryOperation operation);

MpfrMatrixStorage mpfr_script_unary (
  const MpfrMatrixStorage& source,
  MpScriptUnaryOperation operation);

MpfrScalarStorage mpc_script_real_unary (
  const MpfrComplexScalarStorage& source,
  MpScriptUnaryOperation operation);

MpfrMatrixStorage mpc_script_real_unary (
  const MpfrComplexMatrixStorage& source,
  MpScriptUnaryOperation operation);

MpfrComplexScalarStorage mpc_script_unary (
  const MpfrComplexScalarStorage& source,
  MpScriptUnaryOperation operation);

MpfrComplexMatrixStorage mpc_script_unary (
  const MpfrComplexMatrixStorage& source,
  MpScriptUnaryOperation operation);

MpScriptPredicateResult mpfr_script_predicate (
  const MpfrScalarStorage& source,
  MpScriptPredicate predicate);

MpScriptPredicateResult mpfr_script_predicate (
  const MpfrMatrixStorage& source,
  MpScriptPredicate predicate);

MpScriptPredicateResult mpc_script_predicate (
  const MpfrComplexScalarStorage& source,
  MpScriptPredicate predicate);

MpScriptPredicateResult mpc_script_predicate (
  const MpfrComplexMatrixStorage& source,
  MpScriptPredicate predicate);

bool mpfr_script_equal (const MpfrScalarStorage& lhs,
                        const MpfrScalarStorage& rhs,
                        bool nan_equal) noexcept;

bool mpfr_script_equal (const MpfrMatrixStorage& lhs,
                        const MpfrMatrixStorage& rhs,
                        bool nan_equal) noexcept;

bool mpc_script_equal (const MpfrComplexScalarStorage& lhs,
                       const MpfrComplexScalarStorage& rhs,
                       bool nan_equal) noexcept;

bool mpc_script_equal (const MpfrComplexMatrixStorage& lhs,
                       const MpfrComplexMatrixStorage& rhs,
                       bool nan_equal) noexcept;

} // namespace octave_mplapack

#endif
