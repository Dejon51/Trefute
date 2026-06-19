# ============================================================================
#  trefute — Makefile
# ----------------------------------------------------------------------------
#  Usage:
#    make            # release build (default)
#    make release    # optimized build  : -O3 -flto -std=c17
#    make debug      # debug build      : -O0 -g3 -fsanitize=address,undefined
#    make run        # build + run the release binary
#    make ARGS="..." run     # run with arguments
#    make clean      # remove build artifacts for the current profile
#    make distclean  # remove the entire build directory
#    make install    # install to $(PREFIX)/bin  (default /usr/local)
#    make compile_commands.json   # generate clangd/IDE database (needs bear)
#    make format     # run clang-format over all sources (needs clang-format)
#    make help       # list targets
# ============================================================================

# ---- Project ---------------------------------------------------------------
NAME      := trefute
SRC_DIR   := src
BUILD_DIR := _build

# ---- Toolchain -------------------------------------------------------------
CC        ?= cc
PREFIX    ?= /usr/local

# ---- Sources / objects -----------------------------------------------------
SRCS      := $(shell find $(SRC_DIR) -name '*.c')

# ---- Profile selection -----------------------------------------------------
# Default profile is "release". `make debug` overrides it.
PROFILE   ?= release

# Common warning flags applied to every profile.
WARNINGS  := -Wall -Wextra -Wshadow -Wconversion -Wpedantic

# Per-profile flags.
ifeq ($(PROFILE),release)
  CFLAGS_PROFILE  := -O3 -flto -DNDEBUG -march=native
  LDFLAGS_PROFILE := -flto
else ifeq ($(PROFILE),debug)
  CFLAGS_PROFILE  := -O0 -g3 -fsanitize=address,undefined -fno-omit-frame-pointer
  LDFLAGS_PROFILE := -fsanitize=address,undefined
else
  $(error Unknown PROFILE '$(PROFILE)' (expected 'release' or 'debug'))
endif

# Final flag sets. CFLAGS/LDFLAGS from the environment are appended last so
# the user can override anything on the command line.
ALL_CFLAGS  := -std=c17 -MMD -MP $(WARNINGS) $(CFLAGS_PROFILE) $(CPPFLAGS) $(CFLAGS)
ALL_LDFLAGS := $(LDFLAGS_PROFILE) $(LDFLAGS)

# ---- Derived paths ---------------------------------------------------------
OBJ_DIR := $(BUILD_DIR)/$(PROFILE)/obj
BIN_DIR := $(BUILD_DIR)/$(PROFILE)/bin
TARGET  := $(BIN_DIR)/$(NAME)
OBJS    := $(SRCS:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)
DEPS    := $(OBJS:.o=.d)

ARGS ?=

# ---- Phony targets ---------------------------------------------------------
.PHONY: all release debug build run clean distclean install uninstall format \
        compile_commands.json help
.DEFAULT_GOAL := release

all: release

# Build via recursive make so a single invocation always uses one profile's
# flags consistently. The sub-make targets the `build` phony so the child
# re-derives $(TARGET) from its own PROFILE (expanding $(TARGET) here would
# bake in the parent's default profile).
release:
	@$(MAKE) --no-print-directory PROFILE=release build

debug:
	@$(MAKE) --no-print-directory PROFILE=debug build

build: $(TARGET)

# ---- Link ------------------------------------------------------------------
$(TARGET): $(OBJS) | $(BIN_DIR)
	@echo "  LD      $@"
	@$(CC) $(OBJS) $(ALL_LDFLAGS) -o $@
	@echo "  Built $@ [$(PROFILE)]"

# ---- Compile ---------------------------------------------------------------
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	@mkdir -p $(dir $@)
	@echo "  CC      $<"
	@$(CC) $(ALL_CFLAGS) -c $< -o $@

# ---- Directories -----------------------------------------------------------
$(OBJ_DIR) $(BIN_DIR):
	@mkdir -p $@

# ---- Run -------------------------------------------------------------------
run: $(TARGET)
	@echo "  RUN     $(TARGET) $(ARGS)"
	@$(TARGET) $(ARGS)

# ---- Install / uninstall ---------------------------------------------------
install: release
	@echo "  INSTALL $(DESTDIR)$(PREFIX)/bin/$(NAME)"
	@install -d $(DESTDIR)$(PREFIX)/bin
	@install -m 0755 $(BUILD_DIR)/release/bin/$(NAME) $(DESTDIR)$(PREFIX)/bin/$(NAME)

uninstall:
	@echo "  RM      $(DESTDIR)$(PREFIX)/bin/$(NAME)"
	@rm -f $(DESTDIR)$(PREFIX)/bin/$(NAME)

# ---- Tooling ---------------------------------------------------------------
# Generate compile_commands.json for clangd / IDEs (requires `bear`).
compile_commands.json:
	@command -v bear >/dev/null 2>&1 || { echo "bear not found (install it to generate compile_commands.json)"; exit 1; }
	@$(MAKE) --no-print-directory distclean
	@bear -- $(MAKE) --no-print-directory release

format:
	@command -v clang-format >/dev/null 2>&1 || { echo "clang-format not found"; exit 1; }
	@echo "  FORMAT  $(words $(SRCS)) file(s)"
	@clang-format -i $(SRCS)

# ---- Clean -----------------------------------------------------------------
clean:
	@echo "  CLEAN   $(BUILD_DIR)/$(PROFILE)"
	@rm -rf $(BUILD_DIR)/$(PROFILE)

distclean:
	@echo "  CLEAN   $(BUILD_DIR)"
	@rm -rf $(BUILD_DIR)

# ---- Help ------------------------------------------------------------------
help:
	@echo "trefute — make targets:"
	@echo "  release      Optimized build (-O3 -flto -std=c17)  [default]"
	@echo "  debug        Debug build (-O0 -g3 + ASan/UBSan)"
	@echo "  run          Build and run (use ARGS=\"...\" to pass arguments)"
	@echo "  install      Install to \$$PREFIX/bin (PREFIX=$(PREFIX))"
	@echo "  uninstall    Remove the installed binary"
	@echo "  format       Format sources with clang-format"
	@echo "  clean        Remove the current profile's build dir"
	@echo "  distclean    Remove the whole build dir"
	@echo "  compile_commands.json  Generate IDE/clangd database (needs bear)"

# ---- Auto-generated header dependencies ------------------------------------
-include $(DEPS)
