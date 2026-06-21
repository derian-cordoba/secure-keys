#!/usr/bin/env ruby

require_relative '../../services/environment'

module SecureKeys
  module Validation
    module Globals
      module_function

      # Returns the minimum length for an API key
      # @return [Integer] The minimum length for an API key
      def api_key_length
        Services::Environment.integer(key: :api_key_length, default: 20)
      end

      # Returns the minimum length for a token
      # @return [Integer] The minimum length for a token
      def token_length
        Services::Environment.integer(key: :token_length, default: 20)
      end

      # Returns the minimum length for a secret
      # @return [Integer] The minimum length for a secret
      def secret_length
        Services::Environment.integer(key: :secret_length, default: 16)
      end

      # Returns the minimum length for a password
      # @return [Integer] The minimum length for a password
      def password_length
        Services::Environment.integer(key: :password_length, default: 12)
      end

      # Returns the minimum length for a generic key
      # @return [Integer] The minimum length for a key
      def key_length
        Services::Environment.integer(key: :key_length, default: 16)
      end

      # Returns the default file extensions to scan
      # @return [Array<String>] The default file extensions
      def default_scan_extensions
        Services::Environment.fetch(
          key: :scan_extensions,
          default: '.swift,.m,.mm,.h,.rb,.py,.js,.ts,.java,.kt,.yaml,.yml,.json,.env,.plist'
        ).split(',')
      end

      # Returns the default directory and file names to exclude from scanning
      # @return [Array<String>] The default exclude patterns
      def default_scan_excludes
        Services::Environment.fetch(
          key: :scan_excludes,
          default: '.git,node_modules,Pods,build,DerivedData,.build,vendor,.bundle,Carthage,.secure-keys,coverage'
        ).split(',')
      end

      # Returns the maximum directory traversal depth for scanning
      # @return [Integer] The maximum scan depth
      def max_scan_depth
        Services::Environment.integer(key: :max_scan_depth, default: 10)
      end

      # Returns the minimum Shannon entropy threshold for secret validation
      # @return [Float] The minimum entropy threshold
      def min_entropy_threshold
        Services::Environment.decimal(key: :min_entropy_threshold, default: 3.0)
      end
    end
  end
end
