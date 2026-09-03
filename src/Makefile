MKOCTFILE ?= mkoctfile
PKG_CONFIG ?= pkg-config
MPLAPACK_PC ?= mplapack_mpfr
CXX ?= c++

TARGET = __mplapack_core__.oct
SOURCE = octave_bridge.cc mp_value.cc mp_matrix_value.cc mp_blas.cc mp_lapack.cc \
  mp_scalar_storage.cc mp_matrix_storage.cc mp_matrix_inspection.cc \
  mp_matrix_arithmetic.cc mp_matrix_structure.cc mp_matrix_concat.cc \
  mp_matrix_assignment.cc \
  mp_arithmetic.cc mp_precision.cc mp_complex_precision.cc \
  mp_complex_scalar_storage.cc mp_complex_matrix_storage.cc \
  mp_complex_value.cc mp_complex_matrix_value.cc mp_complex_structure.cc \
  mp_complex_arithmetic.cc mp_complex_blas.cc
HEADERS = mp_value.h mp_matrix_value.h mp_scalar_storage.h \
  mp_matrix_storage.h mp_matrix_inspection.h mp_matrix_arithmetic.h \
  mp_matrix_structure.h mp_matrix_concat.h \
  mp_matrix_assignment.h \
  mp_precision.h mp_blas.h \
  mp_lapack.h mp_complex_precision.h mp_complex_scalar_storage.h \
  mp_complex_matrix_storage.h mp_complex_value.h mp_complex_matrix_value.h \
  mp_complex_structure.h mp_complex_arithmetic.h mp_complex_blas.h
STORAGE_TEST = .build-m02/mp_scalar_storage_test
ARITHMETIC_TEST = .build-m06/mp_scalar_arithmetic_test
MATRIX_TEST = .build-m07/mp_matrix_storage_test
BLAS_TEST = .build-m08/mp_blas_test
LAPACK_TEST = .build-m09/mp_lapack_test
INSPECTION_TEST = .build-m10/mp_matrix_inspection_test
ELEMENTWISE_TEST = .build-m11/mp_matrix_arithmetic_test
STRUCTURE_TEST = .build-m12/mp_matrix_structure_test
CONCAT_TEST = .build-m13/mp_matrix_concat_test
ASSIGNMENT_TEST = .build-m14/mp_matrix_assignment_test
RGELS_TEST = .build-m15/mp_lapack_rgels_test
RANK_TEST = .build-m16/mp_lapack_rank_test
CHOLESKY_TEST = .build-m17/mp_lapack_cholesky_test
QR_TEST = .build-m18/mp_lapack_qr_test
PIVOTED_QR_TEST = .build-m19/mp_lapack_pivoted_qr_test
LU_TEST = .build-m21/mp_lapack_lu_test
DEPENDENCY_TEST = .build-m22/m22_dependency_probe
CPLX_STORAGE_TEST = .build-c00/mp_complex_storage_test
CPLX_STRUCTURE_TEST = .build-c03/mp_complex_structure_test
CPLX_ARITHMETIC_TEST = .build-c04/mp_complex_arithmetic_test
CPLX_BLAS_TEST = .build-c05/mp_complex_blas_test
MPLAPACK_VERSION := $(shell $(PKG_CONFIG) --modversion $(MPLAPACK_PC) 2>/dev/null)
MPLAPACK_CFLAGS ?= $(shell $(PKG_CONFIG) --cflags $(MPLAPACK_PC) 2>/dev/null)
MPLAPACK_LIBS ?= $(shell $(PKG_CONFIG) --libs $(MPLAPACK_PC) 2>/dev/null)
PACKAGE_CXXFLAGS = -std=c++17 -DMPLAPACK_PKG_VERSION=$(MPLAPACK_VERSION)
SANITIZER_FLAGS = -fsanitize=address,undefined -fno-omit-frame-pointer

.PHONY: all check-deps check-dependency check-storage-sanitized \
  check-arithmetic-sanitized check-matrix-sanitized check-blas \
  check-lapack check-inspection check-elementwise check-structure \
  check-concat check-assignment check-rgels check-rank check-cholesky check-qr \
  check-pivoted-qr check-lu check-complex-storage check-complex-structure \
  check-complex-arithmetic check-complex-blas clean
