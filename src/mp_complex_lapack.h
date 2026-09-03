// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_COMPLEX_LAPACK_H
#define OCTAVE_MPLAPACK_MP_COMPLEX_LAPACK_H

#include <stdexcept>

#include "mp_complex_matrix_storage.h"

namespace octave_mplapack
{

class MpcCgesvError : public std::runtime_error
{
public:
  enum class Kind
  {
    singular,
    invalid_argument
  };

  MpcCgesvError (Kind kind, MpfrComplexMatrixStorage::MplapackInteger info,
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

void require_mplapack_mpc_solve_precision_contract (
  mpfr_prec_t operation_precision,
  const MpfrComplexMatrixStorage& a_work,
  const MpfrComplexMatrixStorage& b_work);

MpfrComplexMatrixStorage mplapack_mpc_matrix_solve (
  const MpfrComplexMatrixStorage& lhs,
  const MpfrComplexMatrixStorage& rhs);

} // namespace octave_mplapack

#endif
