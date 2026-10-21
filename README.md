# loup-cmd-fleet-audit

A [Loup](https://code-craft.ai/references/loup) script that audits every
`loup-cmd-*` repository of [myronccai](https://github.com/myronccai) against
the series' definition of done, through `gh`, `curl` and `git`, and writes a
Markdown report, including the status table of the series roadmap.

Part of the **loup-cmd** series of example applications: classic Linux and
Windows commands, and projects for each Loup execution mode, each in its own
repository under [myronccai](https://github.com/myronccai?tab=repositories&q=loup-cmd).
This one is a `host.scripted` project: a thin `.lpscr` entry script in `bin/`
that drives other programs through `io.proc`, over modules in `lib/`.

## Requirements

- [Loup Lite](https://github.com/code-craft-ai-company/loup-releases) 1.26.0
  or later (`loup` and `loup-bootstrap` on `PATH`); see [Installing Loup Lite](#installing-loup-lite).
- `git`, and `gh` or `curl`, for a live audit. `make` and `bash` for the
  tests, which need no network and no token.

## Installing Loup Lite

This example is built and tested with **Loup Lite**, the free public build of
the Loup toolchain from [Code Craft AI](https://code-craft.ai), meant for
education and training. Code Craft AI publishes the official builds,
installers and signed checksums at
**<https://github.com/code-craft-ai-company/loup-releases>**, for Linux
(x86-64, arm64), macOS (Apple silicon, Intel) and Windows (x86-64).

Linux and macOS:

```sh
curl -fsSL https://github.com/code-craft-ai-company/loup-releases/releases/latest/download/loup-install.sh | sh
```

Windows (PowerShell):

```powershell
irm https://github.com/code-craft-ai-company/loup-releases/releases/latest/download/loup-install.ps1 | iex
```

The installer picks the archive for your machine, checks it against the
release's `SHA256SUMS`, unpacks it into `~/.loup`
(`%LOCALAPPDATA%\Programs\Loup` on Windows) and puts its `bin` directory on
your `PATH`; it needs no administrator rights. You get `loup`, the Stage0
compiler `loup-bootstrap` and the Wasm runtime `loup-launcher`. Open a new
shell and check:

```sh
loup --version             # loup 1.26.0 or later
```

CI installs the exact version it tests with, 1.26.0. To do the same:

```sh
curl -fsSL https://github.com/code-craft-ai-company/loup-releases/releases/download/v1.26.0/loup-install.sh | sh -s -- --version 1.26.0
```

To install by hand, download your platform's archive from the
[releases page](https://github.com/code-craft-ai-company/loup-releases/releases),
check it against `SHA256SUMS`, unpack it anywhere and add its `bin` directory to
`PATH`. The [loup-releases README](https://github.com/code-craft-ai-company/loup-releases#verify-a-download)
explains how to verify the Sigstore signature on `SHA256SUMS`.

Loup Lite leaves out Loup's cryptography library and the full set of Loup
packages; this example needs neither. Commercial use of Loup needs a
license: <https://code-craft.ai/loup/license>.

## Usage

```sh
./bin/fleet-audit.lpscr > report.md                                 # audit the fleet
loup run bin/fleet-audit.lpscr -- --roadmap ROADMAP.md --output report.md
GH_TOKEN=... ./bin/fleet-audit.lpscr                                 # through gh api
make audit ROADMAP=../ROADMAP.md > report.md
make ci                                                              # check, unit tests, end-to-end tests
```

**Token or not.** With `GH_TOKEN` or `GITHUB_TOKEN` set (or `gh` logged in),
the REST API is read with `gh api`. Without one it is read anonymously with
`curl`, because `gh` refuses to run without a token even for public data.
Anonymous access allows 60 requests an hour: the audit makes one for the
repository list and one per repository, so a larger fleet can run out; the
CI checks it could not read show as `?` with the API's message. Files are
always read from shallow `git clone`s of the public repositories.

What it checks, for each repository:

| Check | Passes when |
|---|---|
| `description` | the repository has a description |
| `topics` | it has `loup`, `loup-example` and exactly one group topic (`loup-linux-command`, ...) |
| `todos` | `REPOSITORY_TODOS.md` is gone |
| `pin` | `loup` in `package.lppkg` equals `LOUP_VERSION` in `.github/workflows/ci.yml` |
| `version` | `version` in `package.lppkg` equals the `APP_VERSION` constant in the sources |
| `spec` | `specs/<name>/` has `requirements.md`, `design.md` and `tasks.md` |
| `readme` | `README.md` has a "Differences from ..." or "What this example shows" section |
| `ci` | the latest GitHub Actions run on the default branch succeeded (a run still going is `?`) |
| `license` | a `LICENSE` file exists (a warning only: a repository can be done without one) |

A repository is **done** when every check but `license` passes. With
`--roadmap`, the report ends with section 6 of the roadmap (ID, Repo,
Created, Spec, CI green, Done) filled in, ready to paste.

An audit of the recorded fleet in [`tests/fixtures/fleet`](tests/fixtures/fleet)
(real data, edited so that every check has something to find; its
[README](tests/fixtures/fleet/README.md) lists the edits), shortened:

```text
$ loup run bin/fleet-audit.lpscr -- -f tests/fixtures/fleet -r tests/fixtures/fleet/ROADMAP.md > report.md; echo "status $?"
status 1
$ cat report.md
# loup-cmd fleet audit

Repositories `loup-cmd-*` of [myronccai](https://github.com/myronccai), 2026-10-20 07:41 UTC.
Data: a recording in `tests/fixtures/fleet` of the GitHub REST API through `gh api` (authenticated) and shallow `git` clones.

**12 repositories: 3 done, 9 with problems.**

| Repository | Group | Version | Loup | description | topics | todos | pin | version | spec | readme | ci | license |
|---|---|---|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| [loup-cmd-cat](https://github.com/myronccai/loup-cmd-cat) | linux-command | 0.1.0 | 1.26.0 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | [✗](https://github.com/myronccai/loup-cmd-cat/actions/runs/39384150772) | ✗ |
| [loup-cmd-cut](https://github.com/myronccai/loup-cmd-cut) | linux-command | 0.1.0 | 1.26.0 | ✓ | ✓ | ✓ | ✗ | ✓ | ✓ | ✓ | [✓](https://github.com/myronccai/loup-cmd-cut/actions/runs/39384569579) | ✗ |
| [loup-cmd-echo](https://github.com/myronccai/loup-cmd-echo) | linux-command | 0.1.0 | 1.26.0 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | [✓](https://github.com/myronccai/loup-cmd-echo/actions/runs/39382714714) | ✗ |
...

## Problems

- loup-cmd-cat: ci: latest run failure (run 39384150772)
- loup-cmd-cut: pin: package.lppkg loup 1.26.0, ci.yml LOUP_VERSION 1.25.1
- loup-cmd-grep: version: package.lppkg 0.1.0, APP_VERSION 0.2.0 (source/appinfo.loup)
- loup-cmd-kvstore: ci: unknown: run 39388131214 is in_progress
...
- loup-cmd-which: todos, pin, version, spec, readme: unknown: not recorded
- loup-cmd-xxd: ci: no workflow runs

## Warnings

- license: no LICENSE file in loup-cmd-cat, loup-cmd-cut, ...

## Roadmap §6

| ID | Repo | Created | Spec | CI green | Done |
|---|---|---|---|---|---|
| L01 | loup-cmd-echo | ☑ | ☑ | ☑ | ☑ |
| L02 | loup-cmd-cat | ☑ | ☑ | ☐ | ☐ |
...
| S3 | loup-cmd-fleet-audit | ☐ | ☐ | ☐ | ☐ |
| C2 | loup-cmd-kvstore | ☑ | ☑ | ☐ | ☐ |

Created 11 of 13. Not in the roadmap: loup-cmd-httpd.
```

The complete reports are in [`tests/expected/`](tests/expected/). A live
audit prints its progress (`fleet-audit: [3/19] loup-cmd-cut`) on standard
error and takes about a second per repository.

### Options

| Option | Meaning |
|---|---|
| `-o`, `--owner OWNER` | GitHub account (default `myronccai`) |
| `-p`, `--prefix PREFIX` | repository name prefix (default `loup-cmd-`) |
| `-r`, `--roadmap FILE` | add the roadmap's section 6 table |
| `-f`, `--fixtures DIR` | audit a recording instead of GitHub (no network) |
| `--record DIR` | save the data of a live audit to DIR, for `--fixtures` |
| `--output FILE` | write the report to FILE |
| `-h`, `--help` / `-V`, `--version` | help text / `fleet-audit (loup-cmd-fleet-audit) 0.1.0` |

Under `loup run`, long options go after `--` (`loup run` takes words that
start with `--` as its own flags, and the self-hosted driver drops unknown
ones silently); short options pass through, also in the shebang form.

Exit status: `0` every repository is done, `1` some are not, `2` a usage
error or nothing could be collected (for example no network for the
repository list).

## What this example shows

- **A script that drives other programs.** `lib/collect.lpscr` runs `gh
  api`, `curl`, `git clone`, `mktemp`, `cp` and `rm` with `io.proc.run`,
  reads their exit codes and output (`ProcResult.stdout.decode()`), and
  turns every failure into an "unknown" fact instead of stopping.
- **Choosing a mode per module.** The modules that handle parsed JSON
  (`Any`) and do the I/O are `host.scripted` (`lib/github.lpscr`,
  `lib/collect.lpscr`); the facts, checks, roadmap parser and report are
  pure `host.dual` modules (`lib/*.loup`), imported with relative paths
  (`from ..lib.checks import (audit);`).
- **Interpreter features where they fit.** The repository list is paged
  by a generator (`gen func repo_pages`, fed a fetch function, so the
  tests can hand it canned pages); the clones live in a `TempDir` that is a
  `Closeable`, removed when its `with` block ends, and each clone is deleted
  in a `finally` once read. The checks use the list methods `filter` and
  `all`, the tree reader a `set` and a labelled `continue`, the JSON
  getters `as?`. Nothing is compiled, so these interpreter-only features
  are fine here.
- **Testing without the network.** `--record` saves exactly what an audit
  read; `--fixtures` replays it. The unit tests read a recording, and the
  end-to-end tests also run the live code path with
  [`tests/fake-github.sh`](tests/fake-github.sh) on `PATH` as `gh`, `curl`
  and `git`, including the anonymous path and a rate-limited API.
- **Small parsers instead of libraries.** The manifest's TOML keys, the
  workflow's `LOUP_VERSION` and the `APP_VERSION` constant are read with
  `system.regex` line by line, the roadmap's Markdown table with `split`.
  (`data.toml` is not used: a program that imports it gets the TOML parser
  when it calls `system.json.parse`.)

## Limitations

- Repositories are listed from the owner's public repositories; private ones
  need a token with access, and only `gh` sends one.
- The `ci` check reads the latest run on the default branch, whatever its
  workflow; a repository with several workflows is judged by the newest run.
- `version` takes the first `APP_VERSION` constant found in the sources
  (outside `skills/` and `tests/`).

## Layout

```text
bin/fleet-audit.lpscr       # the program (host.scripted entry script)
lib/appinfo.loup            # name, version, exit statuses
lib/args.loup               # option parsing
lib/usage.loup              # --help and --version text
lib/collect.lpscr           # gh/curl/git through io.proc; recordings (host.scripted)
lib/github.lpscr            # reading the API's JSON (host.scripted: Any)
lib/facts.loup              # RepoInfo, RunInfo, TreeFacts; reading manifest, workflow, sources
lib/tree.loup               # the facts of a checked-out repository
lib/checks.loup             # the definition of done
lib/roadmap.loup            # the roadmap's status table
lib/report.loup             # the Markdown report
lib/clock.loup              # UTC time stamps
tests/*_test.lpscr          # unit tests (make test)
tests/e2e.sh                # end-to-end tests with loup run (make e2e)
tests/fake-github.sh        # gh, curl and git for the end-to-end tests
tests/fixtures/fleet/       # a recorded, edited fleet
tests/expected/             # its reports
specs/fleet-audit/          # requirements, design, tasks
```

[AGENTS.md](AGENTS.md) has every check and test command and the conventions
for changing the code.

## License

[MIT](LICENSE), copyright 2026 Code Craft AI LLC. The Loup skill in
[`skills/loup-programmer/`](skills/loup-programmer/) is copied from the Loup
project and is not covered by this license; it keeps the Loup project's terms.
