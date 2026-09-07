// SPDX-License-Identifier: BSD-2-Clause
// High-precision Hilbert inverse using the installed MPLAPACK MPFR API.
//
// Compile from an installed MPLAPACK/gmpfrxx stack with:
//
//   c++ -std=c++17 -O2 -o hilbert_inverse_mpfr examples/interop_hilbert_inverse_mpfr.cpp $(pkg-config --cflags --libs mplapack_mpfr)
//
// This is an external-consumer example.  It deliberately includes only the
// public MPFR headers; mpblas.h and mplapack.h are internal aggregate headers.

#include <algorithm>
#include <iostream>
#include <string>
#include <vector>

#include <mpblas_mpfr.h>
#include <mplapack_mpfr.h>
#include <mplapack_mpfr_precision.h>

namespace {

void print_matrix (const std::vector<mpfr_class>& a, mplapackint n)
{
  for (mplapackint i = 0; i < n; ++i)
    {
      for (mplapackint j = 0; j < n; ++j)
        {
          if (j != 0)
            std::cout << ' ';
          std::cout << a[i + j * n];
        }
      std::cout << '\n';
    }
}

mpfr_class residual_inf_norm (const std::vector<mpfr_class>& product,
                              mplapackint n)
{
  mpfr_class result = mpfr_class::with_precision (product[0].precision ());
  result = 0.0;
  for (mplapackint i = 0; i < n; ++i)
    {
      mpfr_class row_sum = mpfr_class::with_precision (result.precision ());
      row_sum = 0.0;
      for (mplapackint j = 0; j < n; ++j)
        {
          mpfr_class entry = product[i + j * n];
          if (i == j)
            entry -= 1.0;
          row_sum += abs (entry);
        }
      if (row_sum > result)
        result = row_sum;
    }
  return result;
}

} // namespace

int main ()
{
  const mpfr_prec_t precision = 1024;
  const mplapackint n = 6;
  MplapackMpfrPrecisionScope scope (precision);

  const mpfr_class one ("1", precision);
  const mpfr_class zero ("0", precision);
  std::vector<mpfr_class> original (n * n);
  std::vector<mpfr_class> inverse (n * n);
  std::vector<mpfr_class> product (n * n);
  std::vector<mplapackint> pivots (n);

  for (mplapackint j = 0; j < n; ++j)
    for (mplapackint i = 0; i < n; ++i)
      {
        const std::string denominator = std::to_string (i + j + 1);
        const mpfr_class value (one / mpfr_class (denominator, precision));
        original[i + j * n] = value;
        inverse[i + j * n] = value;
      }

  mplapackint info = 0;
  Rgetrf (n, n, inverse.data (), n, pivots.data (), info);
  if (info != 0)
    {
      std::cerr << "Rgetrf INFO=" << info << '\n';
      return 1;
    }

  mplapackint lwork = -1;
  mpfr_class work_query ("0", precision);
  Rgetri (n, inverse.data (), n, pivots.data (), &work_query, lwork, info);
  if (info != 0)
    {
      std::cerr << "Rgetri workspace query INFO=" << info << '\n';
      return 1;
    }
  lwork = std::max<mplapackint> (1, castINTEGER_mpfr (work_query));
  std::vector<mpfr_class> work (lwork, mpfr_class ("0", precision));

  Rgetri (n, inverse.data (), n, pivots.data (), work.data (), lwork, info);
  if (info != 0)
    {
      std::cerr << "Rgetri INFO=" << info << '\n';
      return 1;
    }

  Rgemm ("N", "N", n, n, n, one, original.data (), n,
         inverse.data (), n, zero, product.data (), n);

  std::cout << "Hilbert inverse at " << precision << " bits:\n";
  print_matrix (inverse, n);
  std::cout << "||H * H^(-1) - I||_inf = "
            << residual_inf_norm (product, n) << '\n';
  return 0;
}
