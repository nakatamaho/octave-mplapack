// SPDX-License-Identifier: BSD-2-Clause

#include "mp_script_compat.h"

#include <algorithm>
#include <limits>
#include <stdexcept>
#include <utility>

#include "mp_complex_precision.h"

namespace
{

using namespace octave_mplapack;

void
apply_real_unary (mpfr_ptr destination, mpfr_srcptr source,
                  MpScriptUnaryOperation operation)
{
  switch (operation)
    {
    case MpScriptUnaryOperation::absolute:
      mpfr_abs (destination, source, MPFR_RNDN);
      return;
    case MpScriptUnaryOperation::angle:
      {
        mpfr_t zero;
        mpfr_init2 (zero, mpfr_get_prec (source));
        mpfr_set_zero (zero, 1);
        mpfr_atan2 (destination, zero, source, MPFR_RNDN);
        mpfr_clear (zero);
      }
      return;
    case MpScriptUnaryOperation::sign:
      if (mpfr_nan_p (source))
        mpfr_set_nan (destination);
      else
        mpfr_set_si (destination, mpfr_sgn (source), MPFR_RNDN);
      return;
    }
  throw std::logic_error ("unknown real script unary operation");
}

void
apply_complex_real_unary (mpfr_ptr destination, mpc_srcptr source,
                          MpScriptUnaryOperation operation)
{
  switch (operation)
    {
    case MpScriptUnaryOperation::absolute:
      mpc_abs (destination, source, MPFR_RNDN);
      return;
    case MpScriptUnaryOperation::angle:
      mpc_arg (destination, source, MPFR_RNDN);
      return;
    case MpScriptUnaryOperation::sign:
      throw std::logic_error ("complex sign requires an MPC result");
    }
  throw std::logic_error ("unknown complex real unary operation");
}

void
apply_complex_unary (mpc_ptr destination, mpc_srcptr source,
                     MpScriptUnaryOperation operation)
{
  const mpc_rnd_t rounding = MPC_RND (MPFR_RNDN, MPFR_RNDN);
  switch (operation)
    {
    case MpScriptUnaryOperation::sign:
      if (mpfr_zero_p (mpc_realref (source))
          && mpfr_zero_p (mpc_imagref (source)))
        {
          mpc_set_ui (destination, 0, rounding);
          return;
        }
      {
        mpfr_t magnitude;
        mpfr_init2 (magnitude, mpfr_get_prec (mpc_realref (source)));
        mpc_abs (magnitude, source, MPFR_RNDN);
        mpc_div_fr (destination, source, magnitude, rounding);
        mpfr_clear (magnitude);
      }
      return;
    case MpScriptUnaryOperation::absolute:
    case MpScriptUnaryOperation::angle:
      throw std::logic_error ("complex real-valued operation used as MPC");
    }
  throw std::logic_error ("unknown complex unary operation");
}

bool
predicate_value (mpfr_srcptr source, MpScriptPredicate predicate)
{
  switch (predicate)
    {
    case MpScriptPredicate::isnan:
      return mpfr_nan_p (source) != 0;
    case MpScriptPredicate::isinf:
      return mpfr_inf_p (source) != 0;
    case MpScriptPredicate::isfinite:
      return mpfr_number_p (source) != 0;
    }
  throw std::logic_error ("unknown MPFR script predicate");
}

bool
predicate_value (mpc_srcptr source, MpScriptPredicate predicate)
{
  const mpfr_srcptr real = mpc_realref (source);
  const mpfr_srcptr imag = mpc_imagref (source);
  switch (predicate)
    {
    case MpScriptPredicate::isnan:
      return mpfr_nan_p (real) != 0 || mpfr_nan_p (imag) != 0;
    case MpScriptPredicate::isinf:
      return mpfr_inf_p (real) != 0 || mpfr_inf_p (imag) != 0;
    case MpScriptPredicate::isfinite:
      return mpfr_number_p (real) != 0 && mpfr_number_p (imag) != 0;
    }
  throw std::logic_error ("unknown MPC script predicate");
}

template <typename Storage>
MpScriptPredicateResult
make_predicate_result (const Storage& source, MpScriptPredicate predicate)
{
  MpScriptPredicateResult result;
  result.rows = source.rows ();
  result.columns = source.columns ();
  result.values.resize (source.numel ());
  for (std::size_t index = 0; index < source.numel (); ++index)
    result.values[index] = predicate_value (source.data ()[index].mpfr_data (),
                                            predicate);
  return result;
}

MpScriptPredicateResult
make_complex_predicate_result (const MpfrComplexMatrixStorage& source,
                               MpScriptPredicate predicate)
{
  MpScriptPredicateResult result;
  result.rows = source.rows ();
  result.columns = source.columns ();
  result.values.resize (source.numel ());
  for (std::size_t index = 0; index < source.numel (); ++index)
    result.values[index] = predicate_value (source.data ()[index].mpc_data (),
                                            predicate);
  return result;
}

bool
equal_real (mpfr_srcptr lhs, mpfr_srcptr rhs, bool nan_equal) noexcept
{
  const bool lhs_nan = mpfr_nan_p (lhs) != 0;
  const bool rhs_nan = mpfr_nan_p (rhs) != 0;
  if (lhs_nan || rhs_nan)
    return nan_equal && lhs_nan && rhs_nan;
  return mpfr_cmp (lhs, rhs) == 0;
}

bool
equal_complex (mpc_srcptr lhs, mpc_srcptr rhs, bool nan_equal) noexcept
{
  return equal_real (mpc_realref (lhs), mpc_realref (rhs), nan_equal)
         && equal_real (mpc_imagref (lhs), mpc_imagref (rhs), nan_equal);
}

void
apply_real_elementary (mpfr_ptr destination, mpfr_srcptr source,
                       MpScriptElementaryOperation operation)
{
  switch (operation)
    {
    case MpScriptElementaryOperation::sqrt: mpfr_sqrt (destination, source, MPFR_RNDN); return;
    case MpScriptElementaryOperation::exp: mpfr_exp (destination, source, MPFR_RNDN); return;
    case MpScriptElementaryOperation::expm1: mpfr_expm1 (destination, source, MPFR_RNDN); return;
    case MpScriptElementaryOperation::log: mpfr_log (destination, source, MPFR_RNDN); return;
    case MpScriptElementaryOperation::log1p: mpfr_log1p (destination, source, MPFR_RNDN); return;
    case MpScriptElementaryOperation::log10: mpfr_log10 (destination, source, MPFR_RNDN); return;
    case MpScriptElementaryOperation::log2: mpfr_log2 (destination, source, MPFR_RNDN); return;
    case MpScriptElementaryOperation::sin: mpfr_sin (destination, source, MPFR_RNDN); return;
    case MpScriptElementaryOperation::cos: mpfr_cos (destination, source, MPFR_RNDN); return;
    case MpScriptElementaryOperation::tan: mpfr_tan (destination, source, MPFR_RNDN); return;
    case MpScriptElementaryOperation::asin: mpfr_asin (destination, source, MPFR_RNDN); return;
    case MpScriptElementaryOperation::acos: mpfr_acos (destination, source, MPFR_RNDN); return;
    case MpScriptElementaryOperation::atan: mpfr_atan (destination, source, MPFR_RNDN); return;
    case MpScriptElementaryOperation::sinh: mpfr_sinh (destination, source, MPFR_RNDN); return;
    case MpScriptElementaryOperation::cosh: mpfr_cosh (destination, source, MPFR_RNDN); return;
    case MpScriptElementaryOperation::tanh: mpfr_tanh (destination, source, MPFR_RNDN); return;
    case MpScriptElementaryOperation::asinh: mpfr_asinh (destination, source, MPFR_RNDN); return;
    case MpScriptElementaryOperation::acosh: mpfr_acosh (destination, source, MPFR_RNDN); return;
    case MpScriptElementaryOperation::atanh: mpfr_atanh (destination, source, MPFR_RNDN); return;
    case MpScriptElementaryOperation::cbrt: mpfr_cbrt (destination, source, MPFR_RNDN); return;
    }
  throw std::logic_error ("unknown real elementary operation");
}

mpfr_prec_t
work_precision (mpfr_prec_t precision)
{
  constexpr mpfr_prec_t guard_bits = 32;
  if (precision > MPFR_PREC_MAX - guard_bits)
    return precision;
  return precision + guard_bits;
}

void
apply_complex_elementary (mpc_ptr destination, mpc_srcptr source,
                          MpScriptElementaryOperation operation)
{
  const mpc_rnd_t rounding = MPC_RND (MPFR_RNDN, MPFR_RNDN);
  switch (operation)
    {
    case MpScriptElementaryOperation::sqrt: mpc_sqrt (destination, source, rounding); return;
    case MpScriptElementaryOperation::exp: mpc_exp (destination, source, rounding); return;
    case MpScriptElementaryOperation::log: mpc_log (destination, source, rounding); return;
    case MpScriptElementaryOperation::log10: mpc_log10 (destination, source, rounding); return;
    case MpScriptElementaryOperation::log2: mpc_log2 (destination, source, rounding); return;
    case MpScriptElementaryOperation::sin: mpc_sin (destination, source, rounding); return;
    case MpScriptElementaryOperation::cos: mpc_cos (destination, source, rounding); return;
    case MpScriptElementaryOperation::tan: mpc_tan (destination, source, rounding); return;
    case MpScriptElementaryOperation::asin:
      mpc_asin (destination, source, rounding);
      if (mpfr_zero_p (mpc_imagref (source))
          && mpfr_cmp_ui (mpc_realref (source), 1) > 0)
        mpfr_neg (mpc_imagref (destination), mpc_imagref (destination),
                  MPFR_RNDN);
      return;
    case MpScriptElementaryOperation::acos:
      mpc_acos (destination, source, rounding);
      if (mpfr_zero_p (mpc_imagref (source))
          && mpfr_cmp_ui (mpc_realref (source), 1) > 0)
        mpfr_neg (mpc_imagref (destination), mpc_imagref (destination),
                  MPFR_RNDN);
      return;
    case MpScriptElementaryOperation::atan: mpc_atan (destination, source, rounding); return;
    case MpScriptElementaryOperation::sinh: mpc_sinh (destination, source, rounding); return;
    case MpScriptElementaryOperation::cosh: mpc_cosh (destination, source, rounding); return;
    case MpScriptElementaryOperation::tanh: mpc_tanh (destination, source, rounding); return;
    case MpScriptElementaryOperation::asinh: mpc_asinh (destination, source, rounding); return;
    case MpScriptElementaryOperation::acosh: mpc_acosh (destination, source, rounding); return;
    case MpScriptElementaryOperation::atanh: mpc_atanh (destination, source, rounding); return;
    case MpScriptElementaryOperation::cbrt:
      {
        mpfr_t third;
        mpfr_init2 (third, mpfr_get_prec (mpc_realref (source)));
        mpfr_set_ui (third, 1, MPFR_RNDN);
        mpfr_div_ui (third, third, 3, MPFR_RNDN);
        mpc_pow_fr (destination, source, third, rounding);
        mpfr_clear (third);
      }
      return;
    case MpScriptElementaryOperation::expm1:
    case MpScriptElementaryOperation::log1p:
      {
        const mpfr_prec_t precision = mpfr_get_prec (mpc_realref (source));
        const mpfr_prec_t work = work_precision (precision);
        auto input = mpfrxx::mpc_class::with_precision (work);
        auto intermediate = mpfrxx::mpc_class::with_precision (work);
        mpc_set (input.mpc_data (), source, rounding);
        if (operation == MpScriptElementaryOperation::expm1)
          {
            mpc_exp (intermediate.mpc_data (), input.mpc_data (), rounding);
            mpc_sub_ui (intermediate.mpc_data (), intermediate.mpc_data (), 1,
                        rounding);
          }
        else
          {
            mpc_add_ui (intermediate.mpc_data (), input.mpc_data (), 1,
                        rounding);
            mpc_log (intermediate.mpc_data (), intermediate.mpc_data (),
                     rounding);
          }
        mpc_set (destination, intermediate.mpc_data (), rounding);
      }
      return;
    }
  throw std::logic_error ("unknown complex elementary operation");
}

bool
real_domain_requires_complex (mpfr_srcptr source,
                              MpScriptElementaryOperation operation) noexcept
{
  if (mpfr_nan_p (source))
    return false;
  switch (operation)
    {
    case MpScriptElementaryOperation::sqrt:
      return mpfr_cmp_si (source, 0) < 0;
    case MpScriptElementaryOperation::log:
      return mpfr_cmp_si (source, 0) < 0;
    case MpScriptElementaryOperation::log1p:
      return mpfr_cmp_si (source, -1) < 0;
    case MpScriptElementaryOperation::asin:
    case MpScriptElementaryOperation::acos:
      return mpfr_cmp_si (source, -1) < 0 || mpfr_cmp_si (source, 1) > 0;
    case MpScriptElementaryOperation::acosh:
      return mpfr_cmp_si (source, 1) < 0;
    case MpScriptElementaryOperation::atanh:
      return mpfr_cmp_si (source, -1) < 0 || mpfr_cmp_si (source, 1) > 0;
    default:
      return false;
    }
}

} // namespace

