#!/usr/bin/env bash
set -euo pipefail

# Run from the repository root (where Package.swift lives).
cd "$(git rev-parse --show-toplevel)"

# 1. Ensure dependencies are installed
if [ -f "Gemfile" ]; then
  echo "==> Installing Ruby gems via Bundler"
  bundle install --quiet
fi

# 2. Extract Swift tools version from Package.swift
if ! grep -q "swift-tools-version:" Package.swift; then
  echo "Error: Could not find 'swift-tools-version:' in Package.swift" >&2
  exit 1
fi

SWIFT_TOOLS_VERSION=$(
  grep -Eo 'swift-tools-version:[0-9.]+' Package.swift | cut -d: -f2
)

echo "==> Using Swift version ${SWIFT_TOOLS_VERSION} from Package.swift"

# 3. Build docs with Jazzy (config from .jazzy.yaml)
JAZZY_CMD=(bundle exec jazzy --swift-version "${SWIFT_TOOLS_VERSION}")

echo "==> Running: ${JAZZY_CMD[*]}"
"${JAZZY_CMD[@]}"

echo "==> Documentation generated in ./docs"
