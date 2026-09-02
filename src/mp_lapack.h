// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_LAPACK_H
#define OCTAVE_MPLAPACK_MP_LAPACK_H

#include <stdexcept>

#include <mplapack_gmpfrxx_mkII_config.h>
#include <mplapack_mpfr_precision.h>
#include <mpfrxx_mkII.h>

#include "mp_matrix_storage.h"

namespace octave_mplapack
{

class MpfrRgesvError : public std::runtime_error
{
public:
  enum class Kind
  {
    singular,
    invalid_argument
  };

  MpfrRgesvError (Kind kind, int info, const char *message)
    : std::runtime_error (message), m_kind (kind), m_info (info)
  {
  }

  Kind kind () const noexcept { return m_kind; }
  int info () const noexcept { return m_info; }

private:
  Kind m_kind;
  int m_info;
};

class MpfrRgelsError : public std::runtime_error
{
public:
  enum class Kind
  {
    rank_deficient,
    invalid_argument
  };

  MpfrRgelsError (Kind kind, int info, const char *message)
    : std::runtime_error (message), m_kind (kind), m_info (info)
  {
  }

  Kind kind () const noexcept { return m_kind; }
  int info () const noexcept { return m_info; }

private:
  Kind m_kind;
  int m_info;
};

class MpfrRpotrfError : public std::runtime_error
{
public:
  enum class Kind
  {
    invalid_argument,
    internal
  };

  MpfrRpotrfError (Kind kind, int info, const char *message)
    : std::runtime_error (message), m_kind (kind), m_info (info)
  {
  }

  Kind kind () const noexcept { return m_kind; }
  int info () const noexcept { return m_info; }

private:
  Kind m_kind;
  int m_info;
};

class MpfrRankRevealingError : public std::runtime_error
{
public:
  enum class Kind
  {
    convergence,
    invalid_argument,
    internal
  };

  MpfrRankRevealingError (Kind kind, int info, const char *message)
    : std::runtime_error (message), m_kind (kind), m_info (info)
  {
  }

  Kind kind () const noexcept { return m_kind; }
  int info () const noexcept { return m_info; }

private:
  Kind m_kind;
  int m_info;
};

struct MpfrRankRevealingSolveResult
{
  MpfrMatrixStorage solution;
  MpfrMatrixStorage::MplapackInteger rank;
};

struct MpfrCholeskyResult
{
  MpfrMatrixStorage factor;
  MpfrMatrixStorage::MplapackInteger info;
};

void require_mplapack_mpfr_solve_precision_contract (
  mpfr_prec_t operation_precision,
  const MpfrMatrixStorage& a_work,
  const MpfrMatrixStorage& b_work);

void require_mplapack_mpfr_rgels_precision_contract (
  mpfr_prec_t operation_precision,
  const MpfrMatrixStorage& a_work,
  const MpfrMatrixStorage& b_work,
  const MpfrMatrixStorage& work);

void require_mplapack_mpfr_rank_precision_contract (
  mpfr_prec_t operation_precision,
  const MpfrMatrixStorage& a_work,
  const MpfrMatrixStorage& b_work,
  const mpfrxx::mpfr_class& rcond,
  const MpfrMatrixStorage& singular_values,
  const MpfrMatrixStorage& work);

void require_mplapack_mpfr_rpotrf_precision_contract (
  mpfr_prec_t operation_precision, const MpfrMatrixStorage& a_work);

MpfrMatrixStorage mplapack_mpfr_matrix_solve (
  const MpfrMatrixStorage& lhs, const MpfrMatrixStorage& rhs);

MpfrMatrixStorage mplapack_mpfr_matrix_rectangular_solve (
  const MpfrMatrixStorage& lhs, const MpfrMatrixStorage& rhs);

MpfrRankRevealingSolveResult
mplapack_mpfr_matrix_rank_revealing_solve (
  const MpfrMatrixStorage& lhs, const MpfrMatrixStorage& rhs);

MpfrCholeskyResult mplapack_mpfr_matrix_cholesky (
  const MpfrMatrixStorage& input, bool lower);

MpfrMatrixStorage mplapack_mpfr_matrix_left_divide (
  const MpfrMatrixStorage& rhs,
  const mpfrxx::mpfr_class& lhs);

MpfrMatrixStorage mplapack_mpfr_matrix_left_divide (
  const MpfrMatrixStorage& rhs, double lhs);

} // namespace octave_mplapack

#endif
