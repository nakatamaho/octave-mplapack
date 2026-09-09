// SPDX-License-Identifier: BSD-2-Clause

#include "mp_norm.h"

#include <algorithm>
#include <cmath>
#include <cstddef>
#include <cstdint>
#include <limits>
#include <stdexcept>
#include <type_traits>
#include <utility>

#include <mpblas_mpfr.h>
#include <mplapack_mpfr.h>

#include "mp_complex_blas.h"
#include "mp_complex_precision.h"

namespace
{

using octave_mplapack::MpfrComplexMatrixStorage;
using octave_mplapack::MpfrMatrixStorage;
using octave_mplapack::MpfrNormRequest;
using octave_mplapack::MpfrScalarStorage;

void
validate_precision (mpfr_prec_t precision_bits)
{
  if (precision_bits < MPFR_PREC_MIN || precision_bits > MPFR_PREC_MAX)
    throw std::invalid_argument ("MPLAPACK norm precision is outside MPFR limits");
}

MpfrScalarStorage::NativeScalar
make_zero (mpfr_prec_t precision_bits)
{
  auto result = MpfrScalarStorage::NativeScalar::with_precision (precision_bits);
  mpfr_set_zero (result.mpfr_data (), 1);
  return result;
}

MpfrScalarStorage::NativeScalar
absolute_value (const MpfrScalarStorage::NativeScalar& value,
                mpfr_prec_t precision_bits)
{
  auto result = MpfrScalarStorage::NativeScalar::with_precision (precision_bits);
  mpfr_abs (result.mpfr_data (), value.mpfr_data (), MPFR_RNDN);
  return result;
}

MpfrScalarStorage::NativeScalar
absolute_value (const octave_mplapack::MpfrComplexScalarStorage::NativeScalar& value,
                mpfr_prec_t precision_bits)
{
  auto result = MpfrScalarStorage::NativeScalar::with_precision (precision_bits);
  mpc_abs (result.mpfr_data (), value.mpc_data (), MPFR_RNDN);
  return result;
}

template <typename Matrix>
MpfrScalarStorage
maximum_abs (const Matrix& input)
{
  const mpfr_prec_t precision_bits = input.precision_bits ();
  auto result = make_zero (precision_bits);
  for (std::size_t index = 0; index < input.numel (); ++index)
    {
      auto value = absolute_value (input.data ()[index], precision_bits);
      if (mpfr_nan_p (value.mpfr_data ()) != 0
          || mpfr_cmp (value.mpfr_data (), result.mpfr_data ()) > 0)
        mpfr_set (result.mpfr_data (), value.mpfr_data (), MPFR_RNDN);
    }
  return MpfrScalarStorage (std::move (result));
}

template <typename Matrix>
MpfrScalarStorage
minimum_abs (const Matrix& input)
{
  const mpfr_prec_t precision_bits = input.precision_bits ();
  if (input.numel () == 0)
    return MpfrScalarStorage (make_zero (precision_bits));

  auto result = absolute_value (input.data ()[0], precision_bits);
  for (std::size_t index = 1; index < input.numel (); ++index)
    {
      auto value = absolute_value (input.data ()[index], precision_bits);
      if (mpfr_nan_p (value.mpfr_data ()) != 0
          || mpfr_cmp (value.mpfr_data (), result.mpfr_data ()) < 0)
        mpfr_set (result.mpfr_data (), value.mpfr_data (), MPFR_RNDN);
    }
  return MpfrScalarStorage (std::move (result));
}

template <typename Matrix>
MpfrScalarStorage
zero_count (const Matrix& input)
{
  const mpfr_prec_t precision_bits = input.precision_bits ();
  auto result = make_zero (precision_bits);
  for (std::size_t index = 0; index < input.numel (); ++index)
    {
      const auto value = absolute_value (input.data ()[index], precision_bits);
      if (mpfr_zero_p (value.mpfr_data ()) == 0)
        mpfr_add_ui (result.mpfr_data (), result.mpfr_data (), 1, MPFR_RNDN);
    }
  return MpfrScalarStorage (std::move (result));
}

template <typename Matrix>
MpfrScalarStorage
finite_vector_norm (const Matrix& input, double exponent)
{
  const mpfr_prec_t precision_bits = input.precision_bits ();
  auto sum = make_zero (precision_bits);
  auto p = MpfrScalarStorage::NativeScalar::with_precision (precision_bits);
  auto reciprocal = MpfrScalarStorage::NativeScalar::with_precision (
    precision_bits);
  mpfr_set_d (p.mpfr_data (), exponent, MPFR_RNDN);
  mpfr_set_d (reciprocal.mpfr_data (), 1.0 / exponent, MPFR_RNDN);

  for (std::size_t index = 0; index < input.numel (); ++index)
    {
      auto absolute = absolute_value (input.data ()[index], precision_bits);
      auto term = MpfrScalarStorage::NativeScalar::with_precision (
        precision_bits);
      mpfr_pow (term.mpfr_data (), absolute.mpfr_data (), p.mpfr_data (),
                MPFR_RNDN);
      mpfr_add (sum.mpfr_data (), sum.mpfr_data (), term.mpfr_data (),
                MPFR_RNDN);
    }

  auto result = MpfrScalarStorage::NativeScalar::with_precision (precision_bits);
  if (input.numel () == 0)
    mpfr_set_zero (result.mpfr_data (), 1);
  else
    mpfr_pow (result.mpfr_data (), sum.mpfr_data (), reciprocal.mpfr_data (),
              MPFR_RNDN);
  return MpfrScalarStorage (std::move (result));
}

MpfrScalarStorage
real_vector_norm (const MpfrMatrixStorage& input, const MpfrNormRequest& request)
{
  const mpfr_prec_t precision_bits = input.precision_bits ();
  switch (request.kind)
    {
    case MpfrNormRequest::Kind::one:
      {
        auto result = make_zero (precision_bits);
        for (std::size_t index = 0; index < input.numel (); ++index)
          {
            auto value = absolute_value (input.data ()[index], precision_bits);
            mpfr_add (result.mpfr_data (), result.mpfr_data (),
                      value.mpfr_data (), MPFR_RNDN);
          }
        return MpfrScalarStorage (std::move (result));
      }
    case MpfrNormRequest::Kind::two:
    case MpfrNormRequest::Kind::frobenius:
      {
        if (input.numel () == 0)
          return MpfrScalarStorage (make_zero (precision_bits));
        auto work = MpfrMatrixStorage (input.rows (), input.columns (),
                                       precision_bits, input);
        MplapackMpfrPrecisionScope scope (precision_bits);
        auto result = Rnrm2 (
          MpfrMatrixStorage::checked_mplapack_dimension (input.numel ()),
          work.data (), 1);
        return MpfrScalarStorage (std::move (result));
      }
    case MpfrNormRequest::Kind::infinity:
      return maximum_abs (input);
    case MpfrNormRequest::Kind::negative_infinity:
      return minimum_abs (input);
    case MpfrNormRequest::Kind::zero:
      return zero_count (input);
    case MpfrNormRequest::Kind::finite:
      return finite_vector_norm (input, request.exponent);
    }
  throw std::logic_error ("unknown real vector norm kind");
}

MpfrScalarStorage
complex_vector_norm (const MpfrComplexMatrixStorage& input,
                     const MpfrNormRequest& request)
{
  const mpfr_prec_t precision_bits = input.precision_bits ();
  switch (request.kind)
    {
    case MpfrNormRequest::Kind::one:
    case MpfrNormRequest::Kind::frobenius:
    case MpfrNormRequest::Kind::infinity:
    case MpfrNormRequest::Kind::negative_infinity:
    case MpfrNormRequest::Kind::zero:
      if (request.kind == MpfrNormRequest::Kind::one)
        {
          auto result = make_zero (precision_bits);
          for (std::size_t index = 0; index < input.numel (); ++index)
            {
              auto value = absolute_value (input.data ()[index], precision_bits);
              mpfr_add (result.mpfr_data (), result.mpfr_data (),
                        value.mpfr_data (), MPFR_RNDN);
            }
          return MpfrScalarStorage (std::move (result));
        }
      if (request.kind == MpfrNormRequest::Kind::infinity)
        return maximum_abs (input);
      if (request.kind == MpfrNormRequest::Kind::negative_infinity)
        return minimum_abs (input);
      if (request.kind == MpfrNormRequest::Kind::zero)
        return zero_count (input);
      break;
    case MpfrNormRequest::Kind::two:
      {
        if (input.numel () == 0)
          return MpfrScalarStorage (make_zero (precision_bits));
        auto work = octave_mplapack::mplapack_mpc_matrix_copy_at_precision (
          input, precision_bits);
        octave_mplapack::MpfrMpcPrecisionScope scope (precision_bits);
        auto result = RCnrm2 (
          MpfrComplexMatrixStorage::checked_mplapack_dimension (input.numel ()),
          work.data (), 1);
        return MpfrScalarStorage (std::move (result));
      }
    case MpfrNormRequest::Kind::finite:
      return finite_vector_norm (input, request.exponent);
    }
  // The only fall-through is Frobenius, which is the vector 2-norm of all
  // entries and uses the same MPFR/MPC-native BLAS path.
  auto work = octave_mplapack::mplapack_mpc_matrix_copy_at_precision (
    input, precision_bits);
  octave_mplapack::MpfrMpcPrecisionScope scope (precision_bits);
  auto result = RCnrm2 (
    MpfrComplexMatrixStorage::checked_mplapack_dimension (input.numel ()),
    work.data (), 1);
  return MpfrScalarStorage (std::move (result));
}

MpfrScalarStorage
real_matrix_standard_norm (const MpfrMatrixStorage& input,
                           const MpfrNormRequest& request)
{
  const mpfr_prec_t precision_bits = input.precision_bits ();
  if (input.numel () == 0)
    return MpfrScalarStorage (make_zero (precision_bits));

  auto work = MpfrMatrixStorage (input.rows (), input.columns (),
                                 precision_bits, input);
  MpfrMatrixStorage work_space (
    request.kind == MpfrNormRequest::Kind::infinity ? input.rows () : 1, 1,
    precision_bits);
  const char norm_code
    = request.kind == MpfrNormRequest::Kind::one
        ? '1'
        : request.kind == MpfrNormRequest::Kind::infinity ? 'I' : 'F';
  MplapackMpfrPrecisionScope scope (precision_bits);
  auto result = Rlange (&norm_code,
                        MpfrMatrixStorage::checked_mplapack_dimension (
                          input.rows ()),
                        MpfrMatrixStorage::checked_mplapack_dimension (
                          input.columns ()),
                        work.data (), work.leading_dimension (),
                        work_space.data ());
  return MpfrScalarStorage (std::move (result));
}

MpfrScalarStorage
complex_matrix_standard_norm (const MpfrComplexMatrixStorage& input,
                              const MpfrNormRequest& request)
{
  const mpfr_prec_t precision_bits = input.precision_bits ();
  if (input.numel () == 0)
    return MpfrScalarStorage (make_zero (precision_bits));

  auto work = octave_mplapack::mplapack_mpc_matrix_copy_at_precision (
    input, precision_bits);
  MpfrMatrixStorage work_space (
    request.kind == MpfrNormRequest::Kind::infinity ? input.rows () : 1, 1,
    precision_bits);
  const char norm_code
    = request.kind == MpfrNormRequest::Kind::one
        ? '1'
        : request.kind == MpfrNormRequest::Kind::infinity ? 'I' : 'F';
  octave_mplapack::MpfrMpcPrecisionScope scope (precision_bits);
  auto result = Clange (&norm_code,
                        MpfrComplexMatrixStorage::checked_mplapack_dimension (
                          input.rows ()),
                        MpfrComplexMatrixStorage::checked_mplapack_dimension (
                          input.columns ()),
                        work.data (), work.leading_dimension (),
                        work_space.data ());
  return MpfrScalarStorage (std::move (result));
}

mpfr_prec_t
checked_workspace_length (const MpfrScalarStorage::NativeScalar& query)
{
  if (mpfr_nan_p (query.mpfr_data ()) != 0
      || mpfr_inf_p (query.mpfr_data ()) != 0
      || mpfr_sgn (query.mpfr_data ()) <= 0
      || mpfr_integer_p (query.mpfr_data ()) == 0)
    throw std::runtime_error ("MPLAPACK SVD returned an invalid workspace query");
  const auto value = mpfr_get_uj (query.mpfr_data (), MPFR_RNDZ);
  if (value > static_cast<std::uintmax_t> (std::numeric_limits<mpfr_prec_t>::max ()))
    throw std::overflow_error ("MPLAPACK SVD workspace is too large");
  return static_cast<mpfr_prec_t> (value);
}

MpfrMatrixStorage
real_singular_values (const MpfrMatrixStorage& input)
{
  const mpfr_prec_t precision_bits = input.precision_bits ();
  validate_precision (precision_bits);
  const std::size_t m = input.rows ();
  const std::size_t n = input.columns ();
  const std::size_t k = std::min (m, n);
  MpfrMatrixStorage result (k, 1, precision_bits);
  if (k == 0)
    return result;

  auto a_work = MpfrMatrixStorage (m, n, precision_bits, input);
  MpfrMatrixStorage u (1, 1, precision_bits);
  MpfrMatrixStorage vt (1, 1, precision_bits);
  MpfrMatrixStorage query_work (1, 1, precision_bits);
  MpfrMatrixStorage::MplapackInteger info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision_bits);
    Rgesvd ("N", "N",
            MpfrMatrixStorage::checked_mplapack_dimension (m),
            MpfrMatrixStorage::checked_mplapack_dimension (n),
            a_work.data (), a_work.leading_dimension (), result.data (),
            u.data (), 1, vt.data (), 1, query_work.data (), -1, info);
    if (info != 0)
      throw std::runtime_error ("MPLAPACK Rgesvd workspace query failed");
    const auto lwork = checked_workspace_length (query_work.at (0, 0));
    MpfrMatrixStorage work (static_cast<std::size_t> (lwork), 1,
                            precision_bits);
    a_work = MpfrMatrixStorage (m, n, precision_bits, input);
    Rgesvd ("N", "N",
            MpfrMatrixStorage::checked_mplapack_dimension (m),
            MpfrMatrixStorage::checked_mplapack_dimension (n),
            a_work.data (), a_work.leading_dimension (), result.data (),
            u.data (), 1, vt.data (), 1, work.data (), lwork, info);
  }
  if (info != 0)
    throw std::runtime_error ("MPLAPACK Rgesvd failed to converge");
  return result;
}

