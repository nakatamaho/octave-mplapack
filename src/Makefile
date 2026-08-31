MKOCTFILE ?= mkoctfile
PKG_CONFIG ?= pkg-config
MPLAPACK_PC ?= mplapack_mpfr
CXX ?= c++

TARGET = __mplapack_core__.oct
SOURCE = octave_bridge.cc mp_value.cc mp_scalar_storage.cc mp_precision.cc
HEADERS = mp_value.h mp_scalar_storage.h mp_precision.h
STORAGE_TEST = .build-m02/mp_scalar_storage_test
MPLAPACK_VERSION := $(shell $(PKG_CONFIG) --modversion $(MPLAPACK_PC) 2>/dev/null)
MPLAPACK_CFLAGS ?= $(shell $(PKG_CONFIG) --cflags $(MPLAPACK_PC) 2>/dev/null)
MPLAPACK_LIBS ?= $(shell $(PKG_CONFIG) --libs $(MPLAPACK_PC) 2>/dev/null)
PACKAGE_CXXFLAGS = -std=c++17 -DMPLAPACK_PKG_VERSION=$(MPLAPACK_VERSION)
SANITIZER_FLAGS = -fsanitize=address,undefined -fno-omit-frame-pointer

.PHONY: all check-deps check-storage-sanitized clean
.DELETE_ON_ERROR:

all: $(TARGET)

$(TARGET): $(SOURCE) $(HEADERS) | check-deps
	@echo "Building $(TARGET) with MKOCTFILE=$(MKOCTFILE)"
	$(MKOCTFILE) $(PACKAGE_CXXFLAGS) $(MPLAPACK_CFLAGS) $(SOURCE) \
	  $(MPLAPACK_LIBS) -o $@

$(STORAGE_TEST): ../test/mp_scalar_storage_test.cc \
  mp_scalar_storage.cc mp_scalar_storage.h mp_precision.cc mp_precision.h \
  | check-deps
	mkdir -p $(dir $@)
	$(CXX) -std=c++17 -Wall -Wextra -Wpedantic $(SANITIZER_FLAGS) \
	  $(MPLAPACK_CFLAGS) -I. ../test/mp_scalar_storage_test.cc \
	  mp_scalar_storage.cc mp_precision.cc $(MPLAPACK_LIBS) -o $@

check-storage-sanitized: $(STORAGE_TEST)
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 \
	UBSAN_OPTIONS=halt_on_error=1 $(STORAGE_TEST)

check-deps:
	@$(MKOCTFILE) --help >/dev/null 2>&1 || { \
	  echo "FAIL: mkoctfile command not found: $(MKOCTFILE)" >&2; exit 1; }
	@command -v "$(PKG_CONFIG)" >/dev/null 2>&1 || { \
	  echo "FAIL: pkg-config command not found: $(PKG_CONFIG)" >&2; exit 1; }
	@$(PKG_CONFIG) --atleast-version=3.0.0 "$(MPLAPACK_PC)" || { \
	  echo "FAIL: $(MPLAPACK_PC) >= 3.0.0 is required" >&2; exit 1; }
	@case "$(MPLAPACK_VERSION)" in \
	  ''|*[!A-Za-z0-9._+-]*) \
	    echo "FAIL: unsafe $(MPLAPACK_PC) version: $(MPLAPACK_VERSION)" >&2; \
	    exit 1;; \
	esac
	@echo "PASS: $(MPLAPACK_PC) $(MPLAPACK_VERSION)"

clean:
	$(RM) $(TARGET) *.o *.lo
	$(RM) -r .libs .deps .build-m02
