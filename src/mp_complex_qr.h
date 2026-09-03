// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_COMPLEX_QR_H
#define OCTAVE_MPLAPACK_MP_COMPLEX_QR_H

#include <stdexcept>

#include "mp_complex_matrix_storage.h"

namespace octave_mplapack
{

class MpcQrError : public std::runtime_error
{
public:
  enum class Kind
  {
    invalid_argument,
    internal
  };

  MpcQrError (Kind kind, MpfrComplexMatrixStorage::MplapackInteger info,
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

struct MpcQrResult
{
  MpfrComplexMatrixStorage q;
  MpfrComplexMatrixStorage r;
};

void require_mplapack_mpc_qr_precision_contract (
  mpfr_prec_t operation_precision,
  const MpfrComplexMatrixStorage& a_work,
  const MpfrComplexMatrixStorage& tau,
  const MpfrComplexMatrixStorage& work);

MpcQrResult mplapack_mpc_matrix_qr (const MpfrComplexMatrixStorage& input,
                                    bool economy, bool want_q);

} // namespace octave_mplapack

#endif
