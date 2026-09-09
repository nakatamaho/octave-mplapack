// SPDX-License-Identifier: BSD-2-Clause

#include "mp_norm.h"

#include <cassert>
#include <cmath>
#include <complex>
#include <cstdio>
#include <vector>

#include <mpfr.h>

#include "mp_complex_precision.h"

namespace
{

using octave_mplapack::MpfrComplexMatrixStorage;
using octave_mplapack::MpfrMatrixStorage;
using octave_mplapack::MpfrNormRequest;

MpfrNormRequest
request (MpfrNormRequest::Kind kind)
{
  return {kind, 2.0};
}

void
assert_double (const octave_mplapack::MpfrScalarStorage& value,
               double expected)
{
  assert (mpfr_cmp_d (value.native_value ().mpfr_data (), expected) == 0);
}

} // namespace

int
main ()
{
  const auto vector = MpfrMatrixStorage (
    2, 1, 512, std::vector<std::string> {"3", "4"});
  assert_double (octave_mplapack::mplapack_mpfr_norm (
                   vector, request (MpfrNormRequest::Kind::one)), 7.0);
  assert_double (octave_mplapack::mplapack_mpfr_norm (
                   vector, request (MpfrNormRequest::Kind::two)), 5.0);
  assert_double (octave_mplapack::mplapack_mpfr_norm (
                   vector, request (MpfrNormRequest::Kind::infinity)), 4.0);
  assert_double (octave_mplapack::mplapack_mpfr_norm (
                   vector, request (MpfrNormRequest::Kind::negative_infinity)),
                 3.0);
  assert_double (octave_mplapack::mplapack_mpfr_norm (
                   vector, request (MpfrNormRequest::Kind::zero)), 2.0);

  const auto matrix = MpfrMatrixStorage (
    2, 2, 512, std::vector<std::string> {"3", "0", "0", "4"});
  assert_double (octave_mplapack::mplapack_mpfr_norm (
                   matrix, request (MpfrNormRequest::Kind::one)), 4.0);
  assert_double (octave_mplapack::mplapack_mpfr_norm (
                   matrix, request (MpfrNormRequest::Kind::two)), 4.0);
  assert_double (octave_mplapack::mplapack_mpfr_norm (
                   matrix, request (MpfrNormRequest::Kind::infinity)), 4.0);
  assert_double (octave_mplapack::mplapack_mpfr_norm (
                   matrix, request (MpfrNormRequest::Kind::frobenius)), 5.0);

  const auto complex_vector = MpfrComplexMatrixStorage (
    2, 1, 512, std::vector<std::string> {"(3,4)", "(0,0)"});
  assert_double (octave_mplapack::mplapack_mpc_norm (
                   complex_vector, request (MpfrNormRequest::Kind::one)), 5.0);
  assert_double (octave_mplapack::mplapack_mpc_norm (
                   complex_vector, request (MpfrNormRequest::Kind::two)), 5.0);

  const auto complex_matrix = MpfrComplexMatrixStorage (
    2, 2, 512, std::vector<std::string> {"(3,0)", "(0,0)", "(0,0)", "(4,0)"});
  assert_double (octave_mplapack::mplapack_mpc_norm (
                   complex_matrix, request (MpfrNormRequest::Kind::two)), 4.0);
  assert_double (octave_mplapack::mplapack_mpc_norm (
                   complex_matrix, request (MpfrNormRequest::Kind::frobenius)),
                 5.0);

  for (mpfr_prec_t precision : {1024, 2048})
    {
      MpfrMatrixStorage canary (1, 1, precision);
      mpfr_set_si_2exp (canary.at (0, 0).mpfr_data (), 1, -700, MPFR_RNDN);
      const auto before = mpfrxx::default_precision_bits ();
      const auto value = octave_mplapack::mplapack_mpfr_norm (
        canary, request (MpfrNormRequest::Kind::two));
      assert (value.precision_bits () == precision);
      assert (mpfr_cmp (value.native_value ().mpfr_data (),
                        canary.at (0, 0).mpfr_data ()) == 0);
      assert (mpfrxx::default_precision_bits () == before);
    }

  mpfrxx::set_default_precision_bits (333);
  const auto ambient = octave_mplapack::mplapack_mpfr_norm (
    vector, request (MpfrNormRequest::Kind::two));
  assert (ambient.precision_bits () == 512);
  assert (mpfrxx::default_precision_bits () == 333);

  std::puts ("N00 native norm PASS");
}
