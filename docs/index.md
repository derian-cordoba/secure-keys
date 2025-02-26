# Secure Key Generator for iOS Projects

A utility to securely generate and manage keys for iOS projects using `xcframework`. This tool helps to safely store and retrieve sensitive keys such as API tokens and access credentials in your iOS app, with support for both local and CI environments.

## Prerequisites

Before you begin, ensure that your development environment meets the following prerequisites:

- **Ruby 3.3.6 or higher**
- **iOS 13.0 or higher**

## Installation

There are multiple ways to install the `SecureKeys` utility:

### Option 1: Install via Homebrew

You can install the `SecureKeys` utility using [Homebrew](https://brew.sh/) with the following commands:

```bash
brew tap derian-cordoba/secure-keys

brew install derian-cordoba/secure-keys/secure-keys
```

For more details, you can visit the [homebrew-secure-keys](https://github.com/derian-cordoba/homebrew-secure-keys) repository.

### Option 2: Install via RubyGems

Alternatively, you can install the utility using RubyGems:

```bash
gem install secure-keys
```

### Option 3: Install via Bundler

If you're using Bundler to manage your Ruby dependencies, add the gem to your `Gemfile`:

```bash
gem 'secure-keys'
```

Then, run:

```bash
bundle install
```

For more details, you can visit the [homebrew-secure-keys](https://github.com/derian-cordoba/homebrew-secure-keys) repository.

## Usage

### Step 1: Define Your Keys

First, determine the keys you want to use in your iOS project. The keys can be sourced either from your Keychain or environment variables. The source of keys is determined by the `CI` environment variable.

- If `CI=true`, keys will be read from environment variables.
- If `CI=false` or not set, keys will be read from the Keychain.

You can configure your keys as follows:

#### From Keychain

1. Define the secure-keys record in your Keychain with the key names and values. The value should be a comma-separated list of keys.

```bash
security add-generic-password -a "secure-keys" -s "secure-keys" -w "githubToken,apiKey"
```

If you need to use a custom Keychain identifier, set the `SECURE_KEYS_IDENTIFIER` environment variable:

```bash
export SECURE_KEYS_IDENTIFIER="your-keychain-identifier"

security add-generic-password -a "$SECURE_KEYS_IDENTIFIER" -s "$SECURE_KEYS_IDENTIFIER" -w "githubToken,apiKey"
```

2. Add new keys to the Keychain as needed:

```bash
security add-generic-password -a "secure-keys" -s "apiKey" -w "your-api-key"
```

Or with a custom Keychain identifier:

```bash
security add-generic-password -a "$SECURE_KEYS_IDENTIFIER" -s "apiKey" -w "your-api-key"
```

#### From Environment Variables

You can define the keys in the `.env` file or export the keys as environment variables.

```bash
export SECURE_KEYS_IDENTIFIER="github-token,api_key,firebaseToken"
export GITHUB_TOKEN="your-github-token"
export API_KEY="your-api-key"
export FIREBASETOKEN="your-firebase-token"
```

> Important: Key names should be formatted in uppercase with `-` replaced by `_` (e.g., `github-token` becomes `GITHUB_TOKEN`).

##### Custom Delimiter

If you prefer a delimiter other than the default comma, you can set a custom delimiter using the `SECURE_KEYS_DELIMITER` environment variable:

```bash
export SECURE_KEYS_DELIMITER="|"
export SECURE_KEYS_IDENTIFIER="github-token|api_key|firebaseToken"
```

### Step 2: Generate the SecureKeys.xcframework

After configuring your keys, generate the `SecureKeys.xcframework` by running the following command in your iOS project root directory:

```bash
secure-keys
```

Using Bundler:

```bash
bundle exec secure-keys
```

To get more information about the command, you can use the `--help` option.

```bash
secure-keys --help

# Output

Usage: secure-keys [--options]

    -h, --help                                  Use the provided commands to select the params
        --add-xcframework-to-target TARGET      Add the xcframework to the target
    -d, --delimiter DELIMITER                   The delimiter to use for the key access (default: ",")
    -i, --identifier IDENTIFIER                 The identifier to use for the key access (default: "secure-keys")
        --verbose                               Enable verbose mode (default: false)
    -v, --version                               Show the secure-keys version
    -x, --xcodeproj XCODEPROJ                   The Xcode project path (default: the first found Xcode project)
```

To avoid defining the `SECURE_KEYS_IDENTIFIER` and `SECURE_KEYS_DELIMITER` env variables, you can use the `--identifier` and `--delimiter` options.

```bash
secure-keys --identifier "your-keychain-or-env-variable-identifier" --delimiter "|"
```

Also, you can use the short options:

```bash
secure-keys -i "your-keychain-or-env-variable-identifier" -d "|"
```

### Step 3: Integrate SecureKeys.xcframework into Your iOS Project

#### Automatically

From the `secure-keys` command, you can use the `--add-xcframework-to-target` option to add the `SecureKeys.xcframework` to the iOS project.

```bash
secure-keys --add-xcframework-to-target "YourTargetName"
```

Also, you can specify your Xcode project path using the `--xcodeproj` option.

```bash
secure-keys --add-xcframework-to-target "YourTargetName" --xcodeproj "/path/to/your/project.xcodeproj"
```

> [!IMPORTANT]
> By default, the xcodeproj path would be the first found Xcode project.

This command will generate the `SecureKeys.xcframework` and add it to the iOS project.

#### Manually

1. From the iOS project, click on the project target, select the `General` tab, and scroll down to the `Frameworks, Libraries, and Embedded Content` section.

![Project Target](https://derian-cordoba.github.io/secure-keys/assets/add-xcframework-to-ios-project/first-step.png)

2. Click on the `Add Other...` button and click on the `Add Files...` option.

![Add Files](https://derian-cordoba.github.io/secure-keys/assets/add-xcframework-to-ios-project/second-step.png)

3. Navigate to the `Securekeys` directory and select the `SecureKeys.xcframework` folder.

![Select SecureKeys.xcframework](https://derian-cordoba.github.io/secure-keys/assets/add-xcframework-to-ios-project/third-step.png)

> Now the `SecureKeys.xcframework` is added to the iOS project.

![Select SecureKeys.xcframework](https://derian-cordoba.github.io/secure-keys/assets/add-xcframework-to-ios-project/third-step-result.png)

4. Click on the `Build settings` tab and search for the `Search Paths` section.

![Search Paths](https://derian-cordoba.github.io/secure-keys/assets/add-xcframework-to-ios-project/fourth-step.png)

> Add the path to the `SecureKeys.xcframework` in the `Framework Search Paths` section.

```bash
$(inherited)
$(SRCROOT)/.secure-keys
```

### Step 4: Use the Keys in Your Code

In your iOS code, you can now use the Keys framework to securely retrieve your keys:

```swift
import SecureKeys

// Using the key directly
let apiKey = SecureKey.apiKey.decryptedValue

// Accessing a key by enum case
let someKey: String = key(for: .someKey)

// Another way to access the key
let someKey: String = key(.someKey)

// Using the raw value to access the key
let apiKey: SecureKey = "apiKey".secretKey

// Accessing decrypted value from the raw key
let apiKey: String = "apiKey".secretKey.decryptedValue

// Using the `key` method to retrieve the key
let apiKey: String = .key(for: .apiKey)
```

## How It Works

When the script is executed, it follows these steps:

1. A `.secure-keys` directory is created.
2. A temporary Swift Package is generated within the `.secure-keys` directory.
3. The Keys source code is copied into the temporary Swift Package.
4. The `SecureKeys.xcframework` is generated using the temporary Swift Package.
5. The temporary Swift Package is removed.

```swift
public enum SecureKey {

    // MARK: - Cases

    case apiKey
    case someKey
    case unknown

    // MARK: - Properties

    /// The decrypted value of the key
    public var decryptedValue: String {
        switch self {
            case .apiKey: [1, 2, 4].decrypt(key: [248, 53, 26], iv: [148, 55, 47], tag: [119, 81])
            case .someKey: [1, 2, 4].decrypt(key: [248, 53, 26], iv: [148, 55, 47], tag: [119, 81])
            case .unknown: fatalError("Unknown key \(rawValue)")
        }
    }
}
```

## License

This project is licensed under the MIT License. See the [License](LICENSE) file for more information.
