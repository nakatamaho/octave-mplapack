// SPDX-License-Identifier: BSD-2-Clause

#include <iostream>
#include <initializer_list>
#include <stdexcept>
#include <string>
#include <vector>

#include <mplapack.h>
#include <mpblas_mpfr.h>
#include <mplapack_mpfr.h>
#include <mplapack_mpfr_precision.h>

namespace
{

using Real = mpfrxx::mpfr_class;

void
check (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

std::vector<Real>
matrix (std::size_t rows, std::size_t columns, mpfr_prec_t precision,
        std::initializer_list<const char*> values)
{
  const std::vector<std::string> text (values.begin (), values.end ());
  check (text.size () == rows * columns, "probe matrix element count mismatch");
  std::vector<Real> result;
  result.reserve (text.size ());
  for (const auto& value : text)
    {
      Real element = Real::with_precision (precision);
      check (mpfr_set_str (element.mpfr_data (), value.c_str (), 10,
                           MPFR_RNDN) == 0,
             "probe matrix text is invalid");
      result.push_back (std::move (element));
    }
  // The input list is row-major for readability; convert to column-major.
  std::vector<Real> column_major;
  column_major.reserve (result.size ());
  for (std::size_t column = 0; column < columns; ++column)
    for (std::size_t row = 0; row < rows; ++row)
      {
        Real element = Real::with_precision (precision);
        mpfr_set (element.mpfr_data (),
                  result[row * columns + column].mpfr_data (), MPFR_RNDN);
        column_major.push_back (std::move (element));
      }
  return column_major;
}

void
check_text (const Real& value, const char *text, const char *message)
{
  Real expected = Real::with_precision (value.precision ());
  check (mpfr_set_str (expected.mpfr_data (), text, 10, MPFR_RNDN) == 0,
         "probe expected text is invalid");
  check (mpfr_equal_p (value.mpfr_data (), expected.mpfr_data ()) != 0,
         message);
}

void
check_fraction (const Real& value, unsigned long numerator,
                unsigned long denominator, const char *message)
{
  Real expected = Real::with_precision (value.precision ());
  mpfr_set_ui (expected.mpfr_data (), numerator, MPFR_RNDN);
  mpfr_div_ui (expected.mpfr_data (), expected.mpfr_data (), denominator,
               MPFR_RNDN);
  Real difference = Real::with_precision (value.precision ());
  mpfr_sub (difference.mpfr_data (), value.mpfr_data (), expected.mpfr_data (),
            MPFR_RNDN);
  mpfr_abs (difference.mpfr_data (), difference.mpfr_data (), MPFR_RNDN);
  Real tolerance = Real::with_precision (value.precision ());
  mpfr_set_ui_2exp (tolerance.mpfr_data (), 1,
                    -static_cast<mpfr_exp_t> (value.precision () * 3 / 4),
                    MPFR_RNDN);
  check (mpfr_cmp (difference.mpfr_data (), tolerance.mpfr_data ()) < 0,
         message);
}

void
factor (std::vector<Real>& values, std::size_t rows, std::size_t columns,
        std::vector<mplapackint>& pivots, mplapackint& info,
        mpfr_prec_t precision)
{
  const mpfr_prec_t ambient = mpfrxx::default_precision_bits ();
  pivots.assign (std::min (rows, columns), 0);
  info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision);
    Rgetrf (static_cast<mplapackint> (rows),
            static_cast<mplapackint> (columns), values.data (),
            static_cast<mplapackint> (std::max<std::size_t> (1, rows)),
            pivots.data (), info);
  }
  check (mpfrxx::default_precision_bits () == ambient,
         "Rgetrf probe did not restore ambient precision");
}

