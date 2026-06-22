#!/usr/bin/env bash
# Setup script for the production environment.
# Exports environment variables consumed by `secure-keys env generate production`.
# Production secrets must never be stored in the Keychain on developer machines.
# Always load them from your CI secrets store or a secrets manager (e.g. 1Password,
# AWS Secrets Manager, GitHub Actions encrypted secrets).
#
# Usage (CI — export these as masked secrets in your CI provider):
#   export apiKey="…"
#   export analyticsKey="…"
#
# DO NOT commit real values here. This file is a template only.

set -euo pipefail

echo "→ Exporting production environment variables…"

# These should come from your CI/CD secrets store — not hardcoded here.
export apiKey="${PROD_API_KEY:?PROD_API_KEY must be set}"
export analyticsKey="${PROD_ANALYTICS_KEY:?PROD_ANALYTICS_KEY must be set}"

echo "✓ Production environment variables exported."
echo ""
echo "Now generate the xcframework:"
echo "  secure-keys env generate production"
