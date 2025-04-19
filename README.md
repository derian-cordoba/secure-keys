<div style="display: flex; gap: 10px; padding-bottom: 20px;">
  <img src="https://img.shields.io/badge/version-1.1.5-cyan" alt="SecureKeys version">

  <img src="https://img.shields.io/badge/iOS-^13.0-blue" alt="iOS version 13.0">

  <img src="https://img.shields.io/badge/Ruby-^3.3.6-red" alt="Ruby version 3.3.6">

</div>

# Secure Key Generator for iOS projects

Utility to generate a `xcframework` for handling secure keys in iOS projects.

### Prerequisites

- Ruby 3.3.6 or higher
- iOS 13.0 or higher
- macOS 11.0 or higher

### Installation

You can install the `SecureKeys` utility using Homebrew using the following command:

```bash
brew tap derian-cordoba/secure-keys

brew install derian-cordoba/secure-keys/secure-keys
```

For more details, you can visit the [homebrew-secure-keys](https://github.com/derian-cordoba/homebrew-secure-keys) repository.

Another way, you can install the `SecureKeys` utility using `gem` command:

```bash
gem install secure-keys
```

If you using `bundler` you can add the `secure-keys` gem to the `Gemfile`:

```ruby
gem 'secure-keys'
```

Then, you can install the gem using:

```bash
bundle install
```

For more information about the gem, you can visit the [secure-keys](https://rubygems.org/gems/secure-keys) page.

## Usage

As first step, you need to determine the keys that you want to use in your iOS project. You can define the keys from Keychain or env variables.

The source is determined by the current platform **local or CI / cloud** using the `CI` environment variable.

If the `CI` environment variable is set to `true`, the keys are read from the environment variables. Otherwise, the keys are read from the Keychain.

You can configure your keys like this:

### From Keychain

1. You need to define the `secure-keys` record in the Keychain with the key name and the key value.

The value for this key should be all the key names separated by a comma.

```bash
security add-generic-password -a "secure-keys" -s "secure-keys" -w "githubToken,apiKey"
```

If you want to use another keychain identifier, you can define an env variable named `SECURE_KEYS_IDENTIFIER` to set the keychain identifier.

```bash
export SECURE_KEYS_IDENTIFIER="your-keychain-identifier"

security add-generic-password -a "$SECURE_KEYS_IDENTIFIER" -s "$SECURE_KEYS_IDENTIFIER" -w "githubToken,apiKey"
```

2. You can add new keys using the `security` command.

```bash
security add-generic-password -a "secure-keys" -s "apiKey" -w "your-api-key"
```

Using custom keychain identifier:

```bash
security add-generic-password -a "$SECURE_KEYS_IDENTIFIER" -s "apiKey" -w "your-api-key"
```

### Environment variables

1. You can define the keys in the `.env` file or export the keys as environment variables.

```bash
export SECURE_KEYS_IDENTIFIER="github-token,api_key,firebaseToken"

export GITHUB_TOKEN="your-github-token"
export API_KEY="your-api-key"
export FIREBASETOKEN="your-firebase-token"
```

> The key names are formatted in uppercase and replace the `-` with `_`.

> [!IMPORTANT]
> If you want to use another demiliter, you can define an env variable named `SECURE_KEYS_DELIMITER` to set the delimiter.

```bash
export SECURE_KEYS_DELIMITER="|"

export SECURE_KEYS_IDENTIFIER="github-token|api_key|firebaseToken"
```

### Ruby script

To generate the `SecureKeys.xcframework` use the `secure-keys` command in the iOS project root directory.

Using global gem:

```bash
secure-keys
```

Using bundler:

```bash
bundle exec secure-keys
```

To get more information about the command, you can use the `--help` option.

```bash
secure-keys --help

# Output

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

To avoid defining the `SECURE_KEYS_IDENTIFIER` and `SECURE_KEYS_DELIMITER` env variables, you can use the `--identifier` and `--delimiter` options.

```bash
secure-keys --identifier "your-keychain-or-env-variable-identifier" --delimiter "|"
```

Also, you can use the short options:

```bash
secure-keys -i "your-keychain-or-env-variable-identifier" -d "|"
```

### iOS project

Within the iOS project, you can use the `SecureKeys` target dependency like:

```swift
import SecureKeys

// Using key directly in the code
let apiKey = SecureKey.apiKey.decryptedValue

// Using key from `SecureKey` enum
let someKey: String = key(for: .someKey)

// Alternative way to use key from `SecureKey` enum
let someKey: String = key(.someKey)

// Using raw value from `SecureKey` enum
let apiKey: SecureKey = "apiKey".secretKey

// Using raw value from `SecureKey` enum with decrypted value
let apiKey: String = "apiKey".secretKey.decryptedValue

// Using `key` method to get the key
let apiKey: String = .key(for: .apiKey)
```

## How to install the `SecureKeys.xcframework` in the iOS project

### Automatically

> [!IMPORTANT]
> You can see more information about the command using the `--help` option.

```bash
secure-keys --xcframework --help

# Output
Usage: secure-keys --xcframework [--options]

    -h, --help                       Use the provided commands to select the params
        --[no-]add                   Add the SecureKeys XCFramework to the Xcode project (default: true)
    -t, --target TARGET              The target to add the xcframework
    -r, --replace                    Replace the existing xcframework in the Xcode project (default: false)
    -x, --xcodeproj XCODEPROJ        The Xcode project path (default: the first found Xcode project)
```

From the `secure-keys` command, you can use the `--xcframework` option to add the `SecureKeys.xcframework` to the iOS project.

```bash
secure-keys --xcframework --target "YourTargetName" --add
```

If you want to add the `SecureKeys.xcframework` to an iOS that already contains the `SecureKeys` source code, you can use the `--replace` option.

```bash
secure-keys --xcframework --target "YourTargetName" --replace
```

> [!IMPORTANT]
> If you don't need to generate the `SecureKeys.xcframework` every time, you can use the `--no-generate` option.

```bash
secure-keys --no-generate --xcframework --target "YourTargetName"
```

Also, you can specify your Xcode project path using the `--xcodeproj` option.

```bash
secure-keys --xcframework --target "YourTargetName" --xcodeproj "/path/to/your/project.xcodeproj"
```

> [!IMPORTANT]
> By default, the xcodeproj path would be the first found Xcode project.

If you don't want to use the CLI options, you can configure some env variable to interact with the `secure-keys` command.

```bash
# e.g (Large version)
export SECURE_KEYS_XCFRAMEWORK_TARGET="YourTargetName"
export SECURE_KEYS_XCFRAMEWORK_ADD=true
export SECURE_KEYS_XCFRAMEWORK_REPLACE=true
export SECURE_KEYS_XCFRAMEWORK_XCODEPROJ="/path/to/your/project.xcodeproj"

# e.g (Short version)
export XCFRAMEWORK_TARGET="YourTargetName"
export XCFRAMEWORK_ADD=true
export XCFRAMEWORK_REPLACE=true
export XCFRAMEWORK_XCODEPROJ="/path/to/your/project.xcodeproj"

# Run the command
secure-keys --xcframework
```

### Manually

1. From the iOS project, click on the project target, select the `General` tab, and scroll down to the `Frameworks, Libraries, and Embedded Content` section.

![Project Target](/docs/assets/add-xcframework-to-ios-project/first-step.png)

2. Click on the `Add Other...` button and click on the `Add Files...` option.

![Add Files](/docs/assets/add-xcframework-to-ios-project/second-step.png)

3. Navigate to the `keys` directory and select the `SecureKeys.xcframework` folder.

![Select SecureKeys.xcframework](/docs/assets/add-xcframework-to-ios-project/third-step.png)

> Now the `SecureKeys.xcframework` is added to the iOS project.

![Select SecureKeys.xcframework](/docs/assets/add-xcframework-to-ios-project/third-step-result.png)

4. Click on the `Build settings` tab and search for the `Search Paths` section.

![Search Paths](/docs/assets/add-xcframework-to-ios-project/fourth-step.png)

> Add the path to the `SecureKeys.xcframework` in the `Framework Search Paths` section.

```bash
$(inherited)
$(SRCROOT)/.secure-keys
```

## How it works

The process when the script is executed is:

1. Create a `.secure-keys` directory.
2. Create a temporary `Swift Package` in the `.secure-keys` directory.
3. Copy the `SecureKeys` source code to the temporary `Swift Package`.

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

4. Generate the `SecureKeys.xcframework` using the temporary `Swift Package`.
5. Remove the temporary `Swift Package`.

## License

This project is licensed under the MIT [License](LICENSE).
