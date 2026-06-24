# Secure Key Generator for iOS Projects

`secure-keys` is a Ruby CLI that generates a `SecureKeys.xcframework` for iOS apps. It reads secret values from macOS Keychain on local machines or environment variables in CI, encrypts those values with AES-256-GCM, writes a Swift API, builds an XCFramework, and optionally adds that framework to an Xcode target.

## Requirements

- macOS 11.0 or later
- Ruby 3.3 or later
- Xcode command line tools
- iOS 13.0 or later

## Installation

Install with Homebrew:

```bash
brew tap derian-cordoba/secure-keys
brew install derian-cordoba/secure-keys/secure-keys
```

Install with RubyGems:

```bash
gem install secure-keys
```

Install with Bundler:

```ruby
gem 'secure-keys'
```

```bash
bundle install
```

## Quick Start

From an iOS project root:

```bash
security add-generic-password -a "secure-keys" -s "secure-keys" -w "apiKey,githubToken"
security add-generic-password -a "secure-keys" -s "apiKey" -w "your-api-key"
security add-generic-password -a "secure-keys" -s "githubToken" -w "your-github-token"

secure-keys
```

The command creates `.secure-keys/SecureKeys.xcframework`.

Use the generated framework from Swift:

```swift
import SecureKeys

let apiKey = SecureKey.apiKey.decryptedValue
let githubToken = key(for: .githubToken)
```

## How Secret Generation Works

`secure-keys` does not create third-party API keys for providers such as GitHub, Firebase, Stripe, or AWS. Those secrets must be created in their owning service first.

The tool generates an iOS framework that contains encrypted copies of the secret values you provide:

1. Resolve the secret source:
   - Local runs use macOS Keychain unless CI mode is enabled.
   - CI runs use environment variables.
2. Read the configured list of secret names.
3. Read each secret value by name.
4. Generate a random AES-256-GCM key for this build.
5. Encrypt each secret value.
6. Write a Swift `SecureKey` enum with encrypted byte arrays.
7. Build `.secure-keys/SecureKeys.xcframework`.
8. Remove temporary Swift package files.

## Local Configuration With Keychain

The default Keychain service and account identifier is `secure-keys`.

Store the list of secret names:

```bash
security add-generic-password -a "secure-keys" -s "secure-keys" -w "githubToken,apiKey"
```

Store each secret value under the same Keychain service:

```bash
security add-generic-password -a "secure-keys" -s "githubToken" -w "your-github-token"
security add-generic-password -a "secure-keys" -s "apiKey" -w "your-api-key"
```

Use a custom Keychain identifier:

```bash
export SECURE_KEYS_IDENTIFIER="my-app-secrets"

security add-generic-password -a "$SECURE_KEYS_IDENTIFIER" -s "$SECURE_KEYS_IDENTIFIER" -w "githubToken,apiKey"
security add-generic-password -a "$SECURE_KEYS_IDENTIFIER" -s "githubToken" -w "your-github-token"
security add-generic-password -a "$SECURE_KEYS_IDENTIFIER" -s "apiKey" -w "your-api-key"
```

Use a custom delimiter:

```bash
export SECURE_KEYS_DELIMITER="|"
security add-generic-password -a "secure-keys" -s "secure-keys" -w "githubToken|apiKey"
```

## CI Configuration With Environment Variables

CI mode is enabled automatically when common CI variables are present, including `CI=true` and `GITHUB_ACTIONS=true`. You can also force it:

```bash
secure-keys --ci
```

Set the list of secret names in `SECURE_KEYS_IDENTIFIER`:

```bash
export SECURE_KEYS_IDENTIFIER="github-token,api_key,firebaseToken"
```

Set each secret value as an environment variable. Secret names are looked up exactly first, then normalized by converting `-` to `_` and uppercasing.

```bash
export GITHUB_TOKEN="your-github-token"
export API_KEY="your-api-key"
export FIREBASETOKEN="your-firebase-token"
```

The `SECURE_KEYS_` prefix is also supported for secret values:

```bash
export SECURE_KEYS_API_KEY="your-api-key"
```

You can store the list in a dedicated environment variable instead:

```bash
export CUSTOM_SECRET_LIST="github-token,api_key"
secure-keys --ci --identifier CUSTOM_SECRET_LIST
```

