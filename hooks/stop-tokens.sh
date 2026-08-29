#!/usr/bin/env bash
set -uo pipefail

if [ "${1:-}" = --selftest ]; then
  p=0; f=0
  t(){ if "$@"; then p=$((p+1)); else f=$((f+1)); fi; }
  t bash -n "$0"
  kj=".claude/cairn/known-projects.json"
  stub(){ s="$1/token-metering"; mkdir -p "$s"; printf 'def parse_session(*a):\n (a[0]/"z").touch()\n' >"$s/parser.py"; }
  run(){ CLAUDE_PLUGIN_ROOT="$1" HOME="$2" "$0" <<<'{"session_id":"a","transcript_path":"tp","cwd":"'"$3"'"}' >/dev/null 2>&1; }
  w=$(mktemp -d); echo x >"$w/CLAUDE.md"
  o=$("$0" <<<"{\"session_id\":\"a\",\"transcript_path\":\"b\",\"cwd\":\"$w\"}" 2>&1)
  t [ -z "$o" -a ! -d "$w/.cairn" ]
  echo '<!-- cairn:start -->' >"$w/CLAUDE.md"; stub "$w/pl"; h=$(mktemp -d)
  run "$w/pl" "$h" "$w"
  t [ -f "$w/.cairn/z" -a ! -f "$h/$kj" ]
  rm -rf "$h"
  pl=$(mktemp -d); h=$(mktemp -d)
  run "$pl" "$h" "$w"
  t [ -f "$h/$kj" -a -n "$(grep -F "$w" "$h/$kj" 2>/dev/null)" ]
  rm -rf "$w" "$pl" "$h"
  echo "stop-tokens.sh selftest: $p passed, $f failed"
  [ "$f" -eq 0 ]; exit $?
fi

command -v jq >/dev/null 2>&1 || exit 0

IFS=$'\t' read -r si tp cwd <<< "$(jq -r '[.session_id,.transcript_path,.cwd]|map(.//"")|@tsv' 2>/dev/null)"
[ -n "$si" ] && [ -n "$tp" ] && [ -n "$cwd" ] || exit 0

grep -qF '<!-- cairn:start -->' "$cwd/CLAUDE.md" 2>/dev/null || exit 0

cd="$cwd/.cairn"; mkdir -p "$cd" 2>/dev/null || exit 0
[ -f "$cd/.gitignore" ] || printf '*\n' > "$cd/.gitignore" 2>/dev/null

pr="${CLAUDE_PLUGIN_ROOT:-}"; [ -n "$pr" ] || exit 0

kp=""
[[ "$pr/" == "$cwd"/* ]] || { [ -n "${HOME:-}" ] && kp="$HOME/.claude/cairn/known-projects.json"; }

python3 -c 'import json,sys
from pathlib import Path
tm,cd,tp,i,cw,kp=sys.argv[1:7]
try: sys.path.insert(0,tm);import parser;parser.parse_session(Path(cd),Path(tp),i)
except Exception:pass
try:
 if kp:
  k=Path(kp);k.parent.mkdir(parents=True,exist_ok=True);d=json.loads(k.read_text()) if k.exists() else []
  if cw not in d:d.append(cw);k.write_text(json.dumps(d)+chr(10))
except Exception:pass
' "$pr/token-metering" "$cd" "$tp" "$si" "$cwd" "$kp" >/dev/null 2>&1

exit 0