.DELETE_ON_ERROR:

all: $(TARGET)

$(TARGET): $(SOURCE) $(HEADERS) | check-dependency
	@echo "Building $(TARGET) with MKOCTFILE=$(MKOCTFILE)"
	$(MKOCTFILE) $(PACKAGE_CXXFLAGS) $(MPLAPACK_CFLAGS) $(SOURCE) \
	  $(MPLAPACK_LIBS) -o $@

$(STORAGE_TEST): ../test/mp_scalar_storage_test.cc \
  mp_scalar_storage.cc mp_scalar_storage.h mp_precision.cc mp_precision.h \
  | check-deps
	mkdir -p $(dir $@)
	$(CXX) -std=c++17 -Wall -Wextra -Wpedantic -pthread $(SANITIZER_FLAGS) \
	  $(MPLAPACK_CFLAGS) -I. ../test/mp_scalar_storage_test.cc \
	  mp_scalar_storage.cc mp_precision.cc $(MPLAPACK_LIBS) -o $@

$(ARITHMETIC_TEST): ../test/mp_scalar_arithmetic_test.cc \
  mp_scalar_storage.cc mp_scalar_storage.h mp_arithmetic.cc \
  mp_precision.cc mp_precision.h | check-deps
	mkdir -p $(dir $@)
	$(CXX) -std=c++17 -Wall -Wextra -Wpedantic $(SANITIZER_FLAGS) \
	  $(MPLAPACK_CFLAGS) -I. ../test/mp_scalar_arithmetic_test.cc \
	  mp_scalar_storage.cc mp_arithmetic.cc mp_precision.cc \
	  $(MPLAPACK_LIBS) -o $@

check-storage-sanitized: $(STORAGE_TEST)
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 \
	UBSAN_OPTIONS=halt_on_error=1 $(STORAGE_TEST)

check-arithmetic-sanitized: $(ARITHMETIC_TEST)
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 \
	UBSAN_OPTIONS=halt_on_error=1 $(ARITHMETIC_TEST)

$(MATRIX_TEST): ../test/mp_matrix_storage_test.cc \
  mp_matrix_storage.cc mp_matrix_storage.h mp_scalar_storage.h | check-deps
	mkdir -p $(dir $@)
	$(CXX) -std=c++17 -Wall -Wextra -Wpedantic $(SANITIZER_FLAGS) \
	  $(MPLAPACK_CFLAGS) -I. ../test/mp_matrix_storage_test.cc \
	  mp_matrix_storage.cc $(MPLAPACK_LIBS) -o $@

check-matrix-sanitized: $(MATRIX_TEST)
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 \
	UBSAN_OPTIONS=halt_on_error=1 $(MATRIX_TEST)

$(BLAS_TEST): ../test/mp_blas_test.cc mp_blas.cc mp_blas.h \
  mp_matrix_storage.cc mp_matrix_storage.h mp_scalar_storage.h | check-deps
	mkdir -p $(dir $@)
	$(CXX) -std=c++17 -Wall -Wextra -Wpedantic -pthread $(SANITIZER_FLAGS) \
	  $(MPLAPACK_CFLAGS) -I. ../test/mp_blas_test.cc mp_blas.cc \
	  mp_matrix_storage.cc $(MPLAPACK_LIBS) -o $@

check-blas: $(BLAS_TEST)
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 \
	UBSAN_OPTIONS=halt_on_error=1 $(BLAS_TEST)

$(LAPACK_TEST): ../test/mp_lapack_test.cc mp_lapack.cc mp_lapack.h \
  mp_matrix_storage.cc mp_matrix_storage.h mp_scalar_storage.h | check-deps
	mkdir -p $(dir $@)
	$(CXX) -std=c++17 -Wall -Wextra -Wpedantic -pthread $(SANITIZER_FLAGS) \
	  $(MPLAPACK_CFLAGS) -I. ../test/mp_lapack_test.cc mp_lapack.cc \
	  mp_matrix_storage.cc $(MPLAPACK_LIBS) -o $@

check-lapack: $(LAPACK_TEST)
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 \
	UBSAN_OPTIONS=halt_on_error=1 $(LAPACK_TEST)

