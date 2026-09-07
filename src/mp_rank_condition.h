// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_RANK_CONDITION_H
#define OCTAVE_MPLAPACK_MP_RANK_CONDITION_H

#include <stdexcept>

#include "mp_complex_matrix_storage.h"
#include "mp_matrix_storage.h"
#include "mp_scalar_storage.h"

namespace octave_mplapack
{

enum class MpfrConditionKind
{
  one,
  two,
  infinity,
  frobenius
};

class MpfrRankConditionError : public std::runtime_error
{
public:
  enum class Kind
  {
    invalid_argument,
    internal
  };

  MpfrRankConditionError (Kind kind, MpfrMatrixStorage::MplapackInteger info,
                          const char *message)
    : std::runtime_error (message), m_kind (kind), m_info (info)
  {
  }

  Kind kind () const noexcept { return m_kind; }
  MpfrMatrixStorage::MplapackInteger info () const noexcept { return m_info; }

private:
  Kind m_kind;
  MpfrMatrixStorage::MplapackInteger m_info;
};

class MpcRankConditionError : public std::runtime_error
{
public:
  enum class Kind
  {
    invalid_argument,
    internal
  };

  MpcRankConditionError (Kind kind,
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

MpfrMatrixStorage::MplapackInteger mplapack_mpfr_matrix_rank (
  const MpfrMatrixStorage& input, const MpfrScalarStorage *tolerance = nullptr);

MpfrComplexMatrixStorage::MplapackInteger mplapack_mpc_matrix_rank (
  const MpfrComplexMatrixStorage& input,
  const MpfrScalarStorage *tolerance = nullptr);

MpfrScalarStorage mplapack_mpfr_matrix_condition (
  const MpfrMatrixStorage& input, MpfrConditionKind kind);

MpfrScalarStorage mplapack_mpc_matrix_condition (
  const MpfrComplexMatrixStorage& input, MpfrConditionKind kind);

MpfrScalarStorage mplapack_mpfr_matrix_rcond (
  const MpfrMatrixStorage& input);

MpfrScalarStorage mplapack_mpc_matrix_rcond (
  const MpfrComplexMatrixStorage& input);

} // namespace octave_mplapack

#endif