namespace octave_mplapack
{

MpfrScalarStorage
mpfr_script_unary (const MpfrScalarStorage& source,
                   MpScriptUnaryOperation operation)
{
  MpfrScalarStorage::NativeScalar result
    = MpfrScalarStorage::NativeScalar::with_precision (
        source.precision_bits ());
  apply_real_unary (result.mpfr_data (), source.native_value ().mpfr_data (),
                    operation);
  return MpfrScalarStorage (std::move (result));
}

MpfrMatrixStorage
mpfr_script_unary (const MpfrMatrixStorage& source,
                   MpScriptUnaryOperation operation)
{
  MpfrMatrixStorage result (source.rows (), source.columns (),
                            source.precision_bits ());
  for (std::size_t index = 0; index < source.numel (); ++index)
    apply_real_unary (result.data ()[index].mpfr_data (),
                      source.data ()[index].mpfr_data (), operation);
  return result;
}

MpfrScalarStorage
mpc_script_real_unary (const MpfrComplexScalarStorage& source,
                       MpScriptUnaryOperation operation)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  MpfrScalarStorage::NativeScalar result
    = MpfrScalarStorage::NativeScalar::with_precision (
        source.precision_bits ());
  apply_complex_real_unary (result.mpfr_data (),
                           source.native_value ().mpc_data (), operation);
  return MpfrScalarStorage (std::move (result));
}

