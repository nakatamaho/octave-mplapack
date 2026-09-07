// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_GENERALIZED_EIG_H
#define OCTAVE_MPLAPACK_MP_GENERALIZED_EIG_H

#include <stdexcept>
#include <string>
#include <variant>

#include "mp_complex_matrix_storage.h"
#include "mp_matrix_storage.h"

namespace octave_mplapack
{

enum class GeneralizedEigAlgorithm
{
  auto_select,
  chol,
  qz
};

class MpGeneralizedEigError : public std::runtime_error
{
public:
  MpGeneralizedEigError (int info, const char *message)
    : std::runtime_error (message), m_info (info)
  {
  }

  int info () const noexcept { return m_info; }

private:
  int m_info;
};

struct MpGeneralizedRealDefiniteEigResult
{
  MpfrMatrixStorage eigenvalues;
  MpfrMatrixStorage right_vectors;
  MpfrMatrixStorage left_vectors;
  MpfrMatrixStorage diagonal;
};

struct MpGeneralizedComplexDefiniteEigResult
{
  MpfrMatrixStorage eigenvalues;
  MpfrComplexMatrixStorage right_vectors;
  MpfrComplexMatrixStorage left_vectors;
  MpfrMatrixStorage diagonal;
};

struct MpGeneralizedQzEigResult
{
  MpfrComplexMatrixStorage eigenvalues;
  MpfrComplexMatrixStorage right_vectors;
  MpfrComplexMatrixStorage left_vectors;
  MpfrComplexMatrixStorage diagonal;
};

using MpGeneralizedEigResult = std::variant<
  MpGeneralizedRealDefiniteEigResult,
  MpGeneralizedComplexDefiniteEigResult,
  MpGeneralizedQzEigResult>;

MpGeneralizedEigResult mplapack_mpfr_matrix_generalized_eig (
  const MpfrMatrixStorage& a, const MpfrMatrixStorage& b,
  GeneralizedEigAlgorithm algorithm);

MpGeneralizedEigResult mplapack_mpc_matrix_generalized_eig (
  const MpfrComplexMatrixStorage& a, const MpfrComplexMatrixStorage& b,
  GeneralizedEigAlgorithm algorithm);

} // namespace octave_mplapack

#endif
