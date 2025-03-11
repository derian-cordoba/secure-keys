# SwiftUIApp + Backend project

> [!WARNING]
> For this fixture, the secrets are printed in the console for demonstration purposes. In a real-world scenario, you should never print secrets in the console, logs, or any other output.

This fixture contains a SwiftUI app that consumes the `SecureKeys` xcframework to securely store and retrieve secrets.

Also included is a backend project that provides an API for user authentication and retrieving super secrets, simulating a real-world scenario where the entire team works with a Secret Manager like `1Password`, `LastPass`, or `AWS Secrets Manager`.

## Setup

In the root project exists a `setup` script that will install the secret keys in the Keychain.

To run the script, execute the following command:

```bash
./setup
```

> [!IMPORTANT]
> If you're running with `CI`, the secrets will not be installed in the Keychain. You must manually export the secrets as environment variables.

Later, you can generate the `SecureKeys` xcframework by running the following command:

```bash
# Running in the root project directory
secure-keys \
  --xcframework \
  --target "SwiftUIApp" \
  --xcodeproj "fixtures/SwiftUIApp+Backend/client/SwiftUIApp.xcodeproj"
```

> [!NOTE]
> You can skip the `--xcodeproj` argument if you're running the command in the same directory as the Xcode project.

Now, you can open the `SwiftUIApp.xcodeproj` and run the project.

![SwiftUIApp](/fixtures/SwiftUIApp+Backend/docs/assets/swiftui-secure-keys.png)
