// SPDX-License-Identifier: BSD-2-Clause

#include "mp_complex_structure.h"

#include <stdexcept>
#include <utility>

#include "mp_complex_precision.h"

namespace octave_mplapack
{

namespace
{

MpfrScalarStorage
component (const MpfrComplexScalarStorage& source, bool imaginary)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  MpfrScalarStorage::NativeScalar result
    = MpfrScalarStorage::NativeScalar::with_precision (
        source.precision_bits ());
  mpfr_set (result.mpfr_data (),
            imaginary
              ? mpc_imagref (source.native_value ().mpc_data ())
              : mpc_realref (source.native_value ().mpc_data ()),
            MPFR_RNDN);
  return MpfrScalarStorage (std::move (result));
}

MpfrComplexScalarStorage
conjugate (const MpfrComplexScalarStorage& source)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  MpfrComplexScalarStorage::NativeScalar result
    = MpfrComplexScalarStorage::NativeScalar::with_precision (
        source.precision_bits ());
  mpc_conj (result.mpc_data (), source.native_value ().mpc_data (),
            MPC_RND (MPFR_RNDN, MPFR_RNDN));
  return MpfrComplexScalarStorage (std::move (result));
}

MpfrComplexScalarStorage
copy (const MpfrComplexScalarStorage& source)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  MpfrComplexScalarStorage::NativeScalar result
    = MpfrComplexScalarStorage::NativeScalar::with_precision (
        source.precision_bits ());
  mpc_set (result.mpc_data (), source.native_value ().mpc_data (),
           MPC_RND (MPFR_RNDN, MPFR_RNDN));
  return MpfrComplexScalarStorage (std::move (result));
}

} // namespace

MpfrScalarStorage
mpfr_complex_scalar_real (const MpfrComplexScalarStorage& source)
{ return component (source, false); }

MpfrScalarStorage
mpfr_complex_scalar_imag (const MpfrComplexScalarStorage& source)
{ return component (source, true); }

MpfrComplexScalarStorage
mpfr_complex_scalar_conj (const MpfrComplexScalarStorage& source)
{ return conjugate (source); }

MpfrComplexScalarStorage
mpfr_complex_scalar_transpose (const MpfrComplexScalarStorage& source)
{ return copy (source); }

MpfrComplexScalarStorage
mpfr_complex_scalar_ctranspose (const MpfrComplexScalarStorage& source)
{ return conjugate (source); }

MpfrComplexMatrixStorage
mpfr_complex_matrix_reshape (const MpfrComplexMatrixStorage& source,
                             std::size_t rows, std::size_t columns)
{
  if (MpfrComplexMatrixStorage::checked_element_count (rows, columns)
      != source.numel ())
    throw std::invalid_argument ("complex reshape element count does not match");

  MpfrMpcPrecisionScope scope (source.precision_bits ());
  MpfrComplexMatrixStorage result (rows, columns, source.precision_bits ());
  for (std::size_t index = 0; index < source.numel (); ++index)
    mpc_set (result.data ()[index].mpc_data (), source.data ()[index].mpc_data (),
             MPC_RND (MPFR_RNDN, MPFR_RNDN));
  return result;
}

} // namespace octave_mplapack
