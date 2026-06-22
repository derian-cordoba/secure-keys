#!/usr/bin/env ruby

require 'fileutils'
require_relative '../config'
require_relative '../console/arguments/generate/handler'
require_relative '../../core/console/arguments/handler'
require_relative '../../core/console/logger'
require_relative '../../core/generator'

module SecureKeys
  module Environment
    module Actions
      # Generates a SecureKeys.xcframework for one or all configured environments.
      # Overrides the core argument handler values with each environment's config before
      # delegating to Core::Generator so no changes to the generator itself are required.
      class Generate
        # Run the generate action
        # @return [void]
        def run
          config = load_config

          if all?
            generate_all(config:)
          else
            generate_one(config:)
          end
          exit(0)
        end

        private

        # Returns true when --all was passed
        # @return [Boolean]
        def all?
          Console::Argument::Generate::Handler.fetch(key: :all, default: false)
        end

        # Returns the environment name provided as a positional argument
        # @return [String, nil]
        def environment_name
          Console::Argument::Generate::Handler.fetch(key: :name)
        end

        # Generate for a single named environment
        # @param config [Config] The loaded environment configuration
        # @return [void]
        def generate_one(config:)
          name = environment_name

          unless name
            Core::Console::Logger.error(message: "Environment name is required — run 'secure-keys env generate <name>'")
            Core::Console::Logger.message(message: "Available environments: #{config.environment_names.join(', ')}")
            exit(1)
          end

          env = fetch_environment(config:, name:)
          generate_environment(env:)
        end

        # Generate for every configured environment in order
        # @param config [Config] The loaded environment configuration
        # @return [void]
        def generate_all(config:)
          Core::Console::Logger.important(message: "Generating all environments: #{config.environment_names.join(', ')}")

          config.environments.each_value do |env|
            generate_environment(env:)
          end
        end

        # Generate the xcframework for a single environment config
        # @param env [EnvironmentConfig] The environment to generate
        # @return [void]
        def generate_environment(env:)
          Core::Console::Logger.important(message: "Generating environment: #{env.name}")
          Core::Console::Logger.message(message: "\tIdentifier : #{env.identifier}")
          Core::Console::Logger.message(message: "\tSource     : #{env.source}")
          Core::Console::Logger.message(message: "\tKeys       : #{env.keys.join(', ')}")
          Core::Console::Logger.message(message: "\tOutput     : #{env.output}")

          apply_environment(env:)
          Core::Generator.new.generate
          place_xcframework(env:)
        end

        # Move the generated xcframework from the default path to the environment's
        # configured output directory so that each environment lands in its own folder
        # (e.g. .secure-keys/staging/SecureKeys.xcframework).
        # @param env [EnvironmentConfig] The environment whose output path should be used
        # @return [void]
        def place_xcframework(env:)
          default_path = File.join(SecureKeys::Swift::KEYS_DIRECTORY, SecureKeys::Swift::XCFRAMEWORK_DIRECTORY)
          target_path  = File.join(env.output, SecureKeys::Swift::XCFRAMEWORK_DIRECTORY)

          return if default_path == target_path
          return unless File.exist?(default_path)

          FileUtils.mkdir_p(env.output)
          FileUtils.mv(default_path, target_path)
        end

        # Override the core argument handler with environment-specific values so that
        # Core::Generator reads the correct identifier, delimiter, and CI flag
        # @param env [EnvironmentConfig] The environment whose values should be applied
        # @return [void]
        def apply_environment(env:)
          Core::Console::Argument::Handler.set(key: :identifier, value: env.identifier)
          Core::Console::Argument::Handler.set(key: :delimiter, value: env.delimiter)
          Core::Console::Argument::Handler.set(key: :ci, value: env.ci_mode?)
        end

        # Fetch an environment by name, printing available names and exiting on error
        # @param config [Config] The loaded environment configuration
        # @param name [String] The environment name to look up
        # @return [EnvironmentConfig]
        def fetch_environment(config:, name:)
          config.get(name:)
        rescue Environment::Error => e
          Core::Console::Logger.error(message: e.message)
          Core::Console::Logger.message(message: "Available environments: #{config.environment_names.join(', ')}")
          exit(1)
        end

        # Load the environment config, exiting with an error if the file is missing
        # @return [Config]
        def load_config
          config = Config.new

          unless config.exists?
            Core::Console::Logger.error(message: "#{Config::CONFIG_FILE} not found — run 'secure-keys env init' to create it")
            exit(1)
          end

          config
        end
      end
    end
  end
end
