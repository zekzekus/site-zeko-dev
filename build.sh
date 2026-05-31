#!/usr/bin/env bash
# Build script for Cloudflare Workers. Installs a pinned Zola then builds.
# Locally you should use `nix develop` instead — this script is for CI.

set -euo pipefail

ZOLA_VERSION="${ZOLA_VERSION:-0.22.1}"

if ! command -v zola >/dev/null 2>&1; then
  echo "Installing Zola ${ZOLA_VERSION}..."
  install_dir="${HOME}/.local/zola"
  mkdir -p "${install_dir}"
  curl -sSfL \
    "https://github.com/getzola/zola/releases/download/v${ZOLA_VERSION}/zola-v${ZOLA_VERSION}-x86_64-unknown-linux-gnu.tar.gz" \
    | tar -xz -C "${install_dir}"
  export PATH="${install_dir}:${PATH}"
fi

echo "Using $(zola --version)"
zola build --minify
