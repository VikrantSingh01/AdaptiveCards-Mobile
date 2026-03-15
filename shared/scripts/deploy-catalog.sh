#!/bin/bash

# Copyright (c) Microsoft Corporation. All rights reserved.
# Author: Vikrant Singh (github.com/VikrantSingh01)
# Licensed under the MIT License.

# =============================================================================
# Deploy Design Catalog to GitHub Pages
# =============================================================================
#
# Deploys a design catalog (index.html + screenshots) to the gh-pages branch.
#
# Usage:
#   bash shared/scripts/deploy-catalog.sh                    # deploy latest catalog
#   bash shared/scripts/deploy-catalog.sh <catalog-dir>      # deploy specific catalog
#
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
WORKTREE_DIR="/tmp/gh-pages-deploy-$$"

# Resolve catalog directory
if [ -n "${1:-}" ]; then
    CATALOG_DIR="$1"
else
    CATALOG_DIR=$(ls -dt "$REPO_ROOT"/shared/test-results/design-catalog-* 2>/dev/null | head -1)
    if [ -z "$CATALOG_DIR" ]; then
        echo "ERROR: No design catalog found. Run design-pass.sh first."
        exit 1
    fi
fi

if [ ! -f "$CATALOG_DIR/index.html" ] || [ ! -d "$CATALOG_DIR/screenshots" ]; then
    echo "ERROR: $CATALOG_DIR is missing index.html or screenshots/"
    exit 1
fi

echo "=== Deploying Design Catalog ==="
echo "  Source: $CATALOG_DIR"
echo "  Target: gh-pages branch"
echo ""

# Clean up any stale worktrees
cd "$REPO_ROOT"
git worktree prune 2>/dev/null
rm -rf "$WORKTREE_DIR"

# Check if gh-pages branch exists
if git rev-parse --verify gh-pages &>/dev/null; then
    git worktree add -f "$WORKTREE_DIR" gh-pages
else
    git worktree add --detach "$WORKTREE_DIR"
    cd "$WORKTREE_DIR"
    git checkout --orphan gh-pages
    git rm -rf . >/dev/null 2>&1 || true
    cd "$REPO_ROOT"
fi

# Copy catalog content (preserving reviews/ directory across deploys)
cd "$WORKTREE_DIR"
rm -rf screenshots index.html
cp "$CATALOG_DIR/index.html" .
cp -r "$CATALOG_DIR/screenshots" .
touch .nojekyll

# Ensure reviews directory exists with index
if [ ! -d reviews ]; then
    mkdir -p reviews
    echo '{"reviewers":[],"lastUpdated":""}' > reviews/_index.json
    echo "  Created reviews/ directory"
else
    echo "  Preserved reviews/ directory ($(ls reviews/*.json 2>/dev/null | wc -l | tr -d ' ') reviewer files)"
fi

# Commit and push
git add -A
if git diff --cached --quiet; then
    echo "  No changes to deploy."
else
    git commit -m "chore: update design catalog $(date +%Y-%m-%d-%H%M)"
    git push origin gh-pages --force
    echo ""
    echo "  Deployed to: https://vikrantsingh01.github.io/AdaptiveCards-Mobile/"
fi

# Clean up
cd "$REPO_ROOT"
git worktree remove "$WORKTREE_DIR" --force 2>/dev/null

echo ""
echo "Done!"
