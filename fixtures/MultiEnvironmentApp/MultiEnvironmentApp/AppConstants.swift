//
//  AppConstants.swift
//  MultiEnvironmentApp
//
//  Centralises access to secrets so the rest of the app never imports
//  SecureKeys directly — only this file does.
//
//  Usage:
//      let url = AppConstants.apiBaseURL
//

import Foundation
import SecureKeys

enum AppConstants {

    // MARK: - API

    /// Base URL built from the environment-specific API key.
    /// Replace the placeholder host with your real backend URL.
    static var apiBaseURL: URL {
        URL(string: "https://api.example.com")!
    }

    /// Raw API key — use only in secure network requests, never log it.
    static var apiKey: String {
        key(for: .apiKey)
    }

    // MARK: - Analytics

    /// Analytics write key — passed to your analytics SDK initializer.
    static var analyticsKey: String {
        key(for: .analyticsKey)
    }

    // MARK: - Development only

    #if DEBUG
    /// Debug token available in the development environment only.
    /// Not present in staging or production `.secure-keys.yml`.
    static var debugToken: String {
        key(for: .debugToken)
    }

    /// Feature-flag service key — available in development and staging.
    static var featureFlagKey: String {
        key(for: .featureFlagKey)
    }
    #endif
}
