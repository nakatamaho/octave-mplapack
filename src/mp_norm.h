// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_NORM_H
#define OCTAVE_MPLAPACK_MP_NORM_H

#include <stdexcept>

#include "mp_complex_matrix_storage.h"
#include "mp_matrix_storage.h"
#include "mp_scalar_storage.h"

namespace octave_mplapack
{

struct MpfrNormRequest
{
  enum class Kind
  {
    one,
    two,
    infinity,
    negative_infinity,
    frobenius,
    zero,
    finite
  };

  Kind kind;
  double exponent = 2.0;
};

class MpfrNormError : public std::runtime_error
{
public:
  explicit MpfrNormError (const char *message)
    : std::runtime_error (message)
  {
  }
};

MpfrScalarStorage mplapack_mpfr_norm (
  const MpfrMatrixStorage& input, const MpfrNormRequest& request);

MpfrScalarStorage mplapack_mpc_norm (
  const MpfrComplexMatrixStorage& input, const MpfrNormRequest& request);

// This is intentionally a private backend-facing helper.  N02 reuses it to
// implement the public SVD API without introducing a second matrix-2-norm
// implementation.
MpfrMatrixStorage mplapack_mpfr_singular_values (
  const MpfrMatrixStorage& input);

MpfrMatrixStorage mplapack_mpc_singular_values (
  const MpfrComplexMatrixStorage& input);

} // namespace octave_mplapack

#endif
