#!/usr/bin/env bash
# update-fork.sh — sync the local working directory into this git repo, commit and push.
#
# Usage:
#   ./update-fork.sh                          # auto-generated commit message with timestamp
#   ./update-fork.sh "your commit message"    # custom commit message
#
# This script expects:
#   - It is run from inside a clone of the fork (it auto-detects the git root).
#   - The "source" folder containing the working theme.css and assets sits next to
#     the fork clone at `../Authentik-Login-theme-Glassmorphism-main/Authentik-Login-theme-Glassmorphism-main/`.
#     (That's the default layout when you extract the ZIP next to the fork clone.)

set -euo pipefail

# --- Resolve paths ---
FORK_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${FORK_ROOT}" ]]; then
    echo "❌ Not inside a git repository. cd into your fork clone first."
    exit 1
fi
cd "${FORK_ROOT}"

SOURCE_DIR="$(cd "${FORK_ROOT}/../Authentik-Login-theme-Glassmorphism-main/Authentik-Login-theme-Glassmorphism-main" 2>/dev/null && pwd || true)"
if [[ -z "${SOURCE_DIR}" || ! -f "${SOURCE_DIR}/theme.css" ]]; then
    echo "❌ Cannot find source theme.css at ../Authentik-Login-theme-Glassmorphism-main/Authentik-Login-theme-Glassmorphism-main/"
    echo "   Expected layout:"
    echo "     theme_authentik/"
    echo "       ├── Authentik-Login-theme-Glassmorphism-main/   (source ZIP extract — what you edit)"
    echo "       └── fork/                                       (this fork clone)"
    exit 1
fi

echo "📂 Source: ${SOURCE_DIR}"
echo "📂 Fork  : ${FORK_ROOT}"

# --- Copy files ---
echo "📋 Copying files..."
cp "${SOURCE_DIR}/theme.css" "${FORK_ROOT}/theme.css"
[[ -f "${SOURCE_DIR}/README.md" ]] && cp "${SOURCE_DIR}/README.md" "${FORK_ROOT}/README.md"
[[ -f "${SOURCE_DIR}/CHANGELOG.md" ]] && cp "${SOURCE_DIR}/CHANGELOG.md" "${FORK_ROOT}/CHANGELOG.md"

# Sync screenshots/ if present
if [[ -d "${SOURCE_DIR}/screenshots" ]]; then
    mkdir -p "${FORK_ROOT}/screenshots"
    cp -f "${SOURCE_DIR}/screenshots/"*.jpg "${FORK_ROOT}/screenshots/" 2>/dev/null || true
    cp -f "${SOURCE_DIR}/screenshots/"*.png "${FORK_ROOT}/screenshots/" 2>/dev/null || true
    cp -f "${SOURCE_DIR}/screenshots/"*.webp "${FORK_ROOT}/screenshots/" 2>/dev/null || true
fi

# --- Bail out if nothing changed ---
if [[ -z "$(git status --porcelain)" ]]; then
    echo "✅ Nothing to commit — local files are already in sync with the fork."
    exit 0
fi

# --- Stage + commit ---
git add -A

MESSAGE="${1:-chore: sync theme update $(date +%Y-%m-%d_%H-%M)}"
echo "📝 Commit message: ${MESSAGE}"
git commit -m "${MESSAGE}"

# --- Push ---
echo "🚀 Pushing to origin..."
git push

echo "✅ Done. Check your fork on GitHub."
