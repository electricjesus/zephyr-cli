#!/usr/bin/env bash
# Copyright (c) 2026 Tigera, Inc. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
# Preflight checks for zephyr CLI. Exits 0 on green, non-zero on first
# hard-blocker. Emits one JSON object per check on stdout
# (status: ok|warn|fail, label, detail).

set -u

OK=0; WARN=0; FAIL=0

emit() {
  printf '{"status":"%s","label":%s,"detail":%s}\n' \
    "$1" \
    "$(printf '%s' "$2" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')" \
    "$(printf '%s' "$3" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
  case "$1" in
    ok)   OK=$((OK+1)) ;;
    warn) WARN=$((WARN+1)) ;;
    fail) FAIL=$((FAIL+1)) ;;
  esac
}

CONFIG="$HOME/.zephyr/config.json"

# 1. brew (needed to install bun if bun absent)
if command -v brew >/dev/null 2>&1; then
  emit ok "brew" "$(brew --version 2>/dev/null | head -1)"
else
  emit warn "brew" "Homebrew not found — needed to install bun if bun is absent. See https://brew.sh"
fi

# 2. bun (required to build zephyr from source)
if command -v bun >/dev/null 2>&1; then
  emit ok "bun" "$(bun --version 2>/dev/null)"
else
  emit fail "bun" "bun not on PATH — required to build zephyr from source. Install: brew install bun OR https://bun.sh/docs/installation"
fi

# 3. zephyr binary (informational — may not be installed yet)
if command -v zephyr >/dev/null 2>&1; then
  emit ok "zephyr-binary" "$(zephyr --version 2>/dev/null || echo 'installed')"
else
  emit warn "zephyr-binary" "zephyr not on PATH — run install.sh to build and install from fork"
fi

# 4. Config file exists
if [ -f "$CONFIG" ]; then
  emit ok "config-file" "$CONFIG exists"
else
  emit warn "config-file" "$CONFIG not found — install.sh will scaffold it"
fi

# 5. apiToken not placeholder (only if config exists)
if [ -f "$CONFIG" ]; then
  TOKEN=$(python3 -c "
import json, sys
try:
  d = json.load(open('$CONFIG'))
  profile = d.get('currentProfile','default')
  print(d.get('profiles',{}).get(profile,{}).get('apiToken',''))
except Exception:
  print('')
" 2>/dev/null)
  if [ -z "$TOKEN" ] || echo "$TOKEN" | grep -qi "your\|placeholder\|token-here\|api-token"; then
    emit fail "api-token" "apiToken is missing or still a placeholder in $CONFIG"
  else
    PROFILE=$(python3 -c "import json; d=json.load(open('$CONFIG')); print(d.get('currentProfile','default'))" 2>/dev/null)
    emit ok "api-token" "apiToken set (profile: $PROFILE)"
  fi
fi

# 6. projectKey set
if [ -f "$CONFIG" ]; then
  KEY=$(python3 -c "
import json
try:
  d = json.load(open('$CONFIG'))
  profile = d.get('currentProfile','default')
  print(d.get('profiles',{}).get(profile,{}).get('projectKey',''))
except:
  print('')
" 2>/dev/null)
  if [ -z "$KEY" ]; then
    emit warn "project-key" "projectKey not set — most commands require it"
  else
    emit ok "project-key" "projectKey=$KEY"
  fi
fi

# 7. jiraBaseUrl set
if [ -f "$CONFIG" ]; then
  JIRA=$(python3 -c "
import json
try:
  d = json.load(open('$CONFIG'))
  profile = d.get('currentProfile','default')
  print(d.get('profiles',{}).get(profile,{}).get('jiraBaseUrl',''))
except:
  print('')
" 2>/dev/null)
  if [ -z "$JIRA" ]; then
    emit warn "jira-base-url" "jiraBaseUrl not set — 'zephyr open' and TUI 'o' key won't work"
  else
    emit ok "jira-base-url" "$JIRA"
  fi
fi

# Summary
echo ""
printf '{"summary":{"ok":%d,"warn":%d,"fail":%d}}\n' "$OK" "$WARN" "$FAIL"

[ "$FAIL" -eq 0 ]
