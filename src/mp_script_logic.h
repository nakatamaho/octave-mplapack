// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_SCRIPT_LOGIC_H
#define OCTAVE_MPLAPACK_MP_SCRIPT_LOGIC_H

#include <cstddef>
#include <vector>

#include "mp_complex_arithmetic.h"
#include "mp_matrix_arithmetic.h"

namespace octave_mplapack
{

enum class MpScriptComparisonOperation
{
  equal,
  not_equal,
  less,
  less_equal,
  greater,
  greater_equal
};

enum class MpScriptLogicalOperation
{
  and_op,
  or_op,
  xor_op
};

struct MpScriptLogicalResult
{
  std::size_t rows = 0;
  std::size_t columns = 0;
  std::vector<unsigned char> values;
};

MpScriptLogicalResult mpfr_script_compare (
  const MpfrElementwiseOperand& lhs,
  const MpfrElementwiseOperand& rhs,
  MpScriptComparisonOperation operation);

MpScriptLogicalResult mpc_script_compare (
  const MpcElementwiseOperand& lhs,
  const MpcElementwiseOperand& rhs,
  MpScriptComparisonOperation operation);

MpScriptLogicalResult mpfr_script_logical (
  const MpfrElementwiseOperand& source);

MpScriptLogicalResult mpc_script_logical (
  const MpcElementwiseOperand& source);

MpScriptLogicalResult mpfr_script_logical_binary (
  const MpfrElementwiseOperand& lhs,
  const MpfrElementwiseOperand& rhs,
  MpScriptLogicalOperation operation);

MpScriptLogicalResult mpc_script_logical_binary (
  const MpcElementwiseOperand& lhs,
  const MpcElementwiseOperand& rhs,
  MpScriptLogicalOperation operation);

} // namespace octave_mplapack

#endif