$(INSPECTION_TEST): ../test/mp_matrix_inspection_test.cc \
  mp_matrix_inspection.cc mp_matrix_inspection.h mp_matrix_storage.cc \
  mp_matrix_storage.h mp_scalar_storage.cc mp_scalar_storage.h \
  mp_complex_matrix_storage.cc mp_complex_matrix_storage.h \
  mp_complex_scalar_storage.cc mp_complex_scalar_storage.h \
  mp_complex_precision.cc mp_complex_precision.h | check-deps
	mkdir -p $(dir $@)
	$(CXX) -std=c++17 -Wall -Wextra -Wpedantic $(SANITIZER_FLAGS) \
	  $(MPLAPACK_CFLAGS) -I. ../test/mp_matrix_inspection_test.cc \
	  mp_matrix_inspection.cc mp_matrix_storage.cc mp_scalar_storage.cc \
	  mp_complex_matrix_storage.cc mp_complex_scalar_storage.cc \
	  mp_complex_precision.cc \
	  $(MPLAPACK_LIBS) -o $@

check-inspection: $(INSPECTION_TEST)
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 \
	UBSAN_OPTIONS=halt_on_error=1 $(INSPECTION_TEST)

$(ELEMENTWISE_TEST): ../test/mp_matrix_arithmetic_test.cc \
  mp_matrix_arithmetic.cc mp_matrix_arithmetic.h mp_matrix_storage.cc \
  mp_matrix_storage.h mp_scalar_storage.cc mp_scalar_storage.h | check-deps
	mkdir -p $(dir $@)
	$(CXX) -std=c++17 -Wall -Wextra -Wpedantic $(SANITIZER_FLAGS) \
	  $(MPLAPACK_CFLAGS) -I. ../test/mp_matrix_arithmetic_test.cc \
	  mp_matrix_arithmetic.cc mp_matrix_storage.cc mp_scalar_storage.cc \
	  $(MPLAPACK_LIBS) -o $@

check-elementwise: $(ELEMENTWISE_TEST)
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 \
	UBSAN_OPTIONS=halt_on_error=1 $(ELEMENTWISE_TEST)

$(STRUCTURE_TEST): ../test/mp_matrix_structure_test.cc \
  mp_matrix_structure.cc mp_matrix_structure.h mp_matrix_storage.cc \
  mp_matrix_storage.h mp_scalar_storage.cc mp_scalar_storage.h \
  mp_complex_matrix_storage.cc mp_complex_matrix_storage.h \
  mp_complex_scalar_storage.cc mp_complex_scalar_storage.h \
  mp_complex_precision.cc mp_complex_precision.h | check-deps
	mkdir -p $(dir $@)
	$(CXX) -std=c++17 -Wall -Wextra -Wpedantic $(SANITIZER_FLAGS) \
	  $(MPLAPACK_CFLAGS) -I. ../test/mp_matrix_structure_test.cc \
	  mp_matrix_structure.cc mp_matrix_storage.cc mp_scalar_storage.cc \
	  mp_complex_matrix_storage.cc mp_complex_scalar_storage.cc \
	  mp_complex_precision.cc \
	  $(MPLAPACK_LIBS) -o $@

check-structure: $(STRUCTURE_TEST)
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 \
	UBSAN_OPTIONS=halt_on_error=1 $(STRUCTURE_TEST)

$(CONCAT_TEST): ../test/mp_matrix_concat_test.cc \
  mp_matrix_concat.cc mp_matrix_concat.h mp_matrix_storage.cc \
  mp_matrix_storage.h mp_scalar_storage.cc mp_scalar_storage.h | check-deps
	mkdir -p $(dir $@)
	$(CXX) -std=c++17 -Wall -Wextra -Wpedantic $(SANITIZER_FLAGS) \
	  $(MPLAPACK_CFLAGS) -I. ../test/mp_matrix_concat_test.cc \
	  mp_matrix_concat.cc mp_matrix_storage.cc mp_scalar_storage.cc \
	  $(MPLAPACK_LIBS) -o $@

check-concat: $(CONCAT_TEST)
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 \
	UBSAN_OPTIONS=halt_on_error=1 $(CONCAT_TEST)

