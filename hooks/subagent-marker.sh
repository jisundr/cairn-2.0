#!/usr/bin/env bash
set -uo pipefail
MAX_AGE=14400
if [ "${1:-}" = --selftest ]; then
p=0;f=0;t(){ "$@"&&p=$((p+1))||f=$((f+1)); }
t bash -n "$0"
h=$(mktemp -d);d="$h/.claude/cairn/active";mkdir -p "$d"
echo '{"project":"/p","task":"docs/tasks/x"}' >"$d/s1.json"
run(){ HOME="$h" "$0" "$1" <<<"$2" 2>&1; }
run start '{"session_id":"s1","agent_id":"a1"}' >/dev/null
t [ "$(jq -r .task "$d/s1--a1.active")" = docs/tasks/x ]
o=$(run start '{"session_id":"nop","agent_id":"a1"}');rc=$?
t [ -z "$o" -a "$rc" = 0 -a ! -e "$d/nop--a1.active" ]
o=$(run stop '{"session_id":"s1","agent_id":"a1"}');rc=$?
t [ -z "$o" -a "$rc" = 0 -a ! -e "$d/s1--a1.active" ]
o=$(run stop '{"session_id":"s1","agent_id":"none"}');rc=$?
t [ -z "$o" -a "$rc" = 0 ]
echo '{}' >"$d/old--a.active";touch -t 202001010000 "$d/old--a.active"
echo '{}' >"$d/other--b.active"
run sweep '{"session_id":"s1"}' >/dev/null
t [ ! -e "$d/old--a.active" -a -e "$d/other--b.active" ]
rm -rf "$h"
echo "subagent-marker.sh selftest: $p passed, $f failed"
exit $((f>0))
fi
command -v jq >/dev/null 2>&1 || exit 0
[ -n "${HOME:-}" ] || exit 0
dir="$HOME/.claude/cairn/active"
payload="$(cat)"
sid="$(jq -r '.session_id // empty' <<<"$payload" 2>/dev/null)"
aid="$(jq -r '.agent_id // empty' <<<"$payload" 2>/dev/null)"
case "${1:-}" in
  start)
    [ -n "$sid" ] && [ -n "$aid" ] || exit 0
    [ -f "$dir/$sid.json" ] || exit 0
    body="$(jq -c 'select((.project|type)=="string" and (.task|type)=="string")|{project,task}' "$dir/$sid.json" 2>/dev/null)"
    [ -n "$body" ] || exit 0
    tmp="$(mktemp "$dir/.marker.XXXXXX" 2>/dev/null)" || exit 0
    printf '%s\n' "$body" >"$tmp" && mv "$tmp" "$dir/$sid--$aid.active" 2>/dev/null || rm -f "$tmp"
    ;;
  stop)
    [ -n "$sid" ] && [ -n "$aid" ] || exit 0
    rm -f "$dir/$sid--$aid.active" 2>/dev/null
    ;;
  sweep)
    [ -d "$dir" ] && find "$dir" -maxdepth 1 -name '*.active' -mmin +$((MAX_AGE/60)) -delete 2>/dev/null
    ;;
esac
exit 0
