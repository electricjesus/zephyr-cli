#!/usr/bin/env bash
# Copyright (c) 2026 Tigera, Inc. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
# Install zephyr CLI from the electricjesus Homebrew tap (supply-chain safe).
# Binaries are built and published to the fork's GH releases via CI.
#
# Flags:
#   --upgrade     run brew upgrade instead of install (use when already installed)
#   --no-config   skip config scaffold

set -euo pipefail

UPGRADE=0
NO_CONFIG=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --upgrade)   UPGRADE=1; shift ;;
    --no-config) NO_CONFIG=1; shift ;;
    *) echo "unknown flag: $1" >&2; exit 2 ;;
  esac
done

step() { printf '==> %s\n' "$1"; }
warn() { printf '[warn] %s\n' "$1"; }
err()  { printf '[err] %s\n' "$1" >&2; }

# 0. brew required
if ! command -v brew >/dev/null 2>&1; then
  err "Homebrew not found — required."
  err "Install: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
  exit 1
fi

TAP="electricjesus/zephyr-cli"
TAP_URL="https://github.com/electricjesus/zephyr-cli.git"

# 1. Tap the fork if not already tapped
if brew tap | grep -qF "$TAP"; then
  step "Tap $TAP already present"
else
  step "Tapping $TAP"
  brew tap "$TAP" "$TAP_URL"
fi

# 2. Install or upgrade
if [ "$UPGRADE" -eq 1 ]; then
  step "Upgrading zephyr from $TAP"
  brew upgrade "$TAP/zephyr"
elif command -v zephyr >/dev/null 2>&1; then
  VER=$(zephyr --version 2>/dev/null || echo "unknown")
  step "zephyr already installed ($VER) — use --upgrade to update"
else
  step "Installing zephyr from $TAP"
  brew install "$TAP/zephyr"
fi

# 3. Scaffold config if missing
CONFIG="$HOME/.zephyr/config.json"
if [ "$NO_CONFIG" -eq 0 ] && [ ! -f "$CONFIG" ]; then
  step "Creating config scaffold at $CONFIG"
  mkdir -p "$HOME/.zephyr"
  cat > "$CONFIG" <<'EOF'
{
  "currentProfile": "default",
  "profiles": {
    "default": {
      "apiToken": "YOUR_ZEPHYR_API_TOKEN",
      "projectKey": "YOUR_PROJECT_KEY",
      "jiraBaseUrl": "https://your-domain.atlassian.net"
    }
  }
}
EOF
  warn "Edit $CONFIG — set apiToken, projectKey, jiraBaseUrl"
  warn "Get API token: Zephyr Scale Settings > API Keys"
elif [ "$NO_CONFIG" -eq 0 ]; then
  step "Config already exists at $CONFIG — skipping scaffold"
fi

step "Done. Run verify.sh to confirm."
