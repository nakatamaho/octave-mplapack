// SPDX-License-Identifier: BSD-2-Clause

#include <algorithm>
#include <array>
#include <cmath>
#include <complex>
#include <iostream>
#include <limits>
#include <stdexcept>
#include <string>
#include <vector>

#include <mplapack_mpfr.h>

#include "mp_complex_blas.h"
#include "mp_complex_precision.h"
#include "mp_complex_rank.h"

namespace
{

using Matrix = octave_mplapack::MpfrComplexMatrixStorage;
using Integer = Matrix::MplapackInteger;

void
check (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

Integer
workspace_length (const mpfrxx::mpfr_class& value, const char *name)
{
  if (mpfr_nan_p (value.mpfr_data ()) != 0
      || mpfr_inf_p (value.mpfr_data ()) != 0
      || mpfr_integer_p (value.mpfr_data ()) == 0
      || mpfr_sgn (value.mpfr_data ()) <= 0)
    throw std::runtime_error (std::string (name)
                              + " workspace query was invalid");
  const auto result = mpfr_get_ui (value.mpfr_data (), MPFR_RNDZ);
  if (result > static_cast<unsigned long> (
                 std::numeric_limits<Integer>::max ())
      || result > static_cast<unsigned long> (
                 std::numeric_limits<std::size_t>::max ()))
    throw std::runtime_error (std::string (name)
                              + " workspace query overflowed");
  return static_cast<Integer> (result);
}

void
fill_rhs (Matrix& destination, const Matrix& source)
{
  for (std::size_t index = 0; index < destination.numel (); ++index)
    mpc_set_ui_ui (destination.data ()[index].mpc_data (), 0, 0,
                   MPC_RND (MPFR_RNDN, MPFR_RNDN));
  for (std::size_t column = 0; column < source.columns (); ++column)
    for (std::size_t row = 0; row < source.rows (); ++row)
      mpc_set (destination.at (row, column).mpc_data (),
               source.at (row, column).mpc_data (),
               MPC_RND (MPFR_RNDN, MPFR_RNDN));
}

struct CandidateResult
{
  Matrix solution;
  Integer rank = 0;
};

enum class Candidate
{
  gelsy,
  gelss,
  gelsd
};

const char *
candidate_name (Candidate candidate)
{
  switch (candidate)
    {
    case Candidate::gelsy: return "Cgelsy";
    case Candidate::gelss: return "Cgelss";
    case Candidate::gelsd: return "Cgelsd";
    }
  return "unknown";
}

CandidateResult
run_candidate (Candidate candidate, const Matrix& lhs, const Matrix& rhs,
               mpfr_prec_t precision)
{
  const std::size_t m = lhs.rows ();
  const std::size_t n = lhs.columns ();
  const std::size_t nrhs = rhs.columns ();
  const std::size_t padded_rows = std::max (m, n);
  const std::size_t minmn = std::min (m, n);
  const auto m_arg = Matrix::checked_mplapack_dimension (m);
  const auto n_arg = Matrix::checked_mplapack_dimension (n);
  const auto nrhs_arg = Matrix::checked_mplapack_dimension (nrhs);

  auto make_a = [&] ()
  { return octave_mplapack::mplapack_mpc_matrix_copy_at_precision (
      lhs, precision); };
  auto make_b = [&] ()
  {
    Matrix result (padded_rows, nrhs, precision);
    fill_rhs (result, rhs);
    return result;
  };

  auto run_gelsy = [&] ()
  {
    auto a = make_a ();
    auto b = make_b ();
    std::vector<Integer> jpvt (n, 0);
    Matrix work_query (1, 1, precision);
    octave_mplapack::MpfrMatrixStorage rwork_query (
      std::max<std::size_t> (1, 2 * n), 1, precision);
    Integer rank = 0;
    Integer info = 0;
    octave_mplapack::MpfrMpcPrecisionScope scope (precision);
    mpfrxx::mpfr_class rcond
      = mpfrxx::mpfr_class::with_precision (precision);
    const mpfrxx::mpfr_class epsilon = Rlamch_mpfr ("E");
    mpfr_set (rcond.mpfr_data (), epsilon.mpfr_data (), MPFR_RNDN);
    Cgelsy (m_arg, n_arg, nrhs_arg, a.data (), a.leading_dimension (),
            b.data (), b.leading_dimension (), jpvt.data (), rcond, rank,
            work_query.data (), -1, rwork_query.data (), info);
    check (info == 0, "Cgelsy workspace query failed");
    const Integer lwork = workspace_length (work_query.at (0, 0).real (),
                                            "Cgelsy");
    a = make_a ();
    b = make_b ();
    jpvt.assign (n, 0);
    Matrix work (static_cast<std::size_t> (lwork), 1, precision);
    octave_mplapack::MpfrMatrixStorage rwork (
      std::max<std::size_t> (1, 2 * n), 1, precision);
    rank = 0;
    info = 0;
    Cgelsy (m_arg, n_arg, nrhs_arg, a.data (), a.leading_dimension (),
            b.data (), b.leading_dimension (), jpvt.data (), rcond, rank,
            work.data (), lwork, rwork.data (), info);
    check (info == 0, "Cgelsy solve failed");
    Matrix result (n, nrhs, precision);
    for (std::size_t column = 0; column < nrhs; ++column)
      for (std::size_t row = 0; row < n; ++row)
        mpc_set (result.at (row, column).mpc_data (),
                 b.at (row, column).mpc_data (),
                 MPC_RND (MPFR_RNDN, MPFR_RNDN));
    return CandidateResult {std::move (result), rank};
  };

  auto run_gelss = [&] ()
  {
    auto a = make_a ();
    auto b = make_b ();
    octave_mplapack::MpfrMatrixStorage singular_values (minmn, 1, precision);
    Matrix work_query (1, 1, precision);
    octave_mplapack::MpfrMatrixStorage rwork_query (
      std::max<std::size_t> (1, 4 * padded_rows + 32), 1, precision);
    Integer rank = 0;
    Integer info = 0;
    octave_mplapack::MpfrMpcPrecisionScope scope (precision);
    mpfrxx::mpfr_class rcond
      = mpfrxx::mpfr_class::with_precision (precision);
    const mpfrxx::mpfr_class epsilon = Rlamch_mpfr ("E");
    mpfr_set (rcond.mpfr_data (), epsilon.mpfr_data (), MPFR_RNDN);
    Cgelss (m_arg, n_arg, nrhs_arg, a.data (), a.leading_dimension (),
            b.data (), b.leading_dimension (), singular_values.data (), rcond,
            rank, work_query.data (), -1, rwork_query.data (), info);
    check (info == 0, "Cgelss workspace query failed");
    const Integer lwork = workspace_length (work_query.at (0, 0).real (),
                                            "Cgelss");
    a = make_a ();
    b = make_b ();
    singular_values = octave_mplapack::MpfrMatrixStorage (minmn, 1, precision);
    Matrix work (static_cast<std::size_t> (lwork), 1, precision);
    octave_mplapack::MpfrMatrixStorage rwork (
      std::max<std::size_t> (1, 4 * padded_rows + 32), 1, precision);
    rank = 0;
    info = 0;
    Cgelss (m_arg, n_arg, nrhs_arg, a.data (), a.leading_dimension (),
            b.data (), b.leading_dimension (), singular_values.data (), rcond,
            rank, work.data (), lwork, rwork.data (), info);
    check (info == 0, "Cgelss solve failed");
    Matrix result (n, nrhs, precision);
    for (std::size_t column = 0; column < nrhs; ++column)
      for (std::size_t row = 0; row < n; ++row)
        mpc_set (result.at (row, column).mpc_data (),
                 b.at (row, column).mpc_data (),
                 MPC_RND (MPFR_RNDN, MPFR_RNDN));
    return CandidateResult {std::move (result), rank};
  };

  auto run_gelsd = [&] ()
  {
    auto a = make_a ();
    auto b = make_b ();
    octave_mplapack::MpfrMatrixStorage singular_values (minmn, 1, precision);
    Matrix work_query (1, 1, precision);
    octave_mplapack::MpfrMatrixStorage rwork_query (1, 1, precision);
    std::vector<Integer> iwork_query (1, 0);
    Integer rank = 0;
    Integer info = 0;
    octave_mplapack::MpfrMpcPrecisionScope scope (precision);
    mpfrxx::mpfr_class rcond
      = mpfrxx::mpfr_class::with_precision (precision);
    const mpfrxx::mpfr_class epsilon = Rlamch_mpfr ("E");
    mpfr_set (rcond.mpfr_data (), epsilon.mpfr_data (), MPFR_RNDN);
    Cgelsd (m_arg, n_arg, nrhs_arg, a.data (), a.leading_dimension (),
            b.data (), b.leading_dimension (), singular_values.data (), rcond,
            rank, work_query.data (), -1, rwork_query.data (),
            iwork_query.data (), info);
    check (info == 0, "Cgelsd workspace query failed");
    const Integer lwork = workspace_length (work_query.at (0, 0).real (),
                                            "Cgelsd complex");
    const Integer lrwork = workspace_length (rwork_query.at (0, 0),
                                             "Cgelsd real");
    const Integer liwork = iwork_query.at (0);
    check (liwork > 0, "Cgelsd integer workspace query failed");
    a = make_a ();
    b = make_b ();
    singular_values = octave_mplapack::MpfrMatrixStorage (minmn, 1, precision);
    Matrix work (static_cast<std::size_t> (lwork), 1, precision);
    octave_mplapack::MpfrMatrixStorage rwork (
      static_cast<std::size_t> (lrwork), 1, precision);
    std::vector<Integer> iwork (static_cast<std::size_t> (liwork));
    rank = 0;
    info = 0;
    Cgelsd (m_arg, n_arg, nrhs_arg, a.data (), a.leading_dimension (),
            b.data (), b.leading_dimension (), singular_values.data (), rcond,
            rank, work.data (), lwork, rwork.data (), iwork.data (), info);
    check (info == 0, "Cgelsd solve failed");
    Matrix result (n, nrhs, precision);
    for (std::size_t column = 0; column < nrhs; ++column)
      for (std::size_t row = 0; row < n; ++row)
        mpc_set (result.at (row, column).mpc_data (),
                 b.at (row, column).mpc_data (),
                 MPC_RND (MPFR_RNDN, MPFR_RNDN));
    return CandidateResult {std::move (result), rank};
  };

  switch (candidate)
    {
    case Candidate::gelsy: return run_gelsy ();
    case Candidate::gelss: return run_gelss ();
    case Candidate::gelsd: return run_gelsd ();
    }
  throw std::logic_error ("unknown complex rank candidate");
}

void
check_solution (const CandidateResult& result,
                const std::vector<std::complex<double>>& expected,
                Integer expected_rank, const char *label)
{
  check (result.rank == expected_rank, label);
  for (std::size_t column = 0; column < result.solution.columns (); ++column)
    for (std::size_t row = 0; row < result.solution.rows (); ++row)
      {
        const octave_mplapack::MpfrComplexScalarStorage actual (
          result.solution.at (row, column));
        check (std::abs (actual.to_double ()
                         - expected[row + result.solution.rows () * column])
                 < 1.0e-9,
               label);
      }
}

void
set_power_of_two (mpc_ptr value, unsigned long exponent)
{
  mpfr_set_ui (mpc_realref (value), 1, MPFR_RNDN);
  mpfr_div_2si (mpc_realref (value), mpc_realref (value), exponent,
                MPFR_RNDN);
  mpfr_set (mpc_imagref (value), mpc_realref (value), MPFR_RNDN);
  mpfr_neg (mpc_imagref (value), mpc_imagref (value), MPFR_RNDN);
}

} // namespace

int
main ()
{
  try
    {
      const mpfr_prec_t precision = 256;
      const Matrix overdetermined (
        3, 2, precision,
        std::vector<std::complex<double>> {
          {1.0, 0.0}, {0.0, 0.0}, {1.0, 0.0},
          {0.0, 0.0}, {1.0, 0.0}, {1.0, 0.0}});
      const Matrix over_rhs (
        3, 2, precision,
        std::vector<std::complex<double>> {
          {1.0, 2.0}, {3.0, 0.0}, {4.0, 2.0},
          {2.0, -1.0}, {-1.0, 4.0}, {1.0, 3.0}});
      const std::vector<std::complex<double>> over_expected {
        {1.0, 2.0}, {3.0, 0.0}, {2.0, -1.0}, {-1.0, 4.0}};
      for (Candidate candidate : {Candidate::gelsy, Candidate::gelss,
                                  Candidate::gelsd})
        {
          const CandidateResult result = run_candidate (
            candidate, overdetermined, over_rhs, precision);
          check_solution (result, over_expected, 2, candidate_name (candidate));
          std::cout << "PASS: " << candidate_name (candidate)
                    << " full-column-rank multiple-RHS audit\n";
        }

      const Matrix underdetermined (
        2, 3, precision,
        std::vector<std::complex<double>> {
          {1.0, 0.0}, {0.0, 0.0}, {0.0, 0.0},
          {1.0, 0.0}, {1.0, 0.0}, {1.0, 0.0}});
      const Matrix under_rhs (
        2, 1, precision,
        std::vector<std::complex<double>> {{3.0, 3.0}, {3.0, 3.0}});
      const std::vector<std::complex<double>> under_expected {
        {1.0, 1.0}, {1.0, 1.0}, {2.0, 2.0}};
      for (Candidate candidate : {Candidate::gelsy, Candidate::gelss,
                                  Candidate::gelsd})
        check_solution (run_candidate (candidate, underdetermined, under_rhs,
                                       precision), under_expected, 2,
                        candidate_name (candidate));

      const Matrix rank_deficient (
        3, 2, precision,
        std::vector<std::complex<double>> {
          {1.0, 0.0}, {2.0, 0.0}, {3.0, 0.0},
          {0.0, 0.0}, {0.0, 0.0}, {0.0, 0.0}});
      const Matrix rank_deficient_rhs (
        3, 1, precision,
        std::vector<std::complex<double>> {{1.0, 2.0}, {2.0, 4.0},
                                            {3.0, 6.0}});
      const std::vector<std::complex<double>> rank_expected {
        {1.0, 2.0}, {0.0, 0.0}};
      for (Candidate candidate : {Candidate::gelsy, Candidate::gelss,
                                  Candidate::gelsd})
        check_solution (run_candidate (candidate, rank_deficient,
                                       rank_deficient_rhs, precision),
                        rank_expected, 1, candidate_name (candidate));

      for (const std::array<unsigned long, 2> settings : {
             std::array<unsigned long, 2> {{1024, 700}},
             std::array<unsigned long, 2> {{2048, 1500}}})
        {
          const mpfr_prec_t canary_precision
            = static_cast<mpfr_prec_t> (settings[0]);
          Matrix lhs (
            3, 2, canary_precision,
            std::vector<std::complex<double>> {
              {1.0, 0.0}, {0.0, 0.0}, {0.0, 0.0},
              {0.0, 0.0}, {1.0, 0.0}, {0.0, 0.0}});
          Matrix rhs (3, 1, canary_precision);
          set_power_of_two (rhs.at (0, 0).mpc_data (), settings[1]);
          set_power_of_two (rhs.at (1, 0).mpc_data (), settings[1]);
          const Matrix lhs_before (lhs);
          const Matrix rhs_before (rhs);
          mpfrxx::set_default_precision_bits (128);
          const auto result = octave_mplapack::mplapack_mpc_matrix_rank_solve (
            lhs, rhs);
          check (result.rank == 2, "Cgelsy canary rank mismatch");
          check (result.solution.precision_bits () == canary_precision,
                 "Cgelsy canary precision mismatch");
          check (result.solution.element_exactly_equal (
                   0, 0, rhs_before, 0, 0),
                 "Cgelsy real canary changed");
          check (result.solution.element_exactly_equal (
                   1, 0, rhs_before, 1, 0),
                 "Cgelsy imaginary canary changed");
          check (lhs.element_exactly_equal (0, 0, lhs_before, 0, 0)
                   && rhs.element_exactly_equal (0, 0, rhs_before, 0, 0),
                 "Cgelsy mutated public operands");
          check (mpfrxx::default_precision_bits () == 128,
                 "Cgelsy changed ambient precision");
        }

      const Matrix empty_lhs (0, 2, 256);
      const Matrix empty_rhs (0, 1, 256);
      const auto empty = octave_mplapack::mplapack_mpc_matrix_rank_solve (
        empty_lhs, empty_rhs);
      check (empty.solution.rows () == 2 && empty.solution.columns () == 1
               && empty.rank == 0,
             "Cgelsy empty shape mismatch");

      std::cout << "PASS: complex rank-revealing candidate audit, Cgelsy selection, minimum norm, precision, workspace, shapes, and immutability\n";
      return 0;
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
}
