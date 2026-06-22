#!/usr/bin/env ruby

require_relative '../config'
require_relative '../../core/console/logger'

module SecureKeys
  module Environment
    module Actions
      # Prints all configured environments and their settings to the console
      class List
        # Run the list action
        # @return [void]
        def run
          config = load_config
          separator = '-' * 70

          Core::Console::Logger.message(message: '')
          Core::Console::Logger.message(message: 'Configured environments:')
          Core::Console::Logger.message(message: separator)

          config.environments.each_value do |env|
            print_environment(env:)
          end

          Core::Console::Logger.message(message: separator)
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

        # Print the details of a single environment
        # @param env [EnvironmentConfig] The environment to display
        # @return [void]
        def print_environment(env:)
          Core::Console::Logger.message(message: '')
          Core::Console::Logger.important(message: "\t#{env.name}")
          Core::Console::Logger.message(message: "\t  Identifier : #{env.identifier}")
          Core::Console::Logger.message(message: "\t  Source     : #{env.source}")
          Core::Console::Logger.message(message: "\t  Delimiter  : #{env.delimiter}")
          Core::Console::Logger.message(message: "\t  Keys       : #{env.keys.join(', ')}")
          Core::Console::Logger.message(message: "\t  Output     : #{env.output}")
        end
      end
    end
  end
end
