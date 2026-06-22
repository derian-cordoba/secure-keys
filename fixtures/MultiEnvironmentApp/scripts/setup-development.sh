#!/usr/bin/env bash
# Setup script for the development environment.
# Installs placeholder secret values into the macOS Keychain under the
# "multi-env-app-dev" service name so that `secure-keys env generate development`
# can read them locally.
#
# Usage:
#   ./scripts/setup-development.sh
#
# Tip: Replace the placeholder values below with your real secrets before running.

set -euo pipefail

IDENTIFIER="multi-env-app-dev"

echo "→ Installing development secrets into the Keychain…"

# Register which keys belong to this environment
security add-generic-password \
  -a "$IDENTIFIER" \
  -s "$IDENTIFIER" \
  -w "apiKey,debugToken,analyticsKey,featureFlagKey" \
  -U

# Individual secret values (replace with real values)
security add-generic-password -a "$IDENTIFIER" -s "apiKey"         -w "dev-api-key-replace-me"       -U
security add-generic-password -a "$IDENTIFIER" -s "debugToken"     -w "dev-debug-token-replace-me"   -U
security add-generic-password -a "$IDENTIFIER" -s "analyticsKey"   -w "dev-analytics-key-replace-me" -U
security add-generic-password -a "$IDENTIFIER" -s "featureFlagKey" -w "dev-feature-flag-replace-me"  -U

echo "✓ Development secrets installed."
echo ""
echo "Now generate the xcframework:"
echo "  secure-keys env generate development"
