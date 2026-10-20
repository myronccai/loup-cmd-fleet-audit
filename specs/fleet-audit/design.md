# Design: fleet-audit

## Overview

`bin/fleet-audit.lpscr` is a `host.scripted` script. Its top-level statements
parse `args()` into `Options`, read the roadmap if one is named, collect the
facts (live or from a recording), run the checks over each repository,
render the report, write it, and exit with 0, 1 or 2.

```text
args() ─ parse_args ─► Options
collect_live / collect_fixtures ─► Collected { facts: list[RepoFacts] }
RepoFacts ─ audit ─► Audit { checks, done }
Audits (+ planned_repos(ROADMAP)) ─ render_report ─► Markdown
```

## Modules

| Module | Mode | Contents |
|---|---|---|
| `bin/fleet-audit.lpscr` | scripted | top level |
| `lib/args.loup`, `lib/usage.loup`, `lib/appinfo.loup` | dual | options, help, identity |
| `lib/collect.lpscr` | scripted | `choose_transport`, `api_get`, `collect_live`, `collect_fixtures`, recording |
| `lib/github.lpscr` | scripted | `parse_repo_page`, `wanted`, `repo_info`, `parse_latest_run` |
| `lib/facts.loup` | dual | the fact structs; `toml_value`, `ci_loup_version`, `app_version`, `readme_section` |
| `lib/tree.loup` | dual | `read_tree(dir)` |
| `lib/checks.loup` | dual | `audit`, the individual checks, `check_named` |
| `lib/roadmap.loup` | dual | `planned_repos` |
| `lib/report.loup` | dual | `render_report`, `summary_line`, `checks_table`, `roadmap_table` |
| `lib/clock.loup` | dual | `utc_stamp` |

The modules that hold parsed JSON (`Any`) or run programs are scripted; the
rest is pure `host.dual` code, so most of the logic is tested with plain
values.

### Collecting

- Transport: `gh` when `GH_TOKEN`/`GITHUB_TOKEN` is set or `gh auth status`
  succeeds, else `curl` (anonymous). `gh` refuses to run without a token, so
  the anonymous path cannot use it. `command -v` is checked first: under the
  self-hosted `loup run`, running a missing program does not throw.
- `api_get(path)`: `gh api -H Accept... PATH` or `curl -sS -H Accept...
  https://api.github.com/PATH`. Error responses are JSON too, so any output
  goes to the parsers, which turn `{"message": ...}` into an error string.
- Repositories: `users/OWNER/repos?per_page=100&page=N` until a page is
  short; `wanted` keeps names with the prefix that are neither templates nor
  archived; sorted by name.
- Per repository: `repos/OWNER/NAME/actions/runs?branch=B&per_page=1`
  (found / none / unknown), then `git -c credential.helper= clone --depth 1
  --branch B` into a `mktemp -d` directory with `GIT_TERMINAL_PROMPT=0`,
  `read_tree`, and `rm -rf`. A failure becomes an unknown fact with its
  first line of error output.
- Recording (`--record DIR`): `meta.json`, the selected repository objects
  as `repos.json`, each runs response as `runs/NAME.json`, the files
  `read_tree` read (its `files` list) under `trees/NAME/`, and a failed
  clone's reason as `trees/NAME.unavailable`. `collect_fixtures` reads the
  same layout back, so a recording replays to the same report.

### Reading files

`read_tree` reads `package.lppkg` (top-level `loup` and `version` by a
line-wise regex; `data.toml` is avoided because it shadows
`system.json.parse`), `.github/workflows/ci.yml` (`LOUP_VERSION:`), the first
source file outside `skills/`, `tests/` and `.git/` with an `APP_VERSION`
constant (texts are pre-filtered with `contains` before the regex, which is
slow on whole files), the presence of `REPOSITORY_TODOS.md` and a license
file, the complete spec directories other than the template's
`command-line-interface`, and the README's explaining section.

### Checks and report

`audit` produces nine `Check`s (`pass`, `fail` or `unknown` with a detail).
Unknown file facts make the file checks unknown; a run that is queued or in
progress makes `ci` unknown. `done` is every check but `license` passing.

The report has the header, the summary line, the table (CI mark linked to
the run), the problems (unknown checks of one repository that share a
reason are merged into one line), the warnings grouped per check, and with
`--roadmap` the section 6 table in the roadmap's own format with a
"Created N of M" line and the repositories the roadmap does not list.

## What this example shows

- A script that runs other programs through `io.proc` and degrades
  gracefully when they fail.
- Choosing `host.scripted` or `host.dual` per module.
- Record and replay, and a fake `gh`/`curl`/`git` on `PATH`, to test a
  network tool offline.

## Error handling

- Usage errors, a missing roadmap or fixtures directory, or a repository
  list that cannot be read: one line on standard error, status 2, no report.
- Everything per repository: an unknown check with the reason; the audit
  carries on.

## Testing

- `tests/facts_test.lpscr`, `tests/tree_test.lpscr`: extraction from texts
  and from the recorded trees.
- `tests/github_test.lpscr`: repository pages (selection, nulls, errors),
  latest runs (found, running, none, rate limited).
- `tests/checks_test.lpscr`: every check and the definition of done.
- `tests/roadmap_test.lpscr`, `tests/report_test.lpscr` (exact Markdown),
  `tests/clock_test.lpscr`, `tests/args_test.lpscr`,
  `tests/collect_test.lpscr` (`collect_fixtures`).
- `tests/e2e.sh`: the recorded fleet with and without the roadmap and with
  `--output`; the live path with the fake `gh`, `curl` and `git` (gh with a
  token, curl without, a rate-limited API, a prefix that gives status 0,
  `--record` then replay, an owner that cannot be listed); command-line
  errors.
