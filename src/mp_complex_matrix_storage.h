// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_COMPLEX_MATRIX_STORAGE_H
#define OCTAVE_MPLAPACK_MP_COMPLEX_MATRIX_STORAGE_H

#include <cstddef>
#include <complex>
#include <string>
#include <vector>

#include <mplapack_config.h>

#include "mp_complex_scalar_storage.h"

namespace octave_mplapack
{

class MpfrComplexMatrixStorage
{
public:
  using NativeScalar = MpfrComplexScalarStorage::NativeScalar;
  using MplapackInteger = mplapackint;

  MpfrComplexMatrixStorage (std::size_t rows, std::size_t columns,
                            mpfr_prec_t precision_bits);
  MpfrComplexMatrixStorage (std::size_t rows, std::size_t columns,
                            mpfr_prec_t precision_bits,
                            const std::vector<std::complex<double>>& values);
  MpfrComplexMatrixStorage (std::size_t rows, std::size_t columns,
                            mpfr_prec_t precision_bits,
                            const std::vector<std::string>& values);
  MpfrComplexMatrixStorage (const MpfrComplexMatrixStorage&) = default;
  MpfrComplexMatrixStorage (MpfrComplexMatrixStorage&&) noexcept = default;
  ~MpfrComplexMatrixStorage () = default;

  MpfrComplexMatrixStorage& operator= (MpfrComplexMatrixStorage other) noexcept;
  void swap (MpfrComplexMatrixStorage& other) noexcept;

  std::size_t rows () const noexcept;
  std::size_t columns () const noexcept;
  std::size_t numel () const noexcept;
  mpfr_prec_t precision_bits () const noexcept;
  MplapackInteger leading_dimension () const;

  NativeScalar* data () noexcept;
  const NativeScalar* data () const noexcept;
  NativeScalar& at (std::size_t row, std::size_t column);
  const NativeScalar& at (std::size_t row, std::size_t column) const;

  bool all_elements_have_uniform_precision () const noexcept;
  bool element_exactly_equal_text (std::size_t row, std::size_t column,
                                   const std::string& text) const;
  bool element_exactly_equal_double (std::size_t row, std::size_t column,
                                     const std::complex<double>& value) const
    noexcept;
  bool element_exactly_equal (std::size_t row, std::size_t column,
                              const MpfrComplexMatrixStorage& other,
                              std::size_t other_row,
                              std::size_t other_column) const;
  static std::size_t checked_element_count (std::size_t rows,
                                            std::size_t columns);
  static MplapackInteger checked_mplapack_dimension (std::size_t value);

private:
  static std::vector<NativeScalar> make_elements (std::size_t count,
                                                  mpfr_prec_t precision_bits);
  std::size_t offset (std::size_t row, std::size_t column) const;

  std::size_t m_rows;
  std::size_t m_columns;
  mpfr_prec_t m_precision_bits;
  std::vector<NativeScalar> m_values;
};

void swap (MpfrComplexMatrixStorage& lhs,
           MpfrComplexMatrixStorage& rhs) noexcept;

} // namespace octave_mplapack

#endif
