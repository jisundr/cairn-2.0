#!/usr/bin/env bash
set -uo pipefail
if [ "${1:-}" = --selftest ]; then
p=0;f=0;t(){ "$@"&&p=$((p+1))||f=$((f+1)); }
t bash -n "$0"
h=$(mktemp -d);d="$h/.claude/cairn/active";mkdir -p "$d"
echo '{}' >"$d/old.json";touch -t 202001010000 "$d/old.json";echo '{}' >"$d/new.json"
HOME="$h" "$0" <<<'{}' &>/dev/null
t [ ! -f "$d/old.json" -a -f "$d/new.json" ]
rm -rf "$h"
echo "session-start.sh selftest: $p passed, $f failed"
exit $((f>0))
fi
in="$(cat)"
[ -n "${HOME:-}" ] && find "$HOME/.claude/cairn/active" -maxdepth 1 -name '*.json' -mtime +0 -delete 2>/dev/null
command -v jq >/dev/null 2>&1 || exit 0
IFS=$'\t' read -r sid cwd <<<"$(jq -r '[.session_id,.cwd]|map(.//"")|@tsv' <<<"$in" 2>/dev/null)"
[ -n "$sid" -a -n "$cwd" ] || exit 0
grep -qsF '<!-- cairn:start -->' "$cwd/CLAUDE.md" || exit 0
c="$cwd/.cairn";mkdir -p "$c" 2>/dev/null || exit 0
[ -f "$c/.gitignore" ] || echo '*' >"$c/.gitignore" 2>/dev/null
v=unknown;m="${CLAUDE_PLUGIN_ROOT:-}/.claude-plugin/plugin.json"
[ -n "${CLAUDE_PLUGIN_ROOT:-}" -a -f "$m" ] && v="$(jq -r '.version // "unknown"' "$m" 2>/dev/null)"
l="$c/sessions.log";pv=""
[ -f "$l" ] && pv="$(tail -n 1 "$l" 2>/dev/null | cut -f2)"
printf '%s\t%s\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$v" "$sid" >>"$l" 2>/dev/null
[ -n "$pv" -a "$pv" != "$v" -a "$v" != unknown ] && printf 'cairn updated %s -> %s. Run /cairn-setup or /cairn-doctor to refresh harness state.\n' "$pv" "$v"
exit 0
