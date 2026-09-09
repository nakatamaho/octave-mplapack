// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_COMPLEX_LU_H
#define OCTAVE_MPLAPACK_MP_COMPLEX_LU_H

#include <stdexcept>
#include <vector>

#include "mp_complex_matrix_storage.h"

namespace octave_mplapack
{

class MpcCgetrfError : public std::runtime_error
{
public:
  enum class Kind
  {
    invalid_argument,
    internal
  };

  MpcCgetrfError (Kind kind,
                  MpfrComplexMatrixStorage::MplapackInteger info,
                  const char *message)
    : std::runtime_error (message), m_kind (kind), m_info (info)
  {
  }

  Kind kind () const noexcept { return m_kind; }
  MpfrComplexMatrixStorage::MplapackInteger info () const noexcept
  { return m_info; }

private:
  Kind m_kind;
  MpfrComplexMatrixStorage::MplapackInteger m_info;
};

struct MpcLuResult
{
  MpfrComplexMatrixStorage packed;
  MpfrComplexMatrixStorage lower;
  MpfrComplexMatrixStorage upper;
  std::vector<MpfrComplexMatrixStorage::MplapackInteger> permutation;
  MpfrComplexMatrixStorage::MplapackInteger info;
};

void require_mplapack_mpc_lu_precision_contract (
  mpfr_prec_t operation_precision,
  const MpfrComplexMatrixStorage& a_work);

MpcLuResult mplapack_mpc_matrix_lu (
  const MpfrComplexMatrixStorage& input);

} // namespace octave_mplapack

#endif
