#!/usr/bin/env bash
set -euo pipefail

# Run from repo root
cd "$(git rev-parse --show-toplevel)"

echo "==> Creating directories"
mkdir -p Scripts .github/workflows

#######################################
# Gemfile
#######################################
cat > Gemfile <<'EOF'
source "https://rubygems.org"

gem "jazzy"
EOF

#######################################
# .jazzy.yaml
#######################################
cat > .jazzy.yaml <<'EOF'
swift_build_tool: spm
module: Flow
min_acl: public
output: docs
EOF

#######################################
# Scripts/generate_docs.sh
#######################################
cat > Scripts/generate_docs.sh <<'EOF'
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
EOF

chmod +x Scripts/generate_docs.sh

#######################################
# .github/workflows/docs.yml
#######################################
cat > .github/workflows/docs.yml <<'EOF'
name: Docs

on:
  push:
    branches:
      - dev
    paths:
      - 'Package.swift'
      - '.jazzy.yaml'
      - 'Sources/**'
  workflow_dispatch:

jobs:
  generate-docs:
    runs-on: macos-15

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

      - name: Generate docs
        run: Scripts/generate_docs.sh

      # Optional: commit docs back to dev
      - name: Commit docs
        if: github.ref == 'refs/heads/dev'
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
          git add docs
          git commit -m "Update docs" || echo "No changes"
          git push
EOF

echo "==> Scaffolding complete."
echo "Run:  bundle install && Scripts/generate_docs.sh"
