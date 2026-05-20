#!/usr/bin/env bash
# Copyright (c) 2026 Tigera, Inc. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
# Post-install verification for zephyr CLI.
# Exits 0 if all checks pass, non-zero otherwise.

set -u

PASS=0; FAIL=0

check() {
  local label="$1"; local cmd="$2"; local expect="$3"
  if eval "$cmd" >/dev/null 2>&1; then
    printf '[ok]   %s\n' "$label"
    PASS=$((PASS+1))
  else
    printf '[FAIL] %s — %s\n' "$label" "$expect"
    FAIL=$((FAIL+1))
  fi
}

# 1. Binary callable
check "zephyr binary" "zephyr --version" "install via: brew install bun913/zephyr-cli/zephyr"

# 2. Config present and token not placeholder
check "config file" "[ -f $HOME/.zephyr/config.json ]" "create ~/.zephyr/config.json (see install.sh)"

if [ -f "$HOME/.zephyr/config.json" ]; then
  TOKEN=$(python3 -c "
import json
try:
  d = json.load(open('$HOME/.zephyr/config.json'))
  p = d.get('currentProfile','default')
  print(d.get('profiles',{}).get(p,{}).get('apiToken',''))
except: print('')
" 2>/dev/null)
  if [ -n "$TOKEN" ] && ! echo "$TOKEN" | grep -qi "your\|placeholder\|token-here"; then
    printf '[ok]   api-token set\n'
    PASS=$((PASS+1))
  else
    printf '[FAIL] api-token — edit ~/.zephyr/config.json and set a real apiToken\n'
    FAIL=$((FAIL+1))
  fi

  # 3. API reachable — project list returns something
  if command -v zephyr >/dev/null 2>&1; then
    RESULT=$(zephyr project list 2>/dev/null || echo "")
    if echo "$RESULT" | python3 -c "import json,sys; d=json.load(sys.stdin); assert len(d)>0" >/dev/null 2>&1; then
      printf '[ok]   API reachable (project list returned results)\n'
      PASS=$((PASS+1))
    else
      printf '[FAIL] API unreachable or returned empty — check apiToken and network\n'
      FAIL=$((FAIL+1))
    fi
  fi
fi

echo ""
printf 'Result: %d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
