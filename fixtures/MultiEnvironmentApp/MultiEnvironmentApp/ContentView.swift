//
//  ContentView.swift
//  MultiEnvironmentApp
//
//  Demonstrates reading secrets from the SecureKeys xcframework.
//  The framework is generated per-environment by secure-keys; the key names
//  remain constant across environments — only their encrypted values differ.
//
//  WARNING: Never print secrets in a production build. The prints below exist
//  solely for local verification during development.
//

import SwiftUI
import SecureKeys

struct ContentView: View {

    // MARK: - Initialization

    init() {
        // These key names map directly to the keys listed in .secure-keys.yml.
        // In production builds, consume the values in your network layer or
        // configuration objects — never display or log them.
        #if DEBUG
        print("[SecureKeys] apiKey       : \(key(for: .apiKey))")
        print("[SecureKeys] analyticsKey : \(key(for: .analyticsKey))")
        #endif
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Text("MultiEnvironmentApp")
                .font(.title2)
                .bold()

            Text("Secrets loaded from SecureKeys xcframework.\nCheck the Xcode console for debug output.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
