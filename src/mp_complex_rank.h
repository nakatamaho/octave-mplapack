// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_COMPLEX_RANK_H
#define OCTAVE_MPLAPACK_MP_COMPLEX_RANK_H

#include <stdexcept>

#include "mp_complex_matrix_storage.h"
#include "mp_matrix_storage.h"

namespace octave_mplapack
{

class MpcCgelsyError : public std::runtime_error
{
public:
  enum class Kind
  {
    convergence,
    invalid_argument,
    internal
  };

  MpcCgelsyError (Kind kind, MpfrComplexMatrixStorage::MplapackInteger info,
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

struct MpcRankRevealingSolveResult
{
  MpfrComplexMatrixStorage solution;
  MpfrComplexMatrixStorage::MplapackInteger rank;
};

void require_mplapack_mpc_rank_precision_contract (
  mpfr_prec_t operation_precision,
  const MpfrComplexMatrixStorage& a_work,
  const MpfrComplexMatrixStorage& b_work,
  const mpfrxx::mpfr_class& rcond,
  const MpfrComplexMatrixStorage& work,
  const MpfrMatrixStorage& rwork);

MpcRankRevealingSolveResult mplapack_mpc_matrix_rank_solve (
  const MpfrComplexMatrixStorage& lhs,
  const MpfrComplexMatrixStorage& rhs);

} // namespace octave_mplapack

#endif
