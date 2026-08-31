MKOCTFILE ?= mkoctfile
PKG_CONFIG ?= pkg-config
MPLAPACK_PC ?= mplapack_mpfr

TARGET = __mplapack_core__.oct
SOURCE = octave_bridge.cc
MPLAPACK_VERSION := $(shell $(PKG_CONFIG) --modversion $(MPLAPACK_PC) 2>/dev/null)
MPLAPACK_CFLAGS ?= $(shell $(PKG_CONFIG) --cflags $(MPLAPACK_PC) 2>/dev/null)
MPLAPACK_LIBS ?= $(shell $(PKG_CONFIG) --libs $(MPLAPACK_PC) 2>/dev/null)
M01_CXXFLAGS = -std=c++17 -DMPLAPACK_PKG_VERSION=$(MPLAPACK_VERSION)

.PHONY: all check-deps clean
.DELETE_ON_ERROR:

all: $(TARGET)

$(TARGET): $(SOURCE) | check-deps
	@echo "Building $(TARGET) with MKOCTFILE=$(MKOCTFILE)"
	$(MKOCTFILE) $(M01_CXXFLAGS) $(MPLAPACK_CFLAGS) $(SOURCE) \
	  $(MPLAPACK_LIBS) -o $@

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
	$(RM) -r .libs .deps
