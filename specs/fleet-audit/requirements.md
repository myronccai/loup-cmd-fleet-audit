# Requirements: fleet-audit

## Introduction

`fleet-audit` checks every `loup-cmd-*` repository of the `myronccai`
account against the series' definition of done and writes a Markdown
report, including a status table in the format of §6 of the series roadmap.
It is a maintenance tool for the series and the third host-scripted project
of it: a `host.scripted` entry script in `bin/` that drives `gh`, `curl` and
`git` through `io.proc`, over modules in `lib/`.

## Requirements

### Requirement 1: Collecting

**User Story:** As the maintainer, I want the tool to gather everything
itself so that one command audits the whole series.

#### Acceptance Criteria

1. THE tool SHALL list the owner's repositories (`-o`, default `myronccai`)
   whose names start with the prefix (`-p`, default `loup-cmd-`), skipping
   template and archived repositories, in name order.
2. WHEN `GH_TOKEN` or `GITHUB_TOKEN` is set, or `gh auth status` succeeds,
   THE tool SHALL call the GitHub REST API with `gh api`; otherwise it SHALL
   call it unauthenticated with `curl`.
3. FOR each repository THE tool SHALL read the latest GitHub Actions run on
   the default branch, and SHALL make a shallow `git clone` to read its
   files, removing the clones afterwards.
4. WHEN a run or a clone cannot be obtained (for example the unauthenticated
   rate limit is exhausted), THE tool SHALL report that check as unknown
   with the reason, and carry on.
5. WHEN the repository list cannot be obtained, THE tool SHALL print
   `fleet-audit: REASON` on standard error and exit with status 2.
6. WHEN `--fixtures DIR` is given, THE tool SHALL read recorded data from DIR
   instead (`meta.json`, `repos.json`, `runs/NAME.json`, `trees/NAME/`) and
   use no network; WHEN `--record DIR` is given, THE tool SHALL write the
   data it used to DIR in that layout.

### Requirement 2: Checks

**User Story:** As the maintainer, I want each repository checked against
the definition of done so that I see what is missing.

#### Acceptance Criteria

1. THE tool SHALL check for each repository:
   - `description`: the repository has a description;
   - `topics`: it has the topics `loup` and `loup-example` and exactly one
     group topic (`loup-linux-command`, `loup-windows-command`,
     `loup-host-dual`, `loup-host-scripted`, `loup-host-native`,
     `loup-freestanding`);
   - `todos`: `REPOSITORY_TODOS.md` is gone;
   - `pin`: `loup` in `package.lppkg` equals `LOUP_VERSION` in
     `.github/workflows/ci.yml`;
   - `version`: `version` in `package.lppkg` equals the `APP_VERSION`
     constant in the sources;
   - `spec`: a directory under `specs/`, other than the template's
     `command-line-interface`, has `requirements.md`, `design.md` and
     `tasks.md`;
   - `readme`: `README.md` has a `Differences from ...` or a
     `What this example shows` section;
   - `ci`: the latest run on the default branch completed successfully;
   - `license`: a `LICENSE` file exists.
2. THE tool SHALL count a repository as done WHEN every check except
   `license` passes (the license is an open question of the roadmap, not
   part of its definition of done); `license` SHALL be reported as a
   warning.

### Requirement 3: Report

**User Story:** As the maintainer, I want a Markdown report so that I can
read it, publish it, or paste its table into the roadmap.

#### Acceptance Criteria

1. THE report SHALL start with a title, the owner and prefix, where the data
   came from and when, and a one-line summary
   (`**N repositories: D done, P with problems.**`).
2. THE report SHALL have a table with one row per repository: a link, the
   group, the version, the Loup pin, and a mark per check (`✓` pass, `✗`
   fail, `?` unknown), with the CI mark linking to the run.
3. THE report SHALL list each problem as `- REPO: check: detail`, and the
   warnings likewise.
4. WHEN `-r FILE` names the roadmap, THE report SHALL end with its §6 table
   (`| ID | Repo | Created | Spec | CI green | Done |` with `☑`/`☐`) for
   every repository the roadmap lists, in its order, and list repositories
   found that the roadmap does not list.
5. THE report SHALL go to standard output, or to `--output FILE`.

### Requirement 4: Command line

**User Story:** As a user, I want conventional options and statuses so that
the audit can run in scripts and CI.

#### Acceptance Criteria

1. THE tool SHALL accept `-o/--owner`, `-p/--prefix`, `-r/--roadmap`,
   `-f/--fixtures`, `--record`, `--output`, `-h/--help` and `-V/--version`,
   with values attached or separate (`--owner=x`, `-ox`, `-o x`).
2. WHEN an option is unknown or lacks its value, or `--fixtures` and
   `--record` are both given, THE tool SHALL print `fleet-audit: MESSAGE`
   and `Try 'fleet-audit --help' for more information.` and exit with
   status 2.
3. THE tool SHALL exit with status 0 WHEN every repository is done, 1 WHEN
   any is not, and 2 on a usage error or when nothing could be collected.
4. WHEN `--version` is given, THE tool SHALL print
   `fleet-audit (loup-cmd-fleet-audit) 0.1.0`.