MpfrMatrixStorage
complex_singular_values (const MpfrComplexMatrixStorage& input)
{
  const mpfr_prec_t precision_bits = input.precision_bits ();
  validate_precision (precision_bits);
  const std::size_t m = input.rows ();
  const std::size_t n = input.columns ();
  const std::size_t k = std::min (m, n);
  MpfrMatrixStorage result (k, 1, precision_bits);
  if (k == 0)
    return result;

  auto a_work = octave_mplapack::mplapack_mpc_matrix_copy_at_precision (
    input, precision_bits);
  MpfrComplexMatrixStorage u (1, 1, precision_bits);
  MpfrComplexMatrixStorage vt (1, 1, precision_bits);
  MpfrComplexMatrixStorage query_work (1, 1, precision_bits);
  MpfrMatrixStorage rwork (5 * k, 1, precision_bits);
  MpfrComplexMatrixStorage::MplapackInteger info = 0;
  {
    octave_mplapack::MpfrMpcPrecisionScope scope (precision_bits);
    Cgesvd ("N", "N",
            MpfrComplexMatrixStorage::checked_mplapack_dimension (m),
            MpfrComplexMatrixStorage::checked_mplapack_dimension (n),
            a_work.data (), a_work.leading_dimension (), result.data (),
            u.data (), 1, vt.data (), 1, query_work.data (), -1,
            rwork.data (), info);
    if (info != 0)
      throw std::runtime_error ("MPLAPACK Cgesvd workspace query failed");
    const auto& query = query_work.at (0, 0);
    auto query_real = MpfrScalarStorage::NativeScalar::with_precision (
      precision_bits);
    mpfr_set (query_real.mpfr_data (), mpc_realref (query.mpc_data ()),
              MPFR_RNDN);
    const auto actual_lwork = checked_workspace_length (query_real);
    MpfrComplexMatrixStorage work (static_cast<std::size_t> (actual_lwork),
                                   1, precision_bits);
    a_work = octave_mplapack::mplapack_mpc_matrix_copy_at_precision (
      input, precision_bits);
    Cgesvd ("N", "N",
            MpfrComplexMatrixStorage::checked_mplapack_dimension (m),
            MpfrComplexMatrixStorage::checked_mplapack_dimension (n),
            a_work.data (), a_work.leading_dimension (), result.data (),
            u.data (), 1, vt.data (), 1, work.data (), actual_lwork,
            rwork.data (), info);
  }
  if (info != 0)
    throw std::runtime_error ("MPLAPACK Cgesvd failed to converge");
  return result;
}