Use a custom delimiter in CI:

```bash
export SECURE_KEYS_DELIMITER="|"
export SECURE_KEYS_IDENTIFIER="github-token|api_key|firebaseToken"
```

## CLI Reference

```bash
secure-keys --help
```

```text
Usage: secure-keys [--options]

    -h, --help                       Use the provided commands to select the params
        --ci                         Enable CI mode (default: false)
    -d, --delimiter DELIMITER        The delimiter to use for the key access (default: ",")
        --[no-]generate              Generate the SecureKeys.xcframework
    -i, --identifier IDENTIFIER      The identifier to use for the key access (default: "secure-keys")
        --verbose                    Enable verbose mode (default: false)
    -v, --version                    Show the secure-keys version
        --xcframework                Add the xcframework to the target
```

Examples:

```bash
secure-keys
secure-keys --verbose
secure-keys --ci --identifier CUSTOM_SECRET_LIST
secure-keys --identifier "my-app-secrets" --delimiter "|"
secure-keys -i "my-app-secrets" -d "|"
```

## Multi-Environment Support

`secure-keys env` manages distinct secret sets for multiple environments — development, staging, and production — each with its own identifier, key list, secret source, and output path. Configuration is driven by a `.secure-keys.yml` file in your project root.

### Configuration file

Create a default configuration file:

```bash
secure-keys env init
```

This writes `.secure-keys.yml` to the current directory with a development/staging/production template. Edit the file to match your project's secrets:

```yaml
environments:
  development:
    identifier: my-app-dev    # Keychain service name
    delimiter: ","
    source: keychain           # Read from macOS Keychain
    keys:
      - apiKey
      - debugToken
      - analyticsKey
    output: .secure-keys/development

  staging:
    identifier: my-app-staging
    delimiter: ","
    source: environment        # Read from environment variables
    keys:
      - apiKey
      - analyticsKey
    output: .secure-keys/staging

  production:
    identifier: my-app-prod
    delimiter: ","
    source: environment
    keys:
      - apiKey
      - analyticsKey
    output: .secure-keys/production
```

| Field | Purpose |
|---|---|
| `identifier` | Keychain service name (local) or environment variable holding the key list (CI) |
| `delimiter` | Character that separates key names in the Keychain value (default: `,`) |
| `source` | `keychain` for local development, `environment` for CI/CD |
| `keys` | List of secret names to encrypt into the xcframework |
| `output` | Directory where `SecureKeys.xcframework` is written |

### Local development

Install development secrets into the Keychain once:

```bash
IDENTIFIER="my-app-dev"

security add-generic-password -a "$IDENTIFIER" -s "$IDENTIFIER" \
  -w "apiKey,debugToken,analyticsKey" -U

security add-generic-password -a "$IDENTIFIER" -s "apiKey"       -w "<your-api-key>"       -U
security add-generic-password -a "$IDENTIFIER" -s "debugToken"   -w "<your-debug-token>"   -U
security add-generic-password -a "$IDENTIFIER" -s "analyticsKey" -w "<your-analytics-key>" -U
```

Generate the development xcframework:

```bash
secure-keys env generate development
```

The framework is written to `.secure-keys/development/SecureKeys.xcframework`.

### CI/CD

For environments with `source: environment`, export the key list and each secret value as environment variables before running `generate`:

```bash
export MY_APP_STAGING="apiKey,analyticsKey"
export apiKey="your-staging-api-key"
export analyticsKey="your-staging-analytics-key"

secure-keys env generate staging
```

The key-list variable name is the `identifier` value with `-` replaced by `_` and uppercased (e.g. `my-app-staging` → `MY_APP_STAGING`). Individual secret values follow the same lookup order as the core CLI: exact name first, then normalized (`-` → `_`, uppercased), then with the `SECURE_KEYS_` prefix.

### Subcommands

```text
Usage: secure-keys env [subcommand] [--options]

    -h, --help                       Show help for the env command

Subcommands:
  init              Create a default .secure-keys.yml configuration file
  list              List all configured environments
  generate [name]   Generate an xcframework for the given environment
  diff <a> <b>      Compare two configured environments
```

#### `env init`

```bash
secure-keys env init
```