MpfrMatrixStorage
mpc_script_real_unary (const MpfrComplexMatrixStorage& source,
                       MpScriptUnaryOperation operation)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  MpfrMatrixStorage result (source.rows (), source.columns (),
                            source.precision_bits ());
  for (std::size_t index = 0; index < source.numel (); ++index)
    apply_complex_real_unary (result.data ()[index].mpfr_data (),
                             source.data ()[index].mpc_data (), operation);
  return result;
}

MpfrComplexScalarStorage
mpc_script_unary (const MpfrComplexScalarStorage& source,
                  MpScriptUnaryOperation operation)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  MpfrComplexScalarStorage::NativeScalar result
    = MpfrComplexScalarStorage::NativeScalar::with_precision (
        source.precision_bits ());
  apply_complex_unary (result.mpc_data (), source.native_value ().mpc_data (),
                       operation);
  return MpfrComplexScalarStorage (std::move (result));
}

MpfrComplexMatrixStorage
mpc_script_unary (const MpfrComplexMatrixStorage& source,
                  MpScriptUnaryOperation operation)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  MpfrComplexMatrixStorage result (source.rows (), source.columns (),
                                   source.precision_bits ());
  for (std::size_t index = 0; index < source.numel (); ++index)
    apply_complex_unary (result.data ()[index].mpc_data (),
                         source.data ()[index].mpc_data (), operation);
  return result;
}

