# MultiEnvironmentApp

> [!WARNING]
> For demonstration purposes, secrets are printed to the Xcode console in `DEBUG` builds only. In a real project, never log or display secret values.

This fixture shows how to use `secure-keys env` to manage distinct secret sets across **development**, **staging**, and **production** environments — each with its own identifier, key list, secret source, and output path.

---

## Table of contents

1. [How it works](#how-it-works)
2. [Project structure](#project-structure)
3. [Configuration reference](#configuration-reference)
4. [Local development setup](#local-development-setup)
5. [CI/CD setup](#cicd-setup)
6. [CLI command reference](#cli-command-reference)
7. [Swift integration](#swift-integration)
8. [Recommendations](#recommendations)

---

## How it works

`secure-keys env` reads a YAML configuration file (`.secure-keys.yml`) that declares one block per environment. Each block specifies:

| Field        | Purpose |
|-------------|---------|
| `identifier` | Keychain service name (local) or prefix for env-var lookup (CI) |
| `delimiter`  | Character that separates key names in the Keychain value |
| `source`     | `keychain` (local dev) or `environment` (CI/CD) |
| `keys`       | List of secret names to encrypt into the xcframework |
| `output`     | Directory where `SecureKeys.xcframework` is written |

When you run `secure-keys env generate <name>`, the tool:

1. Reads the named environment block from `.secure-keys.yml`.
2. Fetches each secret value from the Keychain or from environment variables (depending on `source`).
3. Encrypts the values with AES-256-GCM.
4. Writes the xcframework to the `output` path.

---

## Project structure

```
MultiEnvironmentApp/
├── .secure-keys.yml               # Multi-environment configuration
├── Makefile                       # Convenience make targets
├── scripts/
│   ├── setup-development.sh       # Install dev secrets into the Keychain
│   ├── setup-staging.sh           # Export staging env vars
│   └── setup-production.sh        # Export production env vars (CI only)
├── .github/
│   └── workflows/
│       └── generate-keys.yml      # GitHub Actions workflow
└── MultiEnvironmentApp/           # iOS SwiftUI source
    ├── MultiEnvironmentApp.swift  # @main entry point
    ├── ContentView.swift          # Example SecureKeys usage
    └── AppConstants.swift         # Centralised secrets accessor
```

---

## Configuration reference

The `.secure-keys.yml` in this fixture configures three environments:

```yaml
environments:
  development:
    identifier: multi-env-app-dev   # Keychain service name
    delimiter: ","
    source: keychain                # Read from the macOS Keychain
    keys:
      - apiKey
      - debugToken                  # Dev-only key
      - analyticsKey
      - featureFlagKey
    output: .secure-keys/development

  staging:
    identifier: multi-env-app-staging
    delimiter: ","
    source: environment             # Read from environment variables
    keys:
      - apiKey
      - analyticsKey
      - featureFlagKey
    output: .secure-keys/staging

  production:
    identifier: multi-env-app-prod
    delimiter: ","
    source: environment             # Read from environment variables
    keys:
      - apiKey
      - analyticsKey               # Minimal surface area
    output: .secure-keys/production
```

Key design decisions:

- **`debugToken`** exists only in `development` — it is never compiled into staging or production builds, minimising the risk of accidental exposure.
- **`featureFlagKey`** is available in development and staging for testing feature flags before release, but excluded from production.
- **`source: keychain`** is used in development so engineers can manage secrets locally without exporting environment variables.
- **`source: environment`** is used in staging and production so CI/CD pipelines inject secrets without touching the Keychain.

---

## Local development setup

### Prerequisites

- macOS 11.0 or later
- Ruby 3.3+
- `secure-keys` installed (`gem install secure-keys` or `brew install derian-cordoba/secure-keys/secure-keys`)

### 1 — Install development secrets into the Keychain

```bash
./scripts/setup-development.sh
```

This script calls `security add-generic-password` to register the secret values under the `multi-env-app-dev` service. Edit the placeholder values in the script with your real secrets before running.

Alternatively, run the commands manually:

```bash
IDENTIFIER="multi-env-app-dev"

security add-generic-password -a "$IDENTIFIER" -s "$IDENTIFIER" \
  -w "apiKey,debugToken,analyticsKey,featureFlagKey" -U

security add-generic-password -a "$IDENTIFIER" -s "apiKey"         -w "<your-api-key>"         -U
security add-generic-password -a "$IDENTIFIER" -s "debugToken"     -w "<your-debug-token>"     -U
security add-generic-password -a "$IDENTIFIER" -s "analyticsKey"   -w "<your-analytics-key>"   -U
security add-generic-password -a "$IDENTIFIER" -s "featureFlagKey" -w "<your-feature-flag-key>" -U
```

### 2 — Generate the development xcframework

```bash
secure-keys env generate development
# or
make generate-dev
```

The framework is written to `.secure-keys/development/SecureKeys.xcframework`.

### 3 — Link the xcframework in Xcode

In your Xcode project, under **General → Frameworks, Libraries, and Embedded Content**, add:

```
.secure-keys/development/SecureKeys.xcframework
```

> [!NOTE]
> Each environment produces a separate framework. You can maintain multiple Xcode schemes — one per environment — each pointing to the appropriate `.secure-keys/<environment>/SecureKeys.xcframework`.

---

## CI/CD setup

This fixture includes a GitHub Actions workflow at `.github/workflows/generate-keys.yml`.

### Required secrets

Configure the following in your GitHub repository under **Settings → Environments**:

| Environment | Secret name              | Description |
|-------------|--------------------------|-------------|
| `staging`   | `STAGING_API_KEY`        | Staging API key |
| `staging`   | `STAGING_ANALYTICS_KEY`  | Staging analytics key |
| `staging`   | `STAGING_FEATURE_FLAG_KEY` | Staging feature flag key |
| `production`| `PROD_API_KEY`           | Production API key |
| `production`| `PROD_ANALYTICS_KEY`     | Production analytics key |

The workflow injects each secret as an environment variable. `secure-keys env generate staging` reads those variables because `source: environment` is set for staging and production.

### Workflow overview

```
push to staging branch  →  generate-staging job  →  upload artifact
push to main branch     →  generate-production job → upload artifact
workflow_dispatch       →  choose environment manually
```

Artifacts are uploaded and retained for post-build consumption (e.g., embedding the xcframework in an archive job that follows).

---

## CLI command reference

All commands are run from the directory containing `.secure-keys.yml`.

```bash
# List all configured environments
secure-keys env list

# Compare two environments side by side
secure-keys env diff development production

# Generate for a specific environment
secure-keys env generate development
secure-keys env generate staging
secure-keys env generate production

# Generate for every environment at once
secure-keys env generate --all

# Show env subcommand help
secure-keys env --help

# Show generate subcommand help
secure-keys env generate --help
```

### Make targets (convenience wrappers)

```bash
make init                          # Create .secure-keys.yml from default template
make list                          # List environments
make diff ENV_A=development ENV_B=production   # Diff two environments
make setup-dev                     # Install dev Keychain secrets
make generate-dev                  # Generate development xcframework
make generate-staging              # Generate staging xcframework
make generate-production           # Generate production xcframework
make generate-all                  # Generate all xcframeworks
make clean                         # Delete all .secure-keys output directories
```

---

## Swift integration

### Accessing secrets

Import `SecureKeys` and call the `key(for:)` free function with a key name that matches one of the `keys` entries in `.secure-keys.yml`.

```swift
import SecureKeys

let apiKey = key(for: .apiKey)
```

### Centralising access with AppConstants

`AppConstants.swift` wraps all secret access in one place so that:

- Only one file imports `SecureKeys`.
- Key names are not scattered across the codebase.
- Dev-only keys (`debugToken`, `featureFlagKey`) are wrapped in `#if DEBUG` so the compiler excludes them from Release builds automatically.

```swift
// Consuming code — no direct SecureKeys import needed
let url  = AppConstants.apiBaseURL
let key  = AppConstants.apiKey
```

---

## Recommendations

### Secret surface area
Keep the key list in each environment as small as possible. Only include secrets that the environment genuinely needs. `production` in this fixture intentionally omits `debugToken` and `featureFlagKey`.

### Never commit `.secure-keys/`
Add `.secure-keys/` to your `.gitignore`. The xcframeworks contain AES-256-GCM encrypted values; while encrypted, committing them is still poor practice.

```gitignore
# Generated SecureKeys xcframeworks
.secure-keys/
```

### Separate identifiers per environment
Use a unique `identifier` per environment (e.g., `my-app-dev`, `my-app-staging`, `my-app-prod`). This prevents accidental cross-contamination when Keychain lookups fall through.

### Production secrets only in CI
Never install production secrets on a developer machine. Use `source: environment` for production and inject values exclusively through your CI/CD secrets store (GitHub Actions, CircleCI contexts, Fastlane Match, etc.).

### Xcode scheme per environment
Create one Xcode scheme for each environment. In the scheme's **Pre-actions**, run:

```bash
secure-keys env generate development   # or staging, production
```

This auto-regenerates the xcframework before each build, keeping secrets in sync with the Keychain.

### Diff before a release
Run `secure-keys env diff staging production` before cutting a release to confirm the two environments share the expected keys and spot any configuration drift.

```
secure-keys env diff staging production

Comparing: staging → production
──────────────────────────────────────────────────────────────────────
    Configuration: identical

    Keys (staging: 3, production: 2):
        ✓ apiKey
        ✓ analyticsKey
        − featureFlagKey (only in staging)
──────────────────────────────────────────────────────────────────────
```
