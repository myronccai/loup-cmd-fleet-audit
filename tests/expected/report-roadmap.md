# loup-cmd fleet audit

Repositories `loup-cmd-*` of [myronccai](https://github.com/myronccai), 2026-10-20 07:41 UTC.
Data: a recording in `tests/fixtures/fleet` of the GitHub REST API through `gh api` (authenticated) and shallow `git` clones.

**12 repositories: 3 done, 9 with problems.**

| Repository | Group | Version | Loup | description | topics | todos | pin | version | spec | readme | ci | license |
|---|---|---|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| [loup-cmd-cat](https://github.com/myronccai/loup-cmd-cat) | linux-command | 0.1.0 | 1.26.0 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | [✗](https://github.com/myronccai/loup-cmd-cat/actions/runs/39384150772) | ✗ |
| [loup-cmd-cut](https://github.com/myronccai/loup-cmd-cut) | linux-command | 0.1.0 | 1.26.0 | ✓ | ✓ | ✓ | ✗ | ✓ | ✓ | ✓ | [✓](https://github.com/myronccai/loup-cmd-cut/actions/runs/39384569579) | ✗ |
| [loup-cmd-echo](https://github.com/myronccai/loup-cmd-echo) | linux-command | 0.1.0 | 1.26.0 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | [✓](https://github.com/myronccai/loup-cmd-echo/actions/runs/39382714714) | ✗ |
| [loup-cmd-grep](https://github.com/myronccai/loup-cmd-grep) | linux-command | 0.1.0 | 1.26.0 | ✓ | ✓ | ✓ | ✓ | ✗ | ✓ | ✓ | [✓](https://github.com/myronccai/loup-cmd-grep/actions/runs/39386676114) | ✗ |
| [loup-cmd-httpd](https://github.com/myronccai/loup-cmd-httpd) | host-scripted | 0.1.0 | 1.26.0 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | [✓](https://github.com/myronccai/loup-cmd-httpd/actions/runs/39387777998) | ✗ |
| [loup-cmd-kvstore](https://github.com/myronccai/loup-cmd-kvstore) | host-native | 0.1.0 | 1.26.0 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | [?](https://github.com/myronccai/loup-cmd-kvstore/actions/runs/39388131214) | ✗ |
| [loup-cmd-logwatch](https://github.com/myronccai/loup-cmd-logwatch) | host-scripted | 0.1.0 | 1.26.0 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | [✓](https://github.com/myronccai/loup-cmd-logwatch/actions/runs/39385686525) | ✓ |
| [loup-cmd-ls](https://github.com/myronccai/loup-cmd-ls) | linux-command | 0.1.0 | 1.26.0 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ? | ✗ |
| [loup-cmd-md](https://github.com/myronccai/loup-cmd-md) | — | 0.1.0 | 1.26.0 | ✓ | ✗ | ✗ | ✓ | ✓ | ✗ | ✗ | [✓](https://github.com/myronccai/loup-cmd-md/actions/runs/39387487724) | ✗ |
| [loup-cmd-type](https://github.com/myronccai/loup-cmd-type) | windows-command | 0.1.0 | 1.26.0 | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | [✓](https://github.com/myronccai/loup-cmd-type/actions/runs/39385539342) | ✗ |
| [loup-cmd-which](https://github.com/myronccai/loup-cmd-which) | linux-command | ? | ? | ✓ | ✓ | ? | ? | ? | ? | ? | [✓](https://github.com/myronccai/loup-cmd-which/actions/runs/39387427759) | ? |
| [loup-cmd-xxd](https://github.com/myronccai/loup-cmd-xxd) | linux-command | 0.1.0 | 1.26.0 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ | ✗ |

✓ pass, ✗ fail, ? unknown. A repository is done when every check but `license` passes.

## Problems

- loup-cmd-cat: ci: latest run failure (run 39384150772)
- loup-cmd-cut: pin: package.lppkg loup 1.26.0, ci.yml LOUP_VERSION 1.25.1
- loup-cmd-grep: version: package.lppkg 0.1.0, APP_VERSION 0.2.0 (source/appinfo.loup)
- loup-cmd-kvstore: ci: unknown: run 39388131214 is in_progress
- loup-cmd-ls: ci: unknown: not recorded
- loup-cmd-md: topics: missing loup, loup-example
- loup-cmd-md: todos: REPOSITORY_TODOS.md is still there
- loup-cmd-md: spec: no complete spec under specs/
- loup-cmd-md: readme: no 'Differences from' or 'What this example shows' section
- loup-cmd-type: description: no description
- loup-cmd-which: todos, pin, version, spec, readme: unknown: not recorded
- loup-cmd-xxd: ci: no workflow runs

## Warnings

- license: no LICENSE file in loup-cmd-cat, loup-cmd-cut, loup-cmd-echo, loup-cmd-grep, loup-cmd-httpd, loup-cmd-kvstore, loup-cmd-ls, loup-cmd-md, loup-cmd-type, loup-cmd-which, loup-cmd-xxd

## Roadmap §6

| ID | Repo | Created | Spec | CI green | Done |
|---|---|---|---|---|---|
| L01 | loup-cmd-echo | ☑ | ☑ | ☑ | ☑ |
| L02 | loup-cmd-cat | ☑ | ☑ | ☐ | ☐ |
| L06 | loup-cmd-cut | ☑ | ☑ | ☑ | ☐ |
| L10 | loup-cmd-grep | ☑ | ☑ | ☑ | ☐ |
| L13 | loup-cmd-ls | ☑ | ☑ | ☐ | ☐ |
| L14 | loup-cmd-which | ☑ | ☐ | ☑ | ☐ |
| L19 | loup-cmd-xxd | ☑ | ☑ | ☐ | ☐ |
| L20 | loup-cmd-sha256sum | ☐ | ☐ | ☐ | ☐ |
| W01 | loup-cmd-type | ☑ | ☑ | ☑ | ☐ |
| W02 | loup-cmd-md | ☑ | ☐ | ☑ | ☐ |
| S1 | loup-cmd-logwatch | ☑ | ☑ | ☑ | ☑ |
| S3 | loup-cmd-fleet-audit | ☐ | ☐ | ☐ | ☐ |
| C2 | loup-cmd-kvstore | ☑ | ☑ | ☐ | ☐ |

Created 11 of 13. Not in the roadmap: loup-cmd-httpd.
