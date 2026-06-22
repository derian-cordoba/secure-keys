#!/usr/bin/env bash
# Setup script for the staging environment.
# Exports environment variables consumed by `secure-keys env generate staging`.
# The staging environment uses source: environment (CI mode), so secrets are
# read from shell variables — not the Keychain.
#
# Usage (local):
#   source ./scripts/setup-staging.sh
#
# Usage (CI — export these as masked secrets in your CI provider):
#   export apiKey="…"
#   export analyticsKey="…"
#   export featureFlagKey="…"

set -euo pipefail

echo "→ Exporting staging environment variables…"

export apiKey="${STAGING_API_KEY:-staging-api-key-replace-me}"
export analyticsKey="${STAGING_ANALYTICS_KEY:-staging-analytics-key-replace-me}"
export featureFlagKey="${STAGING_FEATURE_FLAG_KEY:-staging-feature-flag-replace-me}"

echo "✓ Staging environment variables exported."
echo ""
echo "Now generate the xcframework:"
echo "  secure-keys env generate staging"
