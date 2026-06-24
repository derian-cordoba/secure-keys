#!/usr/bin/env ruby

require 'optparse'
require_relative 'handler'
require_relative '../../../../core/console/arguments/handler'

module SecureKeys
  module Validation
    module Console
      module Argument
        module Key
          # Parses CLI options for the `secure-keys validate key` subcommand.
          # The two required positional arguments — name and value — are shifted
          # from ARGV after flag parsing so options may appear in any order.
          class Parser < OptionParser
            # Initialize the key parser, process ARGV, and store results in Handler
            def initialize
              super('Usage: secure-keys validate key <name> <value> [--options]')
              separator('')
              configure!
              parse!
              Handler.set(key: :name, value: ARGV.shift)
              Handler.set(key: :value, value: ARGV.shift)
            end

            private

            # Define all accepted options for the key subcommand
            # @return [void]
            def configure!
              on('-h', '--help', 'Show help for the validate key subcommand') do
                puts self
                exit(0)
              end
              on('--check-entropy', 'Flag values with low Shannon entropy (default: false)') do
                Handler.set(key: :check_entropy, value: true)
              end
              on('--allow-production', 'Skip the production key warning (default: false)') do
                Handler.set(key: :allow_production, value: true)
              end
              on('--warn-on-pattern', 'Show an info notice when a known pattern matches (default: false)') do
                Handler.set(key: :warn_on_pattern, value: true)
              end
              on('--verbose', 'Enable verbose output (default: false)') do
                Core::Console::Argument::Handler.set(key: :verbose, value: true)
              end
            end
          end
        end
      end
    end
  end
end
