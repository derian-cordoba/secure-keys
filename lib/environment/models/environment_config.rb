#!/usr/bin/env ruby

module SecureKeys
  module Environment
    # Represents the configuration for a single named environment
    class EnvironmentConfig
      # @return [String] The environment name (e.g. "development", "production")
      attr_reader :name

      # @return [String] The Keychain service / ENV identifier used to fetch the key list
      attr_reader :identifier

      # @return [String] The delimiter used to split the key list (default: ",")
      attr_reader :delimiter

      # @return [String] Where secrets are read from: "keychain" or "environment"
      attr_reader :source

      # @return [Array<String>] The list of secret key names for this environment
      attr_reader :keys

      # @return [String] The output directory for the generated xcframework
      attr_reader :output

      # Build an EnvironmentConfig from a raw YAML hash entry
      # @param name [String] The environment name
      # @param data [Hash] The raw YAML hash for this environment
      # @return [EnvironmentConfig]
      def self.from_hash(name:, data:)
        new(
          name:,
          identifier: data['identifier'] || "secure-keys-#{name}",
          delimiter: data['delimiter'] || ',',
          source: data['source'] || 'keychain',
          keys: data['keys'] || [],
          output: data['output'] || ".secure-keys/#{name}"
        )
      end

      # @param name [String] The environment name
      # @param identifier [String] The Keychain / ENV identifier for the key list
      # @param delimiter [String] The key-list delimiter
      # @param source [String] "keychain" or "environment"
      # @param keys [Array<String>] The secret key names
      # @param output [String] The xcframework output directory
      def initialize(name:, identifier:, delimiter: ',', source: 'keychain', keys: [], output: nil)
        @name = name.to_s
        @identifier = identifier
        @delimiter = delimiter
        @source = source
        @keys = keys
        @output = output || ".secure-keys/#{name}"
      end

      # Returns true when secrets should be read from environment variables (CI mode)
      # @return [Boolean]
      def ci_mode?
        @source == 'environment'
      end

      # Returns a hash representation of the configuration
      # @return [Hash]
      def to_h
        {
          name:,
          identifier:,
          delimiter:,
          source:,
          keys:,
          output:,
        }
      end
    end
  end
end