Creates `.secure-keys.yml` in the current directory from a default template. Exits with code 1 if the file already exists.

#### `env list`

```bash
secure-keys env list
```

Prints all environment names defined in `.secure-keys.yml`.

#### `env generate`

```bash
# Generate for a specific environment
secure-keys env generate development
secure-keys env generate staging
secure-keys env generate production

# Generate for all configured environments at once
secure-keys env generate --all
```

Each environment's xcframework is written to its configured `output` directory. Running `--all` generates one xcframework per environment without overwriting outputs from previous environments.

```text
Usage: secure-keys env generate [name] [--options]

    -h, --help    Show help for the env generate subcommand
        --all     Generate xcframeworks for all configured environments (default: false)
```

#### `env diff`

```bash
secure-keys env diff development production
```

Compares two environments and reports differences in their configuration and key lists. Useful before a release to confirm that staging and production are in sync.

```text
Comparing: development → production
──────────────────────────────────────────────────────────────────────
    Configuration: identical

    Keys (development: 3, production: 2):
        ✓ apiKey
        ✓ analyticsKey
        − debugToken (only in development)
──────────────────────────────────────────────────────────────────────
```

### Output structure

Each `generate` call writes its xcframework to the `output` path defined for that environment:

```text
.secure-keys/
├── development/
│   └── SecureKeys.xcframework
├── staging/
│   └── SecureKeys.xcframework
└── production/
    └── SecureKeys.xcframework
```

Link the appropriate xcframework in Xcode under **General → Frameworks, Libraries, and Embedded Content**. Use one Xcode scheme per environment, each pointing to the matching `.secure-keys/<environment>/SecureKeys.xcframework`.

Add `.secure-keys/` to `.gitignore` to avoid committing generated xcframeworks:

```gitignore
.secure-keys/
```

## Xcode Integration

Generate the framework only:

```bash
secure-keys
```

Generate and add the framework to an Xcode target:

```bash
secure-keys --xcframework --target "YourTargetName" --add
```

Replace an existing framework reference:

```bash
secure-keys --xcframework --target "YourTargetName" --replace
```

Add an already generated framework without rebuilding:

```bash
secure-keys --no-generate --xcframework --target "YourTargetName"
```

Select a project explicitly:

```bash
secure-keys --xcframework --target "YourTargetName" --xcodeproj "/path/to/YourProject.xcodeproj"
```

The same options can be configured with environment variables:

```bash
export SECURE_KEYS_XCFRAMEWORK_TARGET="YourTargetName"
export SECURE_KEYS_XCFRAMEWORK_ADD=true
export SECURE_KEYS_XCFRAMEWORK_REPLACE=false
export SECURE_KEYS_XCFRAMEWORK_XCODEPROJ="/path/to/YourProject.xcodeproj"

secure-keys --xcframework
```

Short environment variable names are also supported:

```bash
export XCFRAMEWORK_TARGET="YourTargetName"
export XCFRAMEWORK_ADD=true
export XCFRAMEWORK_REPLACE=false
export XCFRAMEWORK_XCODEPROJ="/path/to/YourProject.xcodeproj"
```

### Manual Xcode Setup

If you do not use `--xcframework`, add the framework manually:

1. Open the Xcode project target.
2. Open `General`.
3. Add `.secure-keys/SecureKeys.xcframework` to `Frameworks, Libraries, and Embedded Content`.
4. Open `Build Settings`.
5. Add `$(SRCROOT)/.secure-keys` to `Framework Search Paths`.

## Swift API

The generated framework exposes `SecureKey`, `key(for:)`, `key(_:)`, and a `String.secretKey` helper.

```swift
import SecureKeys

let apiKey = SecureKey.apiKey.decryptedValue
let githubToken = key(for: .githubToken)
let sameGithubToken = key(.githubToken)
let keyFromString: SecureKey = "apiKey".secretKey
let valueFromString = "apiKey".secretKey.decryptedValue
let staticValue = String.key(for: .apiKey)
```

Generated key names are camelized for Swift enum cases:

```text
api-key      -> SecureKey.apiKey
githubToken  -> SecureKey.githubToken
```

## Output Files

The main output is:

```text
.secure-keys/SecureKeys.xcframework
```

