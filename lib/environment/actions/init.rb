#!/usr/bin/env ruby

require_relative '../config'
require_relative '../../core/console/logger'

module SecureKeys
  module Environment
    module Actions
      # Creates the default .secure-keys.yml configuration file in the current directory
      class Init
        # Run the init action
        # @return [void]
        def run
          path = Config::CONFIG_FILE

          if File.exist?(path)
            Core::Console::Logger.error(message: "#{path} already exists — remove it first or edit it manually")
            exit(1)
          end

          Config.create_default(path:)

          Core::Console::Logger.success(message: "Created #{path}")
          Core::Console::Logger.message(message: '')
          Core::Console::Logger.message(message: 'Next steps:')
          Core::Console::Logger.message(message: "\t1. Edit #{path} to configure your environments")
          Core::Console::Logger.message(message: "\t2. Run 'secure-keys env list' to verify the configuration")
          Core::Console::Logger.message(message: "\t3. Run 'secure-keys env generate <environment>' to generate a framework")
          exit(0)
        end
      end
    end
  end
end
