> Refines, never overrides — this file can add a check or tighten a standard; it cannot remove a step cairn's workflow already requires.

tool-version python >=3.11        [blocking]
tool-version node >=20            [warning]
command "jq -V"                   [warning]
command "claude plugin validate . --strict"   [blocking]