MpScriptPredicateResult
mpfr_script_predicate (const MpfrScalarStorage& source,
                       MpScriptPredicate predicate)
{
  return {1, 1, {static_cast<unsigned char> (
                    predicate_value (source.native_value ().mpfr_data (),
                                     predicate))}};
}

MpScriptPredicateResult
mpfr_script_predicate (const MpfrMatrixStorage& source,
                       MpScriptPredicate predicate)
{ return make_predicate_result (source, predicate); }

MpScriptPredicateResult
mpc_script_predicate (const MpfrComplexScalarStorage& source,
                      MpScriptPredicate predicate)
{
  return {1, 1, {static_cast<unsigned char> (
                    predicate_value (source.native_value ().mpc_data (),
                                     predicate))}};
}

MpScriptPredicateResult
mpc_script_predicate (const MpfrComplexMatrixStorage& source,
                      MpScriptPredicate predicate)
{ return make_complex_predicate_result (source, predicate); }

bool
mpfr_script_equal (const MpfrScalarStorage& lhs,
                   const MpfrScalarStorage& rhs,
                   bool nan_equal) noexcept
{ return equal_real (lhs.native_value ().mpfr_data (),
                     rhs.native_value ().mpfr_data (), nan_equal); }

bool
mpfr_script_equal (const MpfrMatrixStorage& lhs,
                   const MpfrMatrixStorage& rhs,
                   bool nan_equal) noexcept
{
  if (lhs.rows () != rhs.rows () || lhs.columns () != rhs.columns ())
    return false;
  for (std::size_t index = 0; index < lhs.numel (); ++index)
    if (! equal_real (lhs.data ()[index].mpfr_data (),
                      rhs.data ()[index].mpfr_data (), nan_equal))
      return false;
  return true;
}

