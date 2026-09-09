// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_GENERAL_EIG_H
#define OCTAVE_MPLAPACK_MP_GENERAL_EIG_H

#include <stdexcept>
#include <string>

#include "mp_complex_matrix_storage.h"
#include "mp_matrix_storage.h"

namespace octave_mplapack
{

class MpfrGeneralEigError : public std::runtime_error
{
public:
  MpfrGeneralEigError (int info, const char *message)
    : std::runtime_error (message), m_info (info)
  {
  }

  int info () const noexcept { return m_info; }

private:
  int m_info;
};

class MpcGeneralEigError : public std::runtime_error
{
public:
  MpcGeneralEigError (int info, const char *message)
    : std::runtime_error (message), m_info (info)
  {
  }

  int info () const noexcept { return m_info; }

private:
  int m_info;
};

struct MpfrGeneralEigResult
{
  MpfrComplexMatrixStorage eigenvalues;
  MpfrComplexMatrixStorage right_vectors;
  MpfrComplexMatrixStorage left_vectors;
  MpfrComplexMatrixStorage diagonal;
};

struct MpcGeneralEigResult
{
  MpfrComplexMatrixStorage eigenvalues;
  MpfrComplexMatrixStorage right_vectors;
  MpfrComplexMatrixStorage left_vectors;
  MpfrComplexMatrixStorage diagonal;
};

MpfrGeneralEigResult mplapack_mpfr_matrix_general_eig (
  const MpfrMatrixStorage& input, bool balance);

MpcGeneralEigResult mplapack_mpc_matrix_general_eig (
  const MpfrComplexMatrixStorage& input, bool balance);

} // namespace octave_mplapack

#endif