void
test_mapping ()
{
  auto values = matrix (2, 2, 256, {"1", "2", "3", "4"});
  std::vector<mplapackint> pivots;
  mplapackint info = 0;
  factor (values, 2, 2, pivots, info, 256);
  check (info == 0 && pivots == std::vector<mplapackint> ({2, 2}),
         "Rgetrf simple IPIV mismatch");
  check_text (values[0], "3", "Rgetrf simple packed pivot mismatch");
  check_fraction (values[1], 1, 3, "Rgetrf simple multiplier mismatch");
  check_text (values[2], "4", "Rgetrf simple packed U mismatch");
  check_fraction (values[3], 2, 3, "Rgetrf simple diagonal mismatch");

  auto multi = matrix (3, 2, 256, {"1", "2", "3", "4", "5", "6"});
  factor (multi, 3, 2, pivots, info, 256);
  check (info == 0 && pivots == std::vector<mplapackint> ({3, 3}),
         "Rgetrf multi-pivot IPIV mismatch");
}

void
test_precision ()
{
  for (const auto case_data : {std::pair<mpfr_prec_t, mpfr_exp_t> (1024, -700),
                               std::pair<mpfr_prec_t, mpfr_exp_t> (2048,
                                                                    -1500)})
    {
      const mpfr_prec_t precision = case_data.first;
      auto values = matrix (2, 2, precision, {"4", "0", "2", "3"});
      Real delta = Real::with_precision (precision);
      mpfr_set_ui_2exp (delta.mpfr_data (), 1, case_data.second, MPFR_RNDN);
      mpfr_set_ui (values[1].mpfr_data (), 1, MPFR_RNDN);
      mpfr_add (values[1].mpfr_data (), values[1].mpfr_data (),
                delta.mpfr_data (), MPFR_RNDN);
      std::vector<mplapackint> pivots;
      mplapackint info = 0;
      factor (values, 2, 2, pivots, info, precision);
      check (info == 0 && pivots == std::vector<mplapackint> ({1, 2}),
             "Rgetrf precision pivot mismatch");
      Real expected = Real::with_precision (precision);
      mpfr_set_ui (expected.mpfr_data (), 1, MPFR_RNDN);
      mpfr_div_ui (expected.mpfr_data (), expected.mpfr_data (), 4,
                   MPFR_RNDN);
      Real tail = Real::with_precision (precision);
      mpfr_set_ui_2exp (tail.mpfr_data (), 1, case_data.second - 2,
                        MPFR_RNDN);
      mpfr_add (expected.mpfr_data (), expected.mpfr_data (), tail.mpfr_data (),
                MPFR_RNDN);
      check (mpfr_equal_p (values[1].mpfr_data (), expected.mpfr_data ()) != 0,
             "Rgetrf precision multiplier tail mismatch");
    }
}

void
test_pivot_precision_and_status ()
{
  for (const auto precision : {mpfr_prec_t (512), mpfr_prec_t (1024)})
    {
      auto values = matrix (2, 2, precision, {"1", "0", "1", "1"});
      Real delta = Real::with_precision (precision);
      mpfr_set_ui_2exp (delta.mpfr_data (), 1, -700, MPFR_RNDN);
      mpfr_add (values[1].mpfr_data (), values[1].mpfr_data (),
                delta.mpfr_data (), MPFR_RNDN);
      std::vector<mplapackint> pivots;
      mplapackint info = 0;
      factor (values, 2, 2, pivots, info, precision);
      check (pivots[0] == (precision == 512 ? 1 : 2),
             "Rgetrf precision-dependent pivot mismatch");
    }

  auto singular = matrix (2, 2, 256, {"1", "2", "2", "4"});
  std::vector<mplapackint> pivots;
  mplapackint info = 0;
  factor (singular, 2, 2, pivots, info, 256);
  check (info == 2, "Rgetrf singular INFO mismatch");

  mpfrxx::set_default_precision_bits (4096);
  auto high_ambient = matrix (2, 2, 256, {"1", "0", "0", "2"});
  factor (high_ambient, 2, 2, pivots, info, 256);
  check (info == 0 && high_ambient[0].precision () == 256
         && mpfrxx::default_precision_bits () == 4096,
         "Rgetrf high ambient precision mismatch");
  mpfrxx::set_default_precision_bits (128);
}

} // namespace

int
main ()
{
  try
    {
      mpfrxx::set_default_precision_bits (128);
      test_mapping ();
      test_precision ();
      test_pivot_precision_and_status ();
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
  std::cout << "PASS: installed MPLAPACK MPFR Rgetrf precision/IPIV probe\n";
  return 0;
}
