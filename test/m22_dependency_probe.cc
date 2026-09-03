// SPDX-License-Identifier: BSD-2-Clause

#include <iostream>
#include <stdexcept>

#include <mplapack_mpfr_precision.h>

int
main ()
{
  const mpfr_prec_t saved = mpfrxx::default_precision_bits ();
  try
    {
      mpfrxx::set_default_precision_bits (128);
      if (mpfrxx::default_precision_bits () != 128)
        throw std::runtime_error ("unable to set MPFR default precision");
      {
        MplapackMpfrPrecisionScope scope (256);
        if (mpfrxx::default_precision_bits () != 256)
          throw std::runtime_error ("precision scope did not establish 256 bits");
      }
      if (mpfrxx::default_precision_bits () != 128)
        throw std::runtime_error ("precision scope did not restore 128 bits");
      mpfrxx::set_default_precision_bits (saved);
      std::cout << "PASS: MPLAPACK MPFR uniform-precision interface probe\n";
      return 0;
    }
  catch (const std::exception& error)
    {
      mpfrxx::set_default_precision_bits (saved);
      std::cerr << "FAIL: incompatible MPLAPACK MPFR uniform-precision "
                   "calling-contract interface: " << error.what () << "\n";
      return 1;
    }
}