template <typename Matrix>
MpfrScalarStorage
largest_singular_value (const Matrix& input)
{
  if (input.numel () == 0)
    return MpfrScalarStorage (make_zero (input.precision_bits ()));
  auto values = [&] {
    if constexpr (std::is_same_v<Matrix, MpfrMatrixStorage>)
      return real_singular_values (input);
    else
      return complex_singular_values (input);
  } ();
  return MpfrScalarStorage (std::move (values.at (0, 0)));
}

} // namespace

namespace octave_mplapack
{

MpfrScalarStorage
mplapack_mpfr_norm (const MpfrMatrixStorage& input,
                    const MpfrNormRequest& request)
{
  validate_precision (input.precision_bits ());
  const bool vector = input.rows () == 1 || input.columns () == 1;
  if (vector)
    return real_vector_norm (input, request);
  if (request.kind == MpfrNormRequest::Kind::two)
    return largest_singular_value (input);
  if (request.kind == MpfrNormRequest::Kind::one
      || request.kind == MpfrNormRequest::Kind::infinity
      || request.kind == MpfrNormRequest::Kind::frobenius)
    return real_matrix_standard_norm (input, request);
  throw std::invalid_argument (
    "matrix norm supports only 1, 2, Inf, and fro norms");
}

MpfrScalarStorage
mplapack_mpc_norm (const MpfrComplexMatrixStorage& input,
                   const MpfrNormRequest& request)
{
  validate_precision (input.precision_bits ());
  const bool vector = input.rows () == 1 || input.columns () == 1;
  if (vector)
    return complex_vector_norm (input, request);
  if (request.kind == MpfrNormRequest::Kind::two)
    return largest_singular_value (input);
  if (request.kind == MpfrNormRequest::Kind::one
      || request.kind == MpfrNormRequest::Kind::infinity
      || request.kind == MpfrNormRequest::Kind::frobenius)
    return complex_matrix_standard_norm (input, request);
  throw std::invalid_argument (
    "matrix norm supports only 1, 2, Inf, and fro norms");
}

MpfrMatrixStorage
mplapack_mpfr_singular_values (const MpfrMatrixStorage& input)
{
  return real_singular_values (input);
}

MpfrMatrixStorage
mplapack_mpc_singular_values (const MpfrComplexMatrixStorage& input)
{
  return complex_singular_values (input);
}

} // namespace octave_mplapack
