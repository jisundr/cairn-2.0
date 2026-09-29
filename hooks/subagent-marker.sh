#!/usr/bin/env bash
set -uo pipefail
if [ "${1:-}" = --selftest ]; then
p=0;f=0;t(){ "$@"&&p=$((p+1))||f=$((f+1)); }
t bash -n "$0"
h=$(mktemp -d);d="$h/.claude/cairn/active";mkdir -p "$d"
echo '{"project":"/p","task":"docs/tasks/x"}' >"$d/s1.json"
r(){ HOME="$h" "$0" "$1" <<<"{\"session_id\":\"$2\",\"agent_id\":\"$3\"}" 2>&1; }
r start s1 a1
t [ "$(jq -r .task "$d/s1--a1.active")" = docs/tasks/x ]
t [ -z "$(r start nop a1)" -a ! -e "$d/nop--a1.active" ]
r stop s1 a1
t [ ! -e "$d/s1--a1.active" ]
t [ -z "$(r stop s1 none)" ]
echo '{}' >"$d/old--a.active";touch -t 202001010000 "$d/old--a.active"
echo '{}' >"$d/other--b.active"
r sweep s1 x
t [ ! -e "$d/old--a.active" -a -e "$d/other--b.active" ]
rm -rf "$h"
echo "subagent-marker.sh selftest: $p passed, $f failed"
exit $((f>0))
fi
command -v jq >/dev/null 2>&1 || exit 0
d="${HOME:-/x}/.claude/cairn/active"
j="$(cat)"
s="$(jq -r '.session_id // empty' <<<"$j" 2>/dev/null)"
a="$(jq -r '.agent_id // empty' <<<"$j" 2>/dev/null)"
case "${1:-}" in
  start)
    [ -n "$s" -a -n "$a" -a -f "$d/$s.json" ] || exit 0
    b="$(jq -c 'select((.project|type)=="string" and (.task|type)=="string")|{project,task}' "$d/$s.json" 2>/dev/null)"
    [ -n "$b" ] || exit 0
    m="$(mktemp "$d/.marker.XXXXXX")" || exit 0
    echo "$b" >"$m" && mv "$m" "$d/$s--$a.active" || rm -f "$m"
    ;;
  stop) [ -n "$s" -a -n "$a" ] && rm -f "$d/$s--$a.active" ;;
  sweep) find "$d" -maxdepth 1 -name '*.active' -mmin +240 -delete 2>/dev/null ;;
esac
exit 0
