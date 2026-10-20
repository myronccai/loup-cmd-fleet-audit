# Tasks: fleet-audit

- [x] 1. Layout: `bin/fleet-audit.lpscr`, pure `lib/*.loup`, scripted `lib/*.lpscr` for JSON and I/O
  - _Requirements: all_
- [x] 2. Read manifest, workflow, sources, README and specs out of a checked-out tree
  - _Requirements: 2.1_
- [x] 3. List repositories and latest runs through `gh api` or anonymous `curl`; shallow clones
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_
- [x] 4. Record and replay (`--record`, `--fixtures`)
  - _Requirements: 1.6_
- [x] 5. The checks and the definition of done (license as a warning)
  - _Requirements: 2.1, 2.2_
- [x] 6. Markdown report: summary, table, problems, warnings; `--output`
  - _Requirements: 3.1, 3.2, 3.3, 3.5_
- [x] 7. Roadmap section 6 table
  - _Requirements: 3.4_
- [x] 8. Options, usage errors, exit statuses, version
  - _Requirements: 4.1, 4.2, 4.3, 4.4_
- [x] 9. Recorded fixture fleet, unit tests, end-to-end tests with a fake gh/curl/git
  - _Requirements: all_
