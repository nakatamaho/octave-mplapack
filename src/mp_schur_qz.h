// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_SCHUR_QZ_H
#define OCTAVE_MPLAPACK_MP_SCHUR_QZ_H

#include <variant>

#include "mp_complex_matrix_storage.h"
#include "mp_matrix_storage.h"

namespace octave_mplapack
{

struct MpHessResult
{
  MpfrMatrixStorage p;
  MpfrMatrixStorage h;
};

struct MpcHessResult
{
  MpfrComplexMatrixStorage p;
  MpfrComplexMatrixStorage h;
};

struct MpSchurResult
{
  MpfrMatrixStorage u;
  MpfrMatrixStorage s;
};

struct MpcSchurResult
{
  MpfrComplexMatrixStorage u;
  MpfrComplexMatrixStorage s;
};

struct MpQzResult
{
  MpfrMatrixStorage aa;
  MpfrMatrixStorage bb;
  MpfrMatrixStorage q;
  MpfrMatrixStorage z;
};

struct MpcQzResult
{
  MpfrComplexMatrixStorage aa;
  MpfrComplexMatrixStorage bb;
  MpfrComplexMatrixStorage q;
  MpfrComplexMatrixStorage z;
};

MpHessResult mplapack_mpfr_hess (const MpfrMatrixStorage& input);
MpcHessResult mplapack_mpc_hess (const MpfrComplexMatrixStorage& input);

MpSchurResult mplapack_mpfr_schur (const MpfrMatrixStorage& input);
MpcSchurResult mplapack_mpc_schur (const MpfrComplexMatrixStorage& input);

MpQzResult mplapack_mpfr_qz (const MpfrMatrixStorage& input_a,
                             const MpfrMatrixStorage& input_b);
MpcQzResult mplapack_mpc_qz (const MpfrComplexMatrixStorage& input_a,
                             const MpfrComplexMatrixStorage& input_b);

} // namespace octave_mplapack

#endif
