#!/usr/bin/env bash
# Stands in for gh, curl and git in the end-to-end tests (linked into PATH
# under those names): it answers from the recording in $FAKE_FLEET instead
# of the network, so the live code path runs in CI without a token.
#
#   FAKE_GH_AUTH=1     `gh auth status` fails (no login), so curl is used
#   FAKE_RATE_LIMIT=1  every runs request gets the API's rate-limit error

set -u
name=$(basename "$0")

# api PATH: print the response for an API path; status 1 for an error.
api() {
    local path=${1#https://api.github.com/}
    case "$path" in
        users/myronccai/repos\?*page=1)
            cat "$FAKE_FLEET/repos.json" ;;
        users/myronccai/repos\?*)
            echo '[]' ;;
        repos/myronccai/*/actions/runs\?*)
            local repo=${path#repos/myronccai/}
            repo=${repo%%/*}
            if [ -n "${FAKE_RATE_LIMIT:-}" ]; then
                echo '{"message":"API rate limit exceeded for 192.0.2.1.","documentation_url":"https://docs.github.com/rest"}'
                return 1
            fi
            if [ -f "$FAKE_FLEET/runs/$repo.json" ]; then
                cat "$FAKE_FLEET/runs/$repo.json"
            else
                echo '{"message":"Not Found","status":"404"}'
                return 1
            fi ;;
        *)
            echo '{"message":"Not Found","status":"404"}'
            return 1 ;;
    esac
}

case "$name" in
    gh)
        if [ "${1:-}" = auth ]; then
            exit "${FAKE_GH_AUTH:-0}"
        fi
        shift                                 # api
        while [ "${1:-}" = -H ]; do shift 2; done
        api "$1"
        exit $? ;;
    curl)
        api "${!#}"
        exit 0 ;;                             # curl -sS exits 0 on HTTP errors
    git)
        # git [-c KEY=VALUE]... clone --quiet --depth 1 --branch B URL DEST
        dest=${!#}
        url=${*: -2:1}
        repo=$(basename "$url" .git)
        if [ -d "$FAKE_FLEET/trees/$repo" ]; then
            cp -r "$FAKE_FLEET/trees/$repo" "$dest"
            exit 0
        fi
        echo "fatal: repository '$url' not found" >&2
        exit 128 ;;
esac
echo "fake-github.sh: called as unknown program '$name'" >&2
exit 2
