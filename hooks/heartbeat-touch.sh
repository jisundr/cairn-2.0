#!/usr/bin/env bash
set -uo pipefail
if [ "${1:-}" = --selftest ]; then
p=0;f=0;t(){ "$@"&&p=$((p+1))||f=$((f+1)); }
t bash -n "$0"
h=$(mktemp -d);d="$h/.claude/cairn/active";mkdir -p "$d"
tf="$d/a.json";echo '{}' >"$tf";touch -t 202001010000 "$tf"
old=$(date -r "$tf" +%s)
HOME="$h" "$0" <<<'{"session_id":"a"}' >/dev/null 2>&1
t [ "$(date -r "$tf" +%s)" -gt "$old" ]
o=$(HOME="$h" "$0" <<<'{"session_id":"missing"}' 2>&1);rc=$?
t [ -z "$o" -a "$rc" = 0 ]
rm -rf "$h"
echo "heartbeat-touch.sh selftest: $p passed, $f failed"
exit $((f>0))
fi
command -v jq >/dev/null 2>&1 || exit 0
session_id="$(jq -r '.session_id // empty' 2>/dev/null)"
[ -n "$session_id" ] || exit 0
[ -n "${HOME:-}" ] || exit 0
file="$HOME/.claude/cairn/active/$session_id.json"
[ -f "$file" ] && touch "$file" 2>/dev/null
exit 0
