#!/usr/bin/env ruby

require_relative '../console/arguments/key/handler'
require_relative '../../core/console/logger'
require_relative '../validator'

module SecureKeys
  module Validation
    module Actions
      # Executes the `validate key` action: validates a single secret value, prints
      # a formatted report to the console, and exits with an appropriate code
      # (0 = valid, 1 = invalid or missing arguments).
      class Key
        # Run the validation, print the report, and exit
        # @return [void]
        def run
          name  = Console::Argument::Key::Handler.fetch(key: :name)
          value = Console::Argument::Key::Handler.fetch(key: :value)

          unless name && value
            Core::Console::Logger.error(message: 'Both <name> and <value> are required')
            Core::Console::Logger.message(message: 'Usage: secure-keys validate key <name> <value> [--options]')
            exit(1)
          end

          result = validate(name:, value:)
          result.print
          print_recommendations(name:)
          exit(result.valid? ? 0 : 1)
        end

        private

        # Build the options hash from CLI arguments
        # @return [Hash] Validation options for Validator#validate
        def validator_options
          {
            check_entropy: Console::Argument::Key::Handler.fetch(key: :check_entropy, default: false),
            allow_production: Console::Argument::Key::Handler.fetch(key: :allow_production, default: false),
            warn_on_pattern: Console::Argument::Key::Handler.fetch(key: :warn_on_pattern, default: false),
          }
        end

        # Run the validator against the provided name/value pair
        # @param name [String] The secret key name
        # @param value [String] The secret value
        # @return [ValidationResult]
        def validate(name:, value:)
          Validator.new.validate(key: name.to_sym, value:, options: validator_options)
        end

        # Print provider-specific security recommendations for the given key name
        # @param name [String] The secret key name
        # @return [void]
        def print_recommendations(name:)
          recommendations = Validator.new.recommendations(key: name.to_sym)
          return if recommendations.empty?

          Core::Console::Logger.message(message: "\nRecommendations:")
          recommendations.each { |recommendation| Core::Console::Logger.message(message: "\t💡 #{recommendation}") }
        end
      end
    end
  end
end
