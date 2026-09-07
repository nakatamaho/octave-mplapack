// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_STRUCTURED_EIG_H
#define OCTAVE_MPLAPACK_MP_STRUCTURED_EIG_H

#include <stdexcept>

#include "mp_complex_matrix_storage.h"
#include "mp_matrix_storage.h"

namespace octave_mplapack
{

class MpfrStructuredEigError : public std::runtime_error
{
public:
  MpfrStructuredEigError (int info, const char *message)
    : std::runtime_error (message), m_info (info)
  {
  }

  int info () const noexcept { return m_info; }

private:
  int m_info;
};

class MpcStructuredEigError : public std::runtime_error
{
public:
  MpcStructuredEigError (int info, const char *message)
    : std::runtime_error (message), m_info (info)
  {
  }

  int info () const noexcept { return m_info; }

private:
  int m_info;
};

struct MpfrStructuredEigResult
{
  MpfrMatrixStorage eigenvalues;
  MpfrMatrixStorage vectors;
  MpfrMatrixStorage diagonal;
};

struct MpcStructuredEigResult
{
  MpfrMatrixStorage eigenvalues;
  MpfrComplexMatrixStorage vectors;
  MpfrMatrixStorage diagonal;
};

MpfrStructuredEigResult mplapack_mpfr_matrix_structured_eig (
  const MpfrMatrixStorage& input);

MpcStructuredEigResult mplapack_mpc_matrix_structured_eig (
  const MpfrComplexMatrixStorage& input);

} // namespace octave_mplapack

#endif
