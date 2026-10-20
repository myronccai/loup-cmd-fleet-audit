# Check, test and run commands for this host-scripted Loup project.
#
# The program is a script (bin/fleet-audit.lpscr) that `loup run` executes
# from source; a script entry cannot be compiled (E-BUILD-COMPILED), so
# there is no build target. On Linux x86-64 `loup` is the self-hosted driver
# and `loup-bootstrap` is Stage0; `check` and `test` need Stage0 there. On
# macOS, Windows and Linux arm64 both names run Stage0.

APP            ?= fleet-audit
LOUP           ?= loup
LOUP_BOOTSTRAP ?= loup-bootstrap
SCRIPTS        := $(wildcard bin/*.lpscr)
TESTS          ?= $(wildcard tests/*_test.lpscr)
ROADMAP        ?=
ARGS           ?=
TEST_ARGS      ?=

.PHONY: all run audit check test e2e ci clean

all: ci

# Run from source, e.g. `make run ARGS="--fixtures tests/fixtures/fleet"`.
# The arguments follow `--` so that long options reach the script.
run:
	$(LOUP) run bin/$(APP).lpscr -- $(ARGS)

# Audit the real fleet (network; GH_TOKEN optional), e.g.
# `make audit ROADMAP=../ROADMAP.md > report.md`.
audit:
	$(LOUP) run bin/$(APP).lpscr -- $(if $(ROADMAP),--roadmap $(ROADMAP)) $(ARGS)

# Type-check each entry script and every lib/ module it imports.
check:
	@for script in $(SCRIPTS); do \
		echo "check $$script"; \
		$(LOUP_BOOTSTRAP) check --no-color $$script || exit 1; \
	done

# Unit tests (tests/*_test.lpscr), one file at a time and one test at a
# time (--no-parallel): in parallel, the 1.26.0 runner fails random tests
# with an empty RuntimeError on a busy machine (seen on CI in
# facts_test.lpscr, whose tests share module-level Regex values). They read
# tests/fixtures/fleet; no network.
# Narrow the run: `make test TESTS=tests/checks_test.lpscr TEST_ARGS="--filter ci"`.
test:
	@status=0; for t in $(TESTS); do \
		$(LOUP_BOOTSTRAP) test --no-color --no-parallel --file $$t $(TEST_ARGS) || status=1; \
	done; exit $$status

# End-to-end tests: run the script with `loup run` on the recorded fleet,
# and on its live code path with tests/fake-github.sh standing in for gh,
# curl and git. No network.
e2e:
	bash tests/e2e.sh $(LOUP)

# Everything CI runs, ending with a smoke test of the entry script.
ci: check test e2e
	$(LOUP) run bin/$(APP).lpscr -- --version

clean:
	rm -rf .temp
