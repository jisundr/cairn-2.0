#!/usr/bin/env bash
set -uo pipefail
if [ "${1:-}" = --selftest ]; then
p=0;f=0;t(){ "$@"&&p=$((p+1))||f=$((f+1)); }
t bash -n "$0"
h=$(mktemp -d);d="$h/.claude/cairn/active";mkdir -p "$d"
old="$d/old.json";echo '{}' >"$old";touch -t 202001010000 "$old"
new="$d/new.json";echo '{}' >"$new"
HOME="$h" "$0" <<<'{}' >/dev/null 2>&1
t [ ! -f "$old" -a -f "$new" ]
rm -rf "$h"
echo "session-start.sh selftest: $p passed, $f failed"
exit $((f>0))
fi

input="$(cat)"

active_dir="${HOME:-}/.claude/cairn/active"
[ -n "${HOME:-}" ] && [ -d "$active_dir" ] && find "$active_dir" -maxdepth 1 -name '*.json' -mtime +0 -delete 2>/dev/null

command -v jq >/dev/null 2>&1 || exit 0

session_id="$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null)"
[ -n "$session_id" ] || exit 0

cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)"
[ -n "$cwd" ] || exit 0

claude_md="$cwd/CLAUDE.md"
[ -f "$claude_md" ] || exit 0
grep -qF '<!-- cairn:start -->' "$claude_md" 2>/dev/null || exit 0

cairn_dir="$cwd/.cairn"
mkdir -p "$cairn_dir" 2>/dev/null || exit 0
[ -f "$cairn_dir/.gitignore" ] || printf '*\n' > "$cairn_dir/.gitignore" 2>/dev/null

manifest="${CLAUDE_PLUGIN_ROOT:-}/.claude-plugin/plugin.json"
version="unknown"
if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -f "$manifest" ]; then
  version="$(jq -r '.version // "unknown"' "$manifest" 2>/dev/null)"
fi

log="$cairn_dir/sessions.log"
prev_version=""
[ -f "$log" ] && prev_version="$(tail -n 1 "$log" 2>/dev/null | cut -f2)"

timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
printf '%s\t%s\t%s\n' "$timestamp" "$version" "$session_id" >> "$log" 2>/dev/null

if [ -n "$prev_version" ] && [ "$prev_version" != "$version" ] && [ "$version" != "unknown" ]; then
  printf 'cairn updated %s -> %s. Run /cairn-setup or /cairn-doctor to refresh harness state.\n' "$prev_version" "$version"
fi

exit 0
