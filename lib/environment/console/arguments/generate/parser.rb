#!/usr/bin/env ruby

require 'optparse'
require_relative 'handler'

module SecureKeys
  module Environment
    module Console
      module Argument
        module Generate
          # Parses CLI options for the `secure-keys env generate` subcommand.
          # Any remaining ARGV token after option parsing is treated as the environment name.
          class Parser < OptionParser
            # Initialize the generate parser, process ARGV, and store results in Handler
            def initialize
              super('Usage: secure-keys env generate [name] [--options]')
              separator('')
              configure!
              parse!(into: Handler.arguments)
              Handler.set(key: :name, value: ARGV.shift) unless ARGV.empty?
            end

            private

            # Define all accepted options for the env generate subcommand
            # @return [void]
            def configure!
              on('-h', '--help', 'Show help for the env generate subcommand') do
                puts self
                exit(0)
              end
              on('--all', 'Generate xcframeworks for all configured environments (default: false)') do
                Handler.set(key: :all, value: true)
              end
            end
          end
        end
      end
    end
  end
end