$(ASSIGNMENT_TEST): ../test/mp_matrix_assignment_test.cc \
  mp_matrix_assignment.cc mp_matrix_assignment.h mp_matrix_storage.cc \
  mp_matrix_storage.h mp_scalar_storage.cc mp_scalar_storage.h | check-deps
	mkdir -p $(dir $@)
	$(CXX) -std=c++17 -Wall -Wextra -Wpedantic $(SANITIZER_FLAGS) \
	  $(MPLAPACK_CFLAGS) -I. ../test/mp_matrix_assignment_test.cc \
	  mp_matrix_assignment.cc mp_matrix_storage.cc mp_scalar_storage.cc \
	  $(MPLAPACK_LIBS) -o $@

check-assignment: $(ASSIGNMENT_TEST)
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 \
	UBSAN_OPTIONS=halt_on_error=1 $(ASSIGNMENT_TEST)

$(RGELS_TEST): ../test/mp_lapack_rgels_test.cc mp_lapack.cc mp_lapack.h \
  mp_matrix_storage.cc mp_matrix_storage.h mp_scalar_storage.h | check-deps
	mkdir -p $(dir $@)
	$(CXX) -std=c++17 -Wall -Wextra -Wpedantic -pthread $(SANITIZER_FLAGS) \
	  $(MPLAPACK_CFLAGS) -I. ../test/mp_lapack_rgels_test.cc mp_lapack.cc \
	  mp_matrix_storage.cc $(MPLAPACK_LIBS) -o $@

check-rgels: $(RGELS_TEST)
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 \
	UBSAN_OPTIONS=halt_on_error=1 $(RGELS_TEST)

$(RANK_TEST): ../test/mp_lapack_rank_test.cc mp_lapack.cc mp_lapack.h \
  mp_matrix_storage.cc mp_matrix_storage.h mp_scalar_storage.h | check-deps
	mkdir -p $(dir $@)
	$(CXX) -std=c++17 -Wall -Wextra -Wpedantic -pthread $(SANITIZER_FLAGS) \
	  $(MPLAPACK_CFLAGS) -I. ../test/mp_lapack_rank_test.cc mp_lapack.cc \
	  mp_matrix_storage.cc $(MPLAPACK_LIBS) -o $@

check-rank: $(RANK_TEST)
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 \
	UBSAN_OPTIONS=halt_on_error=1 $(RANK_TEST)

$(CHOLESKY_TEST): ../test/mp_lapack_cholesky_test.cc mp_lapack.cc mp_lapack.h \
  mp_matrix_storage.cc mp_matrix_storage.h mp_scalar_storage.h | check-deps
	mkdir -p $(dir $@)
	$(CXX) -std=c++17 -Wall -Wextra -Wpedantic -pthread $(SANITIZER_FLAGS) \
	  $(MPLAPACK_CFLAGS) -I. ../test/mp_lapack_cholesky_test.cc mp_lapack.cc \
	  mp_matrix_storage.cc $(MPLAPACK_LIBS) -o $@

check-cholesky: $(CHOLESKY_TEST)
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 \
	UBSAN_OPTIONS=halt_on_error=1 $(CHOLESKY_TEST)

$(QR_TEST): ../test/mp_lapack_qr_test.cc mp_lapack.cc mp_lapack.h \
  mp_matrix_storage.cc mp_matrix_storage.h mp_scalar_storage.h | check-deps
	mkdir -p $(dir $@)
	$(CXX) -std=c++17 -Wall -Wextra -Wpedantic -pthread $(SANITIZER_FLAGS) \
	  $(MPLAPACK_CFLAGS) -I. ../test/mp_lapack_qr_test.cc mp_lapack.cc \
	  mp_matrix_storage.cc $(MPLAPACK_LIBS) -o $@

check-qr: $(QR_TEST)
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 \
	UBSAN_OPTIONS=halt_on_error=1 $(QR_TEST)