bool
mpc_script_equal (const MpfrComplexScalarStorage& lhs,
                  const MpfrComplexScalarStorage& rhs,
                  bool nan_equal) noexcept
{ return equal_complex (lhs.native_value ().mpc_data (),
                        rhs.native_value ().mpc_data (), nan_equal); }

bool
mpc_script_equal (const MpfrComplexMatrixStorage& lhs,
                  const MpfrComplexMatrixStorage& rhs,
                  bool nan_equal) noexcept
{
  if (lhs.rows () != rhs.rows () || lhs.columns () != rhs.columns ())
    return false;
  for (std::size_t index = 0; index < lhs.numel (); ++index)
    if (! equal_complex (lhs.data ()[index].mpc_data (),
                         rhs.data ()[index].mpc_data (), nan_equal))
      return false;
  return true;
}

bool
mpfr_script_power_requires_complex (mpfr_srcptr base,
                                    mpfr_srcptr exponent) noexcept
{
  return mpfr_cmp_si (base, 0) < 0 && ! mpfr_integer_p (exponent);
}

bool
mpfr_script_elementary_requires_complex (
  mpfr_srcptr source, MpScriptElementaryOperation operation) noexcept
{ return real_domain_requires_complex (source, operation); }

MpfrScalarStorage
mpfr_script_elementary (const MpfrScalarStorage& source,
                         MpScriptElementaryOperation operation)
{
  MpfrScalarStorage::NativeScalar result
    = MpfrScalarStorage::NativeScalar::with_precision (
        source.precision_bits ());
  apply_real_elementary (result.mpfr_data (), source.native_value ().mpfr_data (),
                         operation);
  return MpfrScalarStorage (std::move (result));
}

MpfrMatrixStorage
mpfr_script_elementary (const MpfrMatrixStorage& source,
                         MpScriptElementaryOperation operation)
{
  MpfrMatrixStorage result (source.rows (), source.columns (),
                            source.precision_bits ());
  for (std::size_t index = 0; index < source.numel (); ++index)
    apply_real_elementary (result.data ()[index].mpfr_data (),
                           source.data ()[index].mpfr_data (), operation);
  return result;
}

MpfrComplexScalarStorage
mpfr_script_promote (const MpfrScalarStorage& source)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  MpfrComplexScalarStorage::NativeScalar result
    = MpfrComplexScalarStorage::NativeScalar::with_precision (
        source.precision_bits ());
  mpc_set_fr (result.mpc_data (), source.native_value ().mpfr_data (),
              MPC_RND (MPFR_RNDN, MPFR_RNDN));
  return MpfrComplexScalarStorage (std::move (result));
}

MpfrComplexMatrixStorage
mpfr_script_promote (const MpfrMatrixStorage& source)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  MpfrComplexMatrixStorage result (source.rows (), source.columns (),
                                   source.precision_bits ());
  for (std::size_t index = 0; index < source.numel (); ++index)
    mpc_set_fr (result.data ()[index].mpc_data (),
                source.data ()[index].mpfr_data (),
                MPC_RND (MPFR_RNDN, MPFR_RNDN));
  return result;
}

MpfrComplexScalarStorage
mpc_script_elementary (const MpfrComplexScalarStorage& source,
                       MpScriptElementaryOperation operation)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  MpfrComplexScalarStorage::NativeScalar result
    = MpfrComplexScalarStorage::NativeScalar::with_precision (
        source.precision_bits ());
  apply_complex_elementary (result.mpc_data (), source.native_value ().mpc_data (),
                            operation);
  return MpfrComplexScalarStorage (std::move (result));
}

MpfrComplexMatrixStorage
mpc_script_elementary (const MpfrComplexMatrixStorage& source,
                       MpScriptElementaryOperation operation)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  MpfrComplexMatrixStorage result (source.rows (), source.columns (),
                                   source.precision_bits ());
  for (std::size_t index = 0; index < source.numel (); ++index)
    apply_complex_elementary (result.data ()[index].mpc_data (),
                              source.data ()[index].mpc_data (), operation);
  return result;
}

} // namespace octave_mplapack