Temporary Swift package and build files are created under `.secure-keys` during generation and removed after the framework is built.

## Security Notes

- Do not commit `.secure-keys/SecureKeys.xcframework` unless your release process intentionally requires it.
- Do not commit `.env` files or raw secret values.
- Treat app-bundled secrets as obfuscation, not as a perfect security boundary. A determined attacker can inspect a shipped app binary.
- Prefer server-side secret usage for highly sensitive credentials.
- Use environment-specific keys for development, staging, and production.
- Rotate keys regularly and revoke leaked credentials immediately.

## Secret Scanning and Validation

`secure-keys` ships both a CLI and a Ruby API for validating individual secret values and scanning source files or git diffs for accidentally exposed credentials.

### CLI

Scan the current directory:

```bash
secure-keys validate scan
```

Scan a specific path:

```bash
secure-keys validate scan ./src
```

Scan only staged git changes (useful as a pre-commit hook):

```bash
secure-keys validate scan --staged
```

Save the report as JSON:

```bash
secure-keys validate scan --output report.json
```

Override the file extensions and exclusions:

```bash
secure-keys validate scan --extensions .rb,.swift,.go --excludes vendor,tmp,build
```

Enable verbose output:

```bash
secure-keys validate scan --verbose
```

Full option reference:

```text
Usage: secure-keys validate scan [path] [--options]

    -h, --help          Show help for the scan subcommand
        --staged        Scan staged git changes instead of a directory (default: false)
    -o, --output FILE   Save the scan report as JSON to FILE
        --extensions    Comma-separated file extensions to scan (e.g. .rb,.swift)
        --excludes      Comma-separated directory names to exclude from the scan
        --verbose       Enable verbose output (default: false)
```

Exit codes:

| Code | Meaning |
|---|---|
| `0` | Scan completed with no findings |
| `1` | One or more secrets were detected |

Validate a single secret value:

```bash
secure-keys validate key apiKey "your-secret-value"
```

Check entropy in addition to the standard rules:

```bash
secure-keys validate key apiKey "your-secret-value" --check-entropy
```

Emit an informational notice when a known provider pattern matches (useful for auditing non-production keys):

```bash
secure-keys validate key githubToken "ghp_abc123..." --warn-on-pattern
```

Skip the production key warning for live credentials you intentionally want to validate:

```bash
secure-keys validate key stripeKey "sk_live_abc..." --allow-production
```

Full option reference:

```text
Usage: secure-keys validate key <name> <value> [--options]

    -h, --help              Show help for the validate key subcommand
        --check-entropy     Flag values with low Shannon entropy (default: false)
        --allow-production  Skip the production key warning (default: false)
        --warn-on-pattern   Show an info notice when a known pattern matches (default: false)
        --verbose           Enable verbose output (default: false)
```

Exit codes:

| Code | Meaning |
|---|---|
| `0` | Value passed validation (no errors or critical issues) |
| `1` | Validation failed, or `<name>`/`<value>` was not provided |

### Validating a Secret

`SecureKeys::Validation::Validator` checks a single value against a set of security rules and returns a `ValidationResult`.

```ruby
require 'validation/validator'

validator = SecureKeys::Validation::Validator.new
result    = validator.validate(key: :api_key, value: ENV['API_KEY'])

puts result.summary          # ✅ api_key — no issues  /  ❌ api_key — 2 issue(s)
puts result.valid?           # true / false
puts result.severity_level   # :ok | :warning | :error | :critical
result.print                 # formatted report to stdout
```

Available validation options:

| Option | Type | Default | Description |
|---|---|---|---|
| `check_entropy` | Boolean | `false` | Flag low-entropy (repetitive) values |
| `allow_production` | Boolean | `false` | Skip the production-key warning |
| `warn_on_pattern` | Boolean | `false` | Emit an informational notice when a pattern matches |

```ruby
result = validator.validate(
  key: :stripe_key,
  value: ENV['STRIPE_KEY'],
  options: { check_entropy: true, warn_on_pattern: true }
)
```

Detect the type of a secret value:

```ruby
info = validator.detect_type(value: 'ghp_abc...')
# => { type: :github_token, description: "GitHub Personal Access Token", severity: :high, ... }
```

Get provider-specific security recommendations:

