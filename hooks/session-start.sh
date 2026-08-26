#!/usr/bin/env bash
set -uo pipefail

input="$(cat)"

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
