// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_MATRIX_STORAGE_H
#define OCTAVE_MPLAPACK_MP_MATRIX_STORAGE_H

#include <cstddef>
#include <string>
#include <vector>

#include <mplapack_config.h>

#include "mp_scalar_storage.h"

namespace octave_mplapack
{

class MpfrMatrixStorage
{
public:
  using NativeScalar = MpfrScalarStorage::NativeScalar;
  using MplapackInteger = mplapackint;

  MpfrMatrixStorage (std::size_t rows, std::size_t columns,
                     mpfr_prec_t precision_bits);
  MpfrMatrixStorage (std::size_t rows, std::size_t columns,
                     mpfr_prec_t precision_bits,
                     const std::vector<double>& column_major_values);
  MpfrMatrixStorage (std::size_t rows, std::size_t columns,
                     mpfr_prec_t precision_bits,
                     const std::vector<std::string>& column_major_values);
  MpfrMatrixStorage (std::size_t rows, std::size_t columns,
                     mpfr_prec_t precision_bits,
                     const MpfrMatrixStorage& source);
  MpfrMatrixStorage (const MpfrMatrixStorage&) = default;
  MpfrMatrixStorage (MpfrMatrixStorage&&) noexcept = default;
  ~MpfrMatrixStorage () = default;

  MpfrMatrixStorage& operator= (MpfrMatrixStorage other) noexcept;
  void swap (MpfrMatrixStorage& other) noexcept;

  std::size_t rows () const noexcept;
  std::size_t columns () const noexcept;
  std::size_t numel () const noexcept;
  mpfr_prec_t precision_bits () const noexcept;
  MplapackInteger leading_dimension () const;

  NativeScalar * data () noexcept;
  const NativeScalar * data () const noexcept;

  NativeScalar& at (std::size_t row, std::size_t column);
  const NativeScalar& at (std::size_t row, std::size_t column) const;

  bool all_elements_have_uniform_precision () const noexcept;
  bool element_exactly_equal_text (std::size_t row, std::size_t column,
                                   const std::string& text) const;
  bool element_exactly_equal_double (std::size_t row, std::size_t column,
                                     double value) const noexcept;
  bool element_exactly_equal (std::size_t row, std::size_t column,
                              const MpfrMatrixStorage& other,
                              std::size_t other_row,
                              std::size_t other_column) const;

  static std::size_t checked_element_count (std::size_t rows,
                                             std::size_t columns);
  static MplapackInteger checked_mplapack_dimension (std::size_t value);

private:
  static std::vector<NativeScalar> make_elements (
    std::size_t count, mpfr_prec_t precision_bits);
  std::size_t offset (std::size_t row, std::size_t column) const;

  std::size_t m_rows;
  std::size_t m_columns;
  mpfr_prec_t m_precision_bits;
  std::vector<NativeScalar> m_values;
};

void swap (MpfrMatrixStorage& lhs, MpfrMatrixStorage& rhs) noexcept;

} // namespace octave_mplapack

#endif