```ruby
validator.recommendations(key: :githubToken)
# => ["Use GitHub Personal Access Tokens with minimal required scopes", ...]
```

### Scanning Files for Exposed Secrets

`SecureKeys::Validation::Scanner` scans source files or git diffs for credentials that match any of the 25+ built-in patterns.

Scan a directory:

```ruby
require 'validation/scanner'

scanner = SecureKeys::Validation::Scanner.new
result  = scanner.scan_directory(path: '.')

puts result.clean?        # true if no findings
puts result.files_count   # number of files scanned

result.findings.each { |f| puts f.to_s }
result.print if !result.clean?
```

Scan only staged git changes (useful in a pre-commit hook):

```ruby
result = scanner.scan_git_diff                    # staged only (default)
result = scanner.scan_git_diff(staged_only: false) # staged + unstaged
```

Customize the scan at initialization or per call:

```ruby
scanner = SecureKeys::Validation::Scanner.new(
  options: {
    extensions: ['.rb', '.swift', '.go'],
    excludes:   ['vendor', 'node_modules', '.git'],
    max_depth:  5
  }
)
```

Filter findings by severity:

```ruby
result.by_severity(severity: :critical).each { |f| puts f.to_s }
```

### Detected Patterns

The scanner recognizes the following secret types out of the box:

| Pattern | Severity |
|---|---|
| GitHub personal / OAuth / App / refresh token | high |
| AWS access key ID | critical |
| AWS secret access key | critical |
| Google Cloud API key | high |
| Google OAuth token | high |
| Stripe secret key (live / test) | critical |
| Stripe publishable / restricted key | medium / high |
| Slack bot / app / webhook token | high / medium |
| JWT token | medium |
| PEM / RSA / EC / OpenSSH private key | critical |
| Generic API key assignment | medium |
| Generic secret / password assignment | medium |
| Firebase API key | medium |
| Twilio API key / Account SID | high / low |
| SendGrid API key | high |
| Mailchimp API key | medium |
| Square access token | high |
| PayPal Braintree access token | critical |
| Heroku API key | high |
| Base64-encoded secret | low |
| Suspicious assignment (catch-all) | low |

### Validation Configuration

All thresholds can be overridden with environment variables. Both the bare name and the `SECURE_KEYS_` prefix are supported.

| Environment variable | Default | Description |
|---|---|---|
| `SECURE_KEYS_API_KEY_LENGTH` | `20` | Minimum API key length |
| `SECURE_KEYS_TOKEN_LENGTH` | `20` | Minimum token length |
| `SECURE_KEYS_SECRET_LENGTH` | `16` | Minimum secret length |
| `SECURE_KEYS_PASSWORD_LENGTH` | `12` | Minimum password length |
| `SECURE_KEYS_KEY_LENGTH` | `16` | Minimum generic key length |
| `SECURE_KEYS_SCAN_EXTENSIONS` | `.swift,.rb,.py,.js,...` | Comma-separated file extensions to scan |
| `SECURE_KEYS_SCAN_EXCLUDES` | `.git,node_modules,Pods,...` | Comma-separated names to exclude |
| `SECURE_KEYS_MAX_SCAN_DEPTH` | `10` | Maximum directory traversal depth |
| `SECURE_KEYS_MIN_ENTROPY_THRESHOLD` | `3.0` | Shannon entropy threshold for `check_entropy` |

## Troubleshooting

`Error fetching the key from Keychain`

Verify the Keychain service, account, and identifier values. For the default configuration, the list must be stored with account `secure-keys` and service `secure-keys`.

`Error fetching the key from ENV variables`

Verify CI mode is enabled and that each configured key has a matching environment variable. For example, `github-token` maps to `GITHUB_TOKEN`.

`xcodebuild` fails

Verify Xcode command line tools are installed and selected:

```bash
xcode-select -p
```

`SecureKeys.xcframework` is not found by Xcode

Verify `$(SRCROOT)/.secure-keys` is present in `Framework Search Paths` and that the framework is attached to the correct target.

## Development

Install dependencies:

```bash
bundle install
```

Run the test suite:

```bash
bundle exec rspec
```

Run the local CLI:

```bash
bundle exec ./bin/secure-keys --help
```

## License

This project is licensed under the MIT [License](../LICENSE).
