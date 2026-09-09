// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_DET_INV_H
#define OCTAVE_MPLAPACK_MP_DET_INV_H

#include <stdexcept>

#include "mp_complex_matrix_storage.h"
#include "mp_complex_scalar_storage.h"
#include "mp_matrix_storage.h"
#include "mp_scalar_storage.h"

namespace octave_mplapack
{

class MpfrDetInvError : public std::runtime_error
{
public:
  enum class Kind
  {
    singular,
    invalid_argument,
    internal
  };

  MpfrDetInvError (Kind kind, MpfrMatrixStorage::MplapackInteger info,
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

class MpcDetInvError : public std::runtime_error
{
public:
  enum class Kind
  {
    singular,
    invalid_argument,
    internal
  };

  MpcDetInvError (Kind kind,
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

MpfrScalarStorage mplapack_mpfr_matrix_det (const MpfrMatrixStorage& input);

MpfrMatrixStorage mplapack_mpfr_matrix_inverse (
  const MpfrMatrixStorage& input);

MpfrComplexScalarStorage mplapack_mpc_matrix_det (
  const MpfrComplexMatrixStorage& input);

MpfrComplexMatrixStorage mplapack_mpc_matrix_inverse (
  const MpfrComplexMatrixStorage& input);

} // namespace octave_mplapack

#endif
