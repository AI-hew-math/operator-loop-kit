#!/usr/bin/env bash
set -euo pipefail

origin_url="$(git remote get-url origin 2>/dev/null || true)"

if [[ "$origin_url" == *"AI-hew-math/research-template"* ]] || [[ "$origin_url" == *"github.com/AI-hew-math/research-template"* ]]; then
  echo "BLOCKED: origin points to template repo (research-template). Do NOT push."
  echo "Create a new repo from template and use that URL instead."
  exit 1
fi

echo "OK: origin is not template repo."
