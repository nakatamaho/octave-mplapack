// SPDX-License-Identifier: BSD-2-Clause

#include "mp_blas.h"

#include <condition_variable>
#include <iostream>
#include <mutex>
#include <stdexcept>
#include <string>
#include <thread>

namespace
{

using Matrix = octave_mplapack::MpfrMatrixStorage;
using NativeScalar = mpfrxx::mpfr_class;

void
require (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

void
set_unsigned (NativeScalar& value, unsigned long number)
{
  mpfr_set_ui (value.mpfr_data (), number, MPFR_RNDN);
}

void
add_power_of_two (NativeScalar& value, long exponent)
{
  NativeScalar increment = NativeScalar::with_precision (value.precision ());
  mpfr_set_ui_2exp (increment.mpfr_data (), 1, exponent, MPFR_RNDN);
  mpfr_add (value.mpfr_data (), value.mpfr_data (), increment.mpfr_data (),
            MPFR_RNDN);
}

NativeScalar
explicit_value (mpfr_prec_t precision, unsigned long number)
{
  NativeScalar value = NativeScalar::with_precision (precision);
  set_unsigned (value, number);
  return value;
}

class DefaultPrecisionGuard
{
public:
  explicit DefaultPrecisionGuard (mpfr_prec_t precision)
    : m_saved (mpfrxx::default_precision_bits ())
  {
    mpfrxx::set_default_precision_bits (precision);
    require (mpfrxx::default_precision_bits () == precision,
             "failed to set native test MPFR default");
  }

  ~DefaultPrecisionGuard () noexcept
  {
    mpfrxx::set_default_precision_bits (m_saved);
  }

private:
  mpfr_prec_t m_saved;
};

void
test_scope_basic_nested_exception_and_stress ()
{
  DefaultPrecisionGuard guard (128);
  {
    MplapackMpfrPrecisionScope outer (1024);
    require (mpfrxx::default_precision_bits () == 1024,
             "basic scope did not set the requested precision");
    NativeScalar value;
    require (value.precision () == 1024,
             "default construction ignored the scope precision");
    {
      MplapackMpfrPrecisionScope inner (2048);
      require (mpfrxx::default_precision_bits () == 2048,
               "nested scope did not set the requested precision");
      NativeScalar nested_value;
      require (nested_value.precision () == 2048,
               "nested default construction ignored the scope precision");
    }
    require (mpfrxx::default_precision_bits () == 1024,
             "nested scope did not restore the outer precision");
  }
  require (mpfrxx::default_precision_bits () == 128,
           "basic scope did not restore the outside precision");

  {
    MplapackMpfrPrecisionScope scope (256);
    require (mpfrxx::default_precision_bits () == 256,
             "reverse scope did not set the requested precision");
  }
  require (mpfrxx::default_precision_bits () == 128,
           "reverse scope did not restore the outside precision");

  try
    {
      MplapackMpfrPrecisionScope scope (4096);
      throw std::runtime_error ("deliberate scope exception");
    }
  catch (const std::runtime_error&)
    {
    }
  require (mpfrxx::default_precision_bits () == 128,
           "scope did not restore precision during exception unwinding");

  NativeScalar explicit_value_1024 = NativeScalar::with_precision (1024);
  {
      MplapackMpfrPrecisionScope scope (512);
    require (explicit_value_1024.precision () == 1024,
             "explicit object changed inside a scope");
  }
  require (explicit_value_1024.precision () == 1024,
           "explicit object changed after a scope");

  bool invalid_rejected = false;
  try
    {
      MplapackMpfrPrecisionScope invalid (0);
    }
  catch (const std::invalid_argument&)
    {
      invalid_rejected = true;
    }
  require (invalid_rejected, "invalid scope precision was accepted");
  require (mpfrxx::default_precision_bits () == 128,
           "invalid scope changed the outside precision");

  for (int iteration = 0; iteration < 10000; ++iteration)
    {
      const mpfr_prec_t precision = (iteration & 1) == 0 ? 256 : 2048;
      MplapackMpfrPrecisionScope scope (precision);
      NativeScalar value;
      require (value.precision () == precision,
               "repeated scope lost the requested precision");
    }
  require (mpfrxx::default_precision_bits () == 128,
           "repeated scopes did not restore the outside precision");
}

void
test_contract_checker ()
{
  constexpr mpfr_prec_t precision = 1024;
  Matrix a (1, 1, precision, std::vector<std::string> {"1"});
  Matrix b (1, 1, precision, std::vector<std::string> {"1"});
  Matrix c (1, 1, precision);
  NativeScalar alpha = explicit_value (precision, 1);
  NativeScalar beta = explicit_value (precision, 0);

  DefaultPrecisionGuard guard (512);
  bool rejected = false;
  bool rgemm_entered = false;
  try
    {
      octave_mplapack::require_mplapack_mpfr_precision_contract (
        precision, alpha, a, b, beta, c);
      rgemm_entered = true;
    }
  catch (const std::runtime_error&)
    {
      rejected = true;
    }
  require (rejected && ! rgemm_entered,
           "TLS mismatch was not rejected before the Rgemm seam");

  DefaultPrecisionGuard valid_guard (precision);
  Matrix short_b (1, 1, 512, std::vector<std::string> {"1"});
  rejected = false;
  try
    {
      octave_mplapack::require_mplapack_mpfr_precision_contract (
        precision, alpha, a, short_b, beta, c);
    }
  catch (const std::runtime_error&)
    {
      rejected = true;
    }
  require (rejected, "matrix precision mismatch was not rejected");

  NativeScalar short_alpha = explicit_value (512, 1);
  rejected = false;
  try
    {
      octave_mplapack::require_mplapack_mpfr_precision_contract (
        precision, short_alpha, a, b, beta, c);
    }
  catch (const std::runtime_error&)
    {
      rejected = true;
    }
  require (rejected, "scalar precision mismatch was not rejected");

  octave_mplapack::require_mplapack_mpfr_precision_contract (
    precision, alpha, a, b, beta, c);
}

void
test_rgemm_precision_and_shapes ()
{
  {
    DefaultPrecisionGuard guard (128);
    constexpr mpfr_prec_t precision = 1024;
    Matrix a (1, 1, precision,
              std::vector<std::string> {"1.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"});
    Matrix b (1, 1, precision, std::vector<std::string> {"1"});
    Matrix result = octave_mplapack::mplapack_mpfr_matrix_multiply (a, b);
    require (result.precision_bits () == precision,
             "1024-bit Rgemm result precision mismatch");
    require (result.element_exactly_equal (0, 0, a, 0, 0),
             "1024-bit Rgemm lost the low-order contribution");
    require (mpfrxx::default_precision_bits () == 128,
             "Rgemm did not restore the outer default precision");
  }

  {
    DefaultPrecisionGuard guard (4096);
    constexpr mpfr_prec_t precision = 256;
    Matrix a (1, 1, precision,
              std::vector<std::string> {"1.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"});
    Matrix b (1, 1, precision, std::vector<std::string> {"1"});
    Matrix result = octave_mplapack::mplapack_mpfr_matrix_multiply (a, b);
    require (result.precision_bits () == precision,
             "256-bit Rgemm used the outside 4096-bit precision");
    require (result.element_exactly_equal (0, 0, a, 0, 0),
             "256-bit Rgemm changed the rounding context");
    require (mpfrxx::default_precision_bits () == 4096,
             "high outside default was not restored after Rgemm");
  }

  {
    DefaultPrecisionGuard guard (128);
    constexpr mpfr_prec_t precision = 2048;
    Matrix a (1, 1, precision);
    Matrix b (1, 1, precision, std::vector<std::string> {"1"});
    set_unsigned (a.at (0, 0), 1);
    add_power_of_two (a.at (0, 0), -1500);
    Matrix result = octave_mplapack::mplapack_mpfr_matrix_multiply (a, b);
    require (result.precision_bits () == precision,
             "2048-bit Rgemm result precision mismatch");
    require (result.element_exactly_equal (0, 0, a, 0, 0),
             "2048-bit Rgemm lost the low-order contribution");
    require (mpfrxx::default_precision_bits () == 128,
             "2048-bit Rgemm did not restore the outer default");
  }

  Matrix left (2, 3, 256,
               std::vector<std::string> {"1", "4", "2", "5", "3", "6"});
  Matrix right (3, 2, 256,
                std::vector<std::string> {"7", "9", "11", "8", "10", "12"});
  Matrix product = octave_mplapack::mplapack_mpfr_matrix_multiply (left, right);
  require (product.rows () == 2 && product.columns () == 2,
           "rectangular Rgemm result shape mismatch");
  require (product.element_exactly_equal_text (0, 0, "58"),
           "rectangular Rgemm result (1,1) mismatch");
  require (product.element_exactly_equal_text (1, 0, "139"),
           "rectangular Rgemm result (2,1) mismatch");
  require (product.element_exactly_equal_text (0, 1, "64"),
           "rectangular Rgemm result (1,2) mismatch");
  require (product.element_exactly_equal_text (1, 1, "154"),
           "rectangular Rgemm result (2,2) mismatch");

  Matrix empty (0, 3, 777);
  Matrix empty_result = octave_mplapack::mplapack_mpfr_matrix_multiply (
    empty, Matrix (3, 2, 333));
  require (empty_result.rows () == 0 && empty_result.columns () == 2
           && empty_result.precision_bits () == 777,
           "empty Rgemm result metadata mismatch");

  bool dimension_rejected = false;
  try
    {
      (void) octave_mplapack::mplapack_mpfr_matrix_multiply (
        Matrix (2, 2, 128), Matrix (3, 1, 128));
    }
  catch (const std::invalid_argument&)
    {
      dimension_rejected = true;
    }
  require (dimension_rejected, "incompatible Rgemm dimensions were accepted");
}

void
test_native_scaling ()
{
  Matrix matrix (2, 1, 256,
                 std::vector<std::string> {"1", "2"});
  NativeScalar scalar = explicit_value (1024, 3);
  Matrix result = octave_mplapack::mplapack_mpfr_matrix_scale (
    matrix, scalar);
  require (result.precision_bits () == 1024,
           "scalar/matrix operation did not use the greater precision");
  require (result.element_exactly_equal_text (0, 0, "3"),
           "scalar/matrix scaling first value mismatch");
  require (result.element_exactly_equal_text (1, 0, "6"),
           "scalar/matrix scaling second value mismatch");
  require (matrix.precision_bits () == 256
           && matrix.element_exactly_equal_text (0, 0, "1"),
           "scalar/matrix scaling mutated its input");
}

void
test_concurrent_thread_scopes ()
{
  if (mpfr_buildopt_tls_p () == 0)
    {
      std::cout << "SKIP: concurrent precision scopes (MPFR TLS disabled)\n";
      return;
    }

  DefaultPrecisionGuard guard (512);
  std::mutex mutex;
  std::condition_variable condition;
  int ready = 0;
  bool release = false;
  mpfr_prec_t thread_a_initial = 0;
  mpfr_prec_t thread_b_initial = 0;
  mpfr_prec_t thread_a_after = 0;
  mpfr_prec_t thread_b_after = 0;
  bool thread_a_ok = false;
  bool thread_b_ok = false;

  auto worker = [&] (mpfr_prec_t precision, mpfr_prec_t& initial,
                     mpfr_prec_t& after, bool& ok)
  {
    initial = mpfrxx::default_precision_bits ();
    {
      MplapackMpfrPrecisionScope scope (precision);
      NativeScalar value;
      std::unique_lock<std::mutex> lock (mutex);
      ok = value.precision () == precision
           && mpfrxx::default_precision_bits () == precision;
      ++ready;
      condition.notify_all ();
      condition.wait (lock, [&] { return release; });
      ok = ok && mpfrxx::default_precision_bits () == precision;
    }
    after = mpfrxx::default_precision_bits ();
  };

  std::thread thread_a (worker, 256, std::ref (thread_a_initial),
                        std::ref (thread_a_after), std::ref (thread_a_ok));
  std::thread thread_b (worker, 2048, std::ref (thread_b_initial),
                        std::ref (thread_b_after), std::ref (thread_b_ok));
  {
    std::unique_lock<std::mutex> lock (mutex);
    condition.wait (lock, [&] { return ready == 2; });
    require (mpfrxx::default_precision_bits () == 512,
             "worker scope changed the main-thread precision");
    release = true;
    condition.notify_all ();
  }
  thread_a.join ();
  thread_b.join ();
  require (thread_a_ok && thread_b_ok,
           "concurrent independent precision scopes interfered");
  require (thread_a_after == thread_a_initial
           && thread_b_after == thread_b_initial,
           "worker scope did not restore each worker's initial precision");
  require (mpfrxx::default_precision_bits () == 512,
           "concurrent scopes changed the main-thread precision after join");
  (void) thread_a_after;
  (void) thread_b_after;
}

} // namespace

int
main ()
{
  try
    {
      test_scope_basic_nested_exception_and_stress ();
      test_contract_checker ();
      test_rgemm_precision_and_shapes ();
      test_native_scaling ();
      test_concurrent_thread_scopes ();
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }

  std::cout << "PASS: private MPFR scope, contract checker, reference Rgemm, "
               "native scaling, shapes, and thread QA\n";
  return 0;
}
