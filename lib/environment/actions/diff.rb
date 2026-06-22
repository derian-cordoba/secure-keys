#!/usr/bin/env ruby

require_relative '../config'
require_relative '../../core/console/logger'

module SecureKeys
  module Environment
    module Actions
      # Compares two configured environments and prints their differences
      class Diff
        # @param name_a [String] The first environment name
        # @param name_b [String] The second environment name
        def initialize(name_a:, name_b:)
          @name_a = name_a
          @name_b = name_b
        end

        # Run the diff action
        # @return [void]
        def run
          config = load_config
          env_a = fetch_environment(config:, name: @name_a)
          env_b = fetch_environment(config:, name: @name_b)

          print_diff(env_a:, env_b:)
          exit(0)
        end

        private

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

        # Fetch an environment by name, exiting with an error if not found
        # @param config [Config] The loaded environment configuration
        # @param name [String] The environment name
        # @return [EnvironmentConfig]
        def fetch_environment(config:, name:)
          config.get(name:)
        rescue Environment::Error => e
          Core::Console::Logger.error(message: e.message)
          Core::Console::Logger.message(message: "Available environments: #{config.environment_names.join(', ')}")
          exit(1)
        end

        # Print a side-by-side diff of two environment configurations
        # @param env_a [EnvironmentConfig] The first environment
        # @param env_b [EnvironmentConfig] The second environment
        # @return [void]
        def print_diff(env_a:, env_b:)
          separator = '-' * 70

          Core::Console::Logger.message(message: '')
          Core::Console::Logger.message(message: "Comparing: #{env_a.name} → #{env_b.name}")
          Core::Console::Logger.message(message: separator)

          print_config_diff(env_a:, env_b:)
          print_key_diff(env_a:, env_b:)

          Core::Console::Logger.message(message: separator)
        end

        # Print configuration field differences (identifier, source, delimiter, output)
        # @param env_a [EnvironmentConfig] The first environment
        # @param env_b [EnvironmentConfig] The second environment
        # @return [void]
        def print_config_diff(env_a:, env_b:)
          fields = %i[identifier source delimiter output]
          changed = fields.reject { |f| env_a.send(f) == env_b.send(f) }

          if changed.empty?
            Core::Console::Logger.success(message: "\tConfiguration: identical")
          else
            Core::Console::Logger.message(message: "\tConfiguration differences:")
            changed.each do |field|
              Core::Console::Logger.warning(message: "\t  #{field}:")
              Core::Console::Logger.message(message: "\t    #{env_a.name}: #{env_a.send(field)}")
              Core::Console::Logger.message(message: "\t    #{env_b.name}: #{env_b.send(field)}")
            end
          end

          Core::Console::Logger.message(message: '')
        end

        # Print key list differences (only in a, only in b, shared)
        # @param env_a [EnvironmentConfig] The first environment
        # @param env_b [EnvironmentConfig] The second environment
        # @return [void]
        def print_key_diff(env_a:, env_b:)
          only_a = env_a.keys - env_b.keys
          only_b = env_b.keys - env_a.keys
          shared = env_a.keys & env_b.keys

          Core::Console::Logger.message(message: "\tKeys (#{env_a.name}: #{env_a.keys.length}, #{env_b.name}: #{env_b.keys.length}):")

          shared.each do |key|
            Core::Console::Logger.success(message: "\t\t✓ #{key}")
          end

          only_a.each do |key|
            Core::Console::Logger.warning(message: "\t\t− #{key} (only in #{env_a.name})")
          end

          only_b.each do |key|
            Core::Console::Logger.important(message: "\t\t+ #{key} (only in #{env_b.name})")
          end
        end
      end
    end
  end
end
