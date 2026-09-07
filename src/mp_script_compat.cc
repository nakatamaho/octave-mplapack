// SPDX-License-Identifier: BSD-2-Clause

#include "mp_script_compat.h"

#include <algorithm>
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

} // namespace octave_mplapack
