// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_SVD_H
#define OCTAVE_MPLAPACK_MP_SVD_H

#include <stdexcept>

#include "mp_complex_matrix_storage.h"
#include "mp_matrix_storage.h"

namespace octave_mplapack
{

class MpfrSvdError : public std::runtime_error
{
public:
  enum class Kind
  {
    convergence,
    invalid_argument,
    internal
  };

  MpfrSvdError (Kind kind, MpfrMatrixStorage::MplapackInteger info,
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

class MpcSvdError : public std::runtime_error
{
public:
  enum class Kind
  {
    convergence,
    invalid_argument,
    internal
  };

  MpcSvdError (Kind kind, MpfrComplexMatrixStorage::MplapackInteger info,
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

struct MpfrSvdResult
{
  MpfrMatrixStorage u;
  MpfrMatrixStorage s;
  MpfrMatrixStorage v;
};

struct MpcSvdResult
{
  MpfrComplexMatrixStorage u;
  MpfrMatrixStorage s;
  MpfrComplexMatrixStorage v;
};

MpfrSvdResult mplapack_mpfr_matrix_svd (const MpfrMatrixStorage& input,
                                        bool economy);

MpcSvdResult mplapack_mpc_matrix_svd (
  const MpfrComplexMatrixStorage& input, bool economy);

} // namespace octave_mplapack

#endif