$(PIVOTED_QR_TEST): ../test/mp_lapack_pivoted_qr_test.cc mp_lapack.cc mp_lapack.h \
  mp_matrix_storage.cc mp_matrix_storage.h mp_scalar_storage.h | check-deps
	mkdir -p $(dir $@)
	$(CXX) -std=c++17 -Wall -Wextra -Wpedantic -pthread $(SANITIZER_FLAGS) \
	  $(MPLAPACK_CFLAGS) -I. ../test/mp_lapack_pivoted_qr_test.cc mp_lapack.cc \
	  mp_matrix_storage.cc $(MPLAPACK_LIBS) -o $@

check-pivoted-qr: $(PIVOTED_QR_TEST)
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 \
	UBSAN_OPTIONS=halt_on_error=1 $(PIVOTED_QR_TEST)

$(LU_TEST): ../test/mp_lapack_lu_test.cc mp_lapack.cc mp_lapack.h \
  mp_matrix_storage.cc mp_matrix_storage.h mp_scalar_storage.h | check-deps
	mkdir -p $(dir $@)
	$(CXX) -std=c++17 -Wall -Wextra -Wpedantic -pthread $(SANITIZER_FLAGS) \
	  $(MPLAPACK_CFLAGS) -I. ../test/mp_lapack_lu_test.cc mp_lapack.cc \
	  mp_matrix_storage.cc $(MPLAPACK_LIBS) -o $@

check-lu: $(LU_TEST)
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 \
	UBSAN_OPTIONS=halt_on_error=1 $(LU_TEST)

$(DEPENDENCY_TEST): ../test/m22_dependency_probe.cc | check-deps
	mkdir -p $(dir $@)
	$(CXX) -std=c++17 -Wall -Wextra -Wpedantic -pthread \
	  $(MPLAPACK_CFLAGS) -I. ../test/m22_dependency_probe.cc \
	  $(MPLAPACK_LIBS) -o $@

check-dependency: $(DEPENDENCY_TEST)
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 \
	UBSAN_OPTIONS=halt_on_error=1 $(DEPENDENCY_TEST)

$(CPLX_STORAGE_TEST): ../test/mp_complex_storage_test.cc \
  mp_complex_precision.cc mp_complex_precision.h \
  mp_complex_scalar_storage.cc mp_complex_scalar_storage.h \
  mp_complex_matrix_storage.cc mp_complex_matrix_storage.h \
  mp_scalar_storage.cc mp_scalar_storage.h | check-deps
	mkdir -p $(dir $@)
	$(CXX) -std=c++17 -Wall -Wextra -Wpedantic -pthread $(SANITIZER_FLAGS) \
	  $(MPLAPACK_CFLAGS) -I. ../test/mp_complex_storage_test.cc \
	  mp_complex_precision.cc mp_complex_scalar_storage.cc \
	  mp_complex_matrix_storage.cc mp_scalar_storage.cc $(MPLAPACK_LIBS) -o $@

check-complex-storage: $(CPLX_STORAGE_TEST)
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 \
	UBSAN_OPTIONS=halt_on_error=1 $(CPLX_STORAGE_TEST)

$(CPLX_STRUCTURE_TEST): ../test/mp_complex_structure_test.cc \
  mp_complex_structure.cc mp_complex_structure.h mp_matrix_structure.cc \
  mp_matrix_structure.h mp_complex_matrix_storage.cc \
  mp_complex_matrix_storage.h mp_complex_scalar_storage.cc \
  mp_complex_scalar_storage.h mp_complex_precision.cc \
  mp_complex_precision.h mp_matrix_storage.cc mp_matrix_storage.h \
  mp_scalar_storage.cc mp_scalar_storage.h | check-deps
	mkdir -p $(dir $@)
	$(CXX) -std=c++17 -Wall -Wextra -Wpedantic -pthread $(SANITIZER_FLAGS) \
	  $(MPLAPACK_CFLAGS) -I. ../test/mp_complex_structure_test.cc \
	  mp_complex_structure.cc mp_matrix_structure.cc \
	  mp_complex_matrix_storage.cc mp_complex_scalar_storage.cc \
	  mp_complex_precision.cc mp_matrix_storage.cc mp_scalar_storage.cc \
	  $(MPLAPACK_LIBS) -o $@

check-complex-structure: $(CPLX_STRUCTURE_TEST)
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 \
	UBSAN_OPTIONS=halt_on_error=1 $(CPLX_STRUCTURE_TEST)

