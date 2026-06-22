#!/usr/bin/env ruby

require 'yaml'
require_relative 'models/environment_config'

module SecureKeys
  module Environment
    # Loads and exposes environment configurations from a YAML file.
    # The default configuration file is +.secure-keys.yml+ in the current directory.
    class Config
      # The default configuration file path
      CONFIG_FILE = '.secure-keys.yml'.freeze

      # Default YAML template written by +Config.create_default+
      DEFAULT_YAML = <<~YAML.freeze
        environments:
          development:
            identifier: secure-keys-dev
            delimiter: ","
            source: keychain
            keys:
              - apiKey
              - debugToken
            output: .secure-keys/development

          staging:
            identifier: secure-keys-staging
            delimiter: ","
            source: environment
            keys:
              - apiKey
              - analyticsKey
            output: .secure-keys/staging

          production:
            identifier: secure-keys-prod
            delimiter: ","
            source: environment
            keys:
              - apiKey
              - analyticsKey
            output: .secure-keys/production
      YAML

      # Write the default configuration file to disk
      # @param path [String] The path to write the file to (default: CONFIG_FILE)
      # @return [String] The path of the written file
      def self.create_default(path: CONFIG_FILE)
        File.write(path, DEFAULT_YAML)
        path
      end

      # Load a configuration file
      # @param path [String] The YAML file path (default: CONFIG_FILE)
      def initialize(path: CONFIG_FILE)
        @path = path
        @environments = {}
        load!
      end

      # Returns all loaded environment configurations keyed by name
      # @return [Hash{String => EnvironmentConfig}]
      attr_reader :environments

      # The path of the loaded configuration file
      # @return [String]
      attr_reader :path

      # Returns the names of all configured environments
      # @return [Array<String>]
      def environment_names
        @environments.keys
      end

      # Fetches an environment configuration by name
      # @param name [String] The environment name
      # @return [EnvironmentConfig]
      # @raise [Error] when the environment is not found
      def get(name:)
        config = @environments[name.to_s]
        raise(Error, "Environment '#{name}' not found in #{@path}") unless config

        config
      end

      # Returns true when the configuration file exists on disk
      # @return [Boolean]
      def exists?
        File.exist?(@path)
      end

      private

      # Parse the YAML file and populate @environments
      # @return [void]
      def load!
        return unless File.exist?(@path)

        raw  = File.read(@path)
        data = YAML.safe_load(raw, permitted_classes: [], permitted_symbols: [], aliases: false) || {}
        return unless data.is_a?(Hash) && data['environments'].is_a?(Hash)

        data['environments'].each do |name, env_data|
          @environments[name.to_s] = EnvironmentConfig.from_hash(name:, data: env_data || {})
        end
      end
    end

    # Raised when an environment operation fails
    class Error < StandardError; end
  end
end
