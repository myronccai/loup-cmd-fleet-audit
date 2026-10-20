# Recorded fleet

An edited recording of `fleet-audit --record` (2026-10-20), used by the unit
and end-to-end tests so that they need no network and no token.

- `meta.json`, `repos.json` (repository objects from `GET /users/myronccai/repos`,
  trimmed to the fields of interest), `runs/NAME.json` (`GET .../actions/runs`,
  trimmed to the latest run), `trees/NAME/` (the files the audit reads;
  READMEs cut to their headings and spec files to their first line).
- Edits that give every check something to find:

| Repository | Edit | Expect |
|---|---|---|
| loup-cmd-cat | latest run `failure` | `ci` fails |
| loup-cmd-cut | `LOUP_VERSION: "1.25.1"` in ci.yml | `pin` fails |
| loup-cmd-grep | `APP_VERSION` `0.2.0` | `version` fails |
| loup-cmd-kvstore | latest run `in_progress` | `ci` unknown |
| loup-cmd-logwatch | a `LICENSE` file | `license` passes |
| loup-cmd-ls | no `runs/` file | `ci` unknown (not recorded) |
| loup-cmd-md | none: recorded straight after creation | topics, todos, spec, readme fail |
| loup-cmd-type | description `null` | `description` fails |
| loup-cmd-which | no `trees/` directory | file checks unknown |
| loup-cmd-xxd | no runs | `ci` fails (no workflow runs) |
| loup-cmd-old, loup-cmd-template-demo, template-loup-cmd-app | archived, template, other prefix | skipped |

`ROADMAP.md` is a cut-down status section for `--roadmap`.