$(CPLX_ARITHMETIC_TEST): ../test/mp_complex_arithmetic_test.cc \
  mp_complex_arithmetic.cc mp_complex_arithmetic.h \
  mp_complex_matrix_storage.cc mp_complex_matrix_storage.h \
  mp_complex_scalar_storage.cc mp_complex_scalar_storage.h \
  mp_complex_precision.cc mp_complex_precision.h \
  mp_scalar_storage.cc mp_scalar_storage.h | check-deps
	mkdir -p $(dir $@)
	$(CXX) -std=c++17 -Wall -Wextra -Wpedantic -pthread $(SANITIZER_FLAGS) \
	  $(MPLAPACK_CFLAGS) -I. ../test/mp_complex_arithmetic_test.cc \
	  mp_complex_arithmetic.cc mp_complex_matrix_storage.cc \
	  mp_complex_scalar_storage.cc mp_complex_precision.cc \
	  mp_matrix_storage.cc mp_scalar_storage.cc $(MPLAPACK_LIBS) -o $@

check-complex-arithmetic: $(CPLX_ARITHMETIC_TEST)
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 \
	UBSAN_OPTIONS=halt_on_error=1 $(CPLX_ARITHMETIC_TEST)

$(CPLX_BLAS_TEST): ../test/mp_complex_blas_test.cc \
  mp_complex_blas.cc mp_complex_blas.h mp_complex_matrix_storage.cc \
  mp_complex_matrix_storage.h mp_complex_scalar_storage.cc \
  mp_complex_scalar_storage.h mp_complex_precision.cc \
  mp_complex_precision.h mp_matrix_storage.cc mp_matrix_storage.h \
  mp_scalar_storage.cc mp_scalar_storage.h | check-deps
	mkdir -p $(dir $@)
	$(CXX) -std=c++17 -Wall -Wextra -Wpedantic -pthread $(SANITIZER_FLAGS) \
	  $(MPLAPACK_CFLAGS) -I. ../test/mp_complex_blas_test.cc \
	  mp_complex_blas.cc mp_complex_matrix_storage.cc \
	  mp_complex_scalar_storage.cc mp_complex_precision.cc \
	  mp_matrix_storage.cc mp_scalar_storage.cc $(MPLAPACK_LIBS) -o $@

check-complex-blas: $(CPLX_BLAS_TEST)
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 \
	UBSAN_OPTIONS=halt_on_error=1 $(CPLX_BLAS_TEST)

check-deps:
	@$(MKOCTFILE) --help >/dev/null 2>&1 || { \
	  echo "FAIL: mkoctfile command not found: $(MKOCTFILE)" >&2; exit 1; }
	@command -v "$(PKG_CONFIG)" >/dev/null 2>&1 || { \
	  echo "FAIL: pkg-config command not found: $(PKG_CONFIG)" >&2; exit 1; }
	@$(PKG_CONFIG) --atleast-version=3.0.0 "$(MPLAPACK_PC)" || { \
	  echo "FAIL: $(MPLAPACK_PC) >= 3.0.0 is required" >&2; exit 1; }
	@test -f "$$($(PKG_CONFIG) --variable=includedir $(MPLAPACK_PC))/mplapack_mpfr_precision.h" || { \
	  echo "FAIL: installed MPLAPACK MPFR precision scope header is required" >&2; exit 1; }
	@case "$(MPLAPACK_VERSION)" in \
	  ''|*[!A-Za-z0-9._+-]*) \
	    echo "FAIL: unsafe $(MPLAPACK_PC) version: $(MPLAPACK_VERSION)" >&2; \
	    exit 1;; \
	esac
	@echo "PASS: $(MPLAPACK_PC) $(MPLAPACK_VERSION)"

clean:
	$(RM) $(TARGET) *.o *.lo
	$(RM) -r .libs .deps .build-m02 .build-m06 .build-m07 .build-m08 .build-m09 .build-m10 .build-m11 .build-m12 .build-m13 .build-m14 .build-m15 .build-m16 .build-m17 .build-m18 .build-m19 .build-m21 .build-m22 .build-c00
