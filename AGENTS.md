# AGENTS.md

This repository is `fleet-audit`, a maintenance tool for the loup-cmd series
of example applications written in the Loup programming language: it checks
every `loup-cmd-*` repository of `myronccai` against the series' definition
of done and writes a Markdown report. It is a `host.scripted` project: the
program is the `.lpscr` script in `bin/`, run from source with `loup run`,
which drives `gh`, `curl` and `git` through `io.proc` and imports modules
from `lib/`. Nothing is compiled.

## Skills

| Skill | Location | Use it when |
|-------|----------|-------------|
| `loup-programmer` | [skills/loup-programmer/SKILL.md](skills/loup-programmer/SKILL.md) | Writing, reviewing, debugging or explaining Loup code: `.lpscr`, `.loup`, `.lphc`, `.lpweb` or `.lpfree` source files, `.lppkg` manifests, `@mode(...)` directives, or the `loup` / `loup-bootstrap` commands. |

Read `skills/loup-programmer/SKILL.md` before writing or changing any Loup code
in this repository. It links to detailed references under
`skills/loup-programmer/references/` for syntax, types and ownership, execution
modes and projects, errors and diagnostics, the standard library, and common
mistakes. Load those only as needed.

## Code layout

```text
.
├── package.lppkg                # manifest: name, version, toolchain, [build] entry (bin/fleet-audit.lpscr), [test] pattern
├── Makefile                     # run, audit, check, test, e2e, ci, clean
├── bin/
│   └── fleet-audit.lpscr        # entry script (host.scripted, executable): options, collect, audit, report, exit status
├── lib/
│   ├── appinfo.loup             # APP_NAME, APP_VERSION, exit statuses
│   ├── args.loup                # struct Options, parse_args()
│   ├── usage.loup               # usage(), version_line()
│   ├── collect.lpscr            # host.scripted: collect_live() via gh/curl/git, collect_fixtures(), --record
│   ├── github.lpscr             # host.scripted: parse_repo_page(), repo_info(), parse_latest_run() (JSON is Any)
│   ├── facts.loup               # RepoInfo, RunInfo, TreeFacts, RepoFacts; toml_value(), ci_loup_version(), app_version()
│   ├── tree.loup                # read_tree(dir): the facts of a checked-out repository
│   ├── checks.loup              # Check, Audit, audit(): the definition of done
│   ├── roadmap.loup             # planned_repos(): the roadmap's section 6 table
│   ├── report.loup              # render_report(): Markdown
│   └── clock.loup               # utc_stamp()
├── tests/
│   ├── *_test.lpscr             # unit tests: func test_*(): void
│   ├── e2e.sh                   # end-to-end tests: loup run on the fixtures and on the live path
│   ├── fake-github.sh           # stands in for gh, curl and git (linked into PATH by e2e.sh)
│   ├── fixtures/fleet/          # an edited recording: meta.json, repos.json, runs/, trees/, ROADMAP.md
│   └── expected/                # report.md, report-roadmap.md, report-live.md
├── specs/fleet-audit/           # requirements.md, design.md, tasks.md
├── skills/loup-programmer/      # the Loup skill and its references
└── .github/workflows/ci.yml     # installs Loup and runs `make ci` (no network, no token)
```

## Check, run and test

Prerequisites: Loup 1.26.0 (`loup` and `loup-bootstrap` on `PATH`), `make`,
`bash`; `git` and `gh` or `curl` for a live audit.

| Task | Command | Notes |
|------|---------|-------|
| Audit the fleet | `make audit ROADMAP=../ROADMAP.md > report.md` | network; `GH_TOKEN` optional |
| Run from source | `make run ARGS="--fixtures tests/fixtures/fleet"` | `loup run bin/fleet-audit.lpscr -- ARGS` |
| Record a fixture | `loup run bin/fleet-audit.lpscr -- --record DIR > /dev/null` | then edit and trim it |
| Type-check | `make check` | `loup-bootstrap check FILE` for each `bin/*.lpscr` and its imports |
| Unit tests | `make test` | each `tests/*_test.lpscr` in turn |
| One test file | `make test TESTS=tests/checks_test.lpscr` | |
| End-to-end tests | `make e2e` | `tests/e2e.sh`: fixtures and fake gh/curl/git, no network |
| Everything CI runs | `make ci` | check, test, e2e, then `--version` |
| Clean | `make clean` | removes `.temp/` |

Run `make ci` before reporting a change as done. If the report format
changes, regenerate and review `tests/expected/`:
`loup run bin/fleet-audit.lpscr -- --fixtures tests/fixtures/fleet > tests/expected/report.md`
(and `report-roadmap.md` with `--roadmap tests/fixtures/fleet/ROADMAP.md`;
`report-live.md` comes from the fake live run in `tests/e2e.sh`, with the
date on line 3 replaced by `DATE`).

Toolchain facts this project depends on (Loup 1.26.0, Linux x86-64):

- A program that imports `data.toml` or `data.csv` gets that module's parser
  when it calls `system.json.parse`. Do not import them here.
- `gh` refuses every command without a token; the anonymous path is `curl`.
- Self-hosted `loup run`: `exec`/`io.proc.run` of a missing program returns
  status 127 (Stage0 throws), `IoError` cannot be caught, and backslash
  escapes inside `i"..."` are not processed. Check with `command -v` first,
  check files exist before reading, and keep escapes in plain strings.
- `loup run SCRIPT --long` takes `--long` as its own flag (the self-hosted
  driver drops it silently): script options go after `--`.
- A helper function named `box` is typed `any` by the checker (Loup has a
  `Box` keyword); pick another name.
- `loup-bootstrap test` with all files at once fails random tests with an
  empty `RuntimeError` on a busy machine; the Makefile runs one file at a time.

## Making a change

1. Update the spec in `specs/fleet-audit/` (see [specs/README.md](specs/README.md)).
2. Change the code: collecting in `lib/collect.lpscr` and
   `lib/github.lpscr`, everything else in the pure `lib/*.loup` modules.
3. Add or update unit tests and cases in `tests/e2e.sh`; extend
   `tests/fixtures/fleet` (and its README) when a new check needs data.
4. Run `make ci`.
5. Tick the finished tasks in `specs/fleet-audit/tasks.md`.

## Conventions

- `bin/fleet-audit.lpscr` is `@mode(host.scripted)` with a
  `#!/usr/bin/env -S loup run` line and the executable bit; keep it thin.
- `lib/*.loup` are `@mode(host.dual)`: pure, no `Any`. `lib/*.lpscr` are the
  scripted modules that need `Any` or run programs.
- Imports are relative: `from ..lib.x import (...)` in `bin/` and `tests/`,
  `from .x import (...)` inside `lib/`.
- Never print a token. The tool reads `GH_TOKEN`/`GITHUB_TOKEN` only to
  decide between `gh` and `curl`; `gh` reads the token itself.
- Keep `APP_VERSION` in `lib/appinfo.loup` equal to `version` in
  `package.lppkg` (the tool checks this in every other repository too).
- The skill documents toolchain 1.25.1; this project targets 1.26.0. When
  they disagree, trust the toolchain's behaviour.
