// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_COMPLEX_CHOLESKY_H
#define OCTAVE_MPLAPACK_MP_COMPLEX_CHOLESKY_H

#include <stdexcept>

#include "mp_complex_matrix_storage.h"

namespace octave_mplapack
{

class MpcCpotrfError : public std::runtime_error
{
public:
  enum class Kind
  {
    invalid_argument,
    internal
  };

  MpcCpotrfError (Kind kind,
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

struct MpcCholeskyResult
{
  MpfrComplexMatrixStorage factor;
  MpfrComplexMatrixStorage::MplapackInteger info;
};

void require_mplapack_mpc_cpotrf_precision_contract (
  mpfr_prec_t operation_precision,
  const MpfrComplexMatrixStorage& a_work);

MpcCholeskyResult mplapack_mpc_matrix_cholesky (
  const MpfrComplexMatrixStorage& input, bool lower);

} // namespace octave_mplapack

#endif
