#!/usr/bin/env bash
# End-to-end tests: run bin/fleet-audit.lpscr with `loup run` and compare
# its report and exit status with the expected ones. No network: the
# recorded fleet in tests/fixtures/fleet is read directly (--fixtures), or
# served to the live code path by tests/fake-github.sh, linked into PATH as
# gh, curl and git.
#
# usage: tests/e2e.sh [LOUP]     (run from the repository root)

set -u
LOUP=${1:-loup}
SCRIPT=bin/fleet-audit.lpscr
FLEET=tests/fixtures/fleet
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
pass=0
fail=0

mkdir -p "$TMP/bin"
for name in gh curl git; do
    ln -s "$PWD/tests/fake-github.sh" "$TMP/bin/$name"
done

# The date of a live run, masked.
mask_date() {
    sed -E '3s/[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2} UTC/DATE/'
}

# run ARGS...: the script, ARGS after `--`, output in $TMP/out and $TMP/err.
run() {
    "$LOUP" run "$SCRIPT" -- "$@" < /dev/null > "$TMP/out" 2> "$TMP/err"
}

# live ARGS...: run with the fake gh, curl and git first on PATH.
live() {
    PATH="$TMP/bin:$PATH" FAKE_FLEET="$PWD/$FLEET" "$LOUP" run "$SCRIPT" -- "$@" < /dev/null > "$TMP/out" 2> "$TMP/err"
}

# same NAME EXPECTED ACTUAL
same() {
    if [ "$2" == "$3" ]; then
        pass=$((pass + 1))
    else
        fail=$((fail + 1))
        echo "FAIL: $1"
        diff <(printf '%s\n' "$2") <(printf '%s\n' "$3") | sed 's/^/    /' | head -20
        sed 's/^/    stderr: /' "$TMP/err" | head -5
    fi
}

HINT="Try 'fleet-audit --help' for more information."

# --- the recorded fleet -------------------------------------------------------

run --fixtures "$FLEET"
same "fixtures: status" 1 $?
same "fixtures: report" "$(cat tests/expected/report.md)" "$(cat "$TMP/out")"
same "fixtures: quiet" "" "$(cat "$TMP/err")"

run -f "$FLEET" -r "$FLEET/ROADMAP.md"
same "roadmap: report" "$(cat tests/expected/report-roadmap.md)" "$(cat "$TMP/out")"

run --fixtures="$FLEET" --output "$TMP/report.md"
same "output file: status" 1 $?
same "output file: stdout" "" "$(cat "$TMP/out")"
same "output file: report" "$(cat tests/expected/report.md)" "$(cat "$TMP/report.md")"

# --- the live code path, with fake gh, curl and git -----------------------------

GH_TOKEN=fake live
same "live gh: status" 1 $?
same "live gh: report" "$(cat tests/expected/report-live.md)" "$(mask_date < "$TMP/out")"
same "live gh: progress" "fleet-audit: [1/12] loup-cmd-cat" "$(head -1 "$TMP/err")"

# Without a token, and with gh not logged in, the API is read with curl.
env -u GH_TOKEN -u GITHUB_TOKEN FAKE_GH_AUTH=1 PATH="$TMP/bin:$PATH" FAKE_FLEET="$PWD/$FLEET" \
    "$LOUP" run "$SCRIPT" < /dev/null > "$TMP/out" 2> "$TMP/err"
same "live curl: data line" 'Data: the GitHub REST API through `curl` (unauthenticated) and shallow `git` clones.' "$(sed -n 4p "$TMP/out")"
same "live curl: same checks" "$(sed 1,4d tests/expected/report-live.md)" "$(sed 1,4d "$TMP/out")"

# A rate-limited run lookup makes `ci` unknown, and the audit carries on.
GH_TOKEN=fake FAKE_RATE_LIMIT=1 live
same "rate limit: status" 1 $?
same "rate limit: problem" "- loup-cmd-echo: ci: unknown: API rate limit exceeded for 192.0.2.1." "$(grep '^- loup-cmd-echo: ci:' "$TMP/out")"
same "rate limit: marks" 12 "$(grep -c '| ? | [✓✗?] |$' "$TMP/out")"

# A prefix that selects only finished repositories: status 0.
GH_TOKEN=fake live --prefix loup-cmd-h
same "prefix: status" 0 $?
same "prefix: summary" "**1 repository: 1 done, 0 with problems.**" "$(sed -n 6p "$TMP/out")"

# A recording of the live run audits the same as the run itself.
GH_TOKEN=fake live --record "$TMP/rec"
same "record: status" 1 $?
same "record: files" "meta.json repos.json runs trees" "$(ls "$TMP/rec" | tr '\n' ' ' | sed 's/ $//')"
run --fixtures "$TMP/rec"
same "record: replay" "$(sed 1,4d tests/expected/report-live.md)" "$(sed 1,4d "$TMP/out")"

# No repository list: status 2.
GH_TOKEN=fake live --owner nobody
same "no list: status" 2 $?
same "no list: message" "fleet-audit: cannot list the repositories of nobody: Not Found" "$(cat "$TMP/err")"
same "no list: no report" "" "$(cat "$TMP/out")"

# --- command line ----------------------------------------------------------------

run --version
same "version" "fleet-audit (loup-cmd-fleet-audit) 0.1.0" "$(cat "$TMP/out")"
run -h
same "help" "usage: fleet-audit [OPTION]..." "$(head -1 "$TMP/out")"

run --bogus
same "unknown option: status" 2 $?
same "unknown option: message" "fleet-audit: unrecognized option '--bogus'
$HINT" "$(cat "$TMP/err")"
run -f "$FLEET" --record "$TMP/x"
same "fixtures and record" "fleet-audit: --fixtures and --record cannot be used together
$HINT" "$(cat "$TMP/err")"
run -o
same "missing value" "fleet-audit: option requires an argument -- 'o'
$HINT" "$(cat "$TMP/err")"
run --fixtures tests/nope
same "missing fixtures: status" 2 $?
same "missing fixtures: message" "fleet-audit: tests/nope: not a directory" "$(cat "$TMP/err")"
run --fixtures "$FLEET" --roadmap nope.md
same "missing roadmap: status" 2 $?
same "missing roadmap: message" "fleet-audit: nope.md: no such file" "$(cat "$TMP/err")"

echo "e2e: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
