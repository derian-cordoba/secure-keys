#!/usr/bin/env ruby

require 'optparse'
require_relative 'handler'
require_relative '../../../../core/console/arguments/handler'

module SecureKeys
  module Validation
    module Console
      module Argument
        module Scan
          # Parses CLI options for the `secure-keys validate scan` subcommand.
          # Uses +parse!+ so options and positional arguments may appear in any order;
          # after parsing, any remaining ARGV token is treated as the scan path.
          class Parser < OptionParser
            # Initialize the scan parser, process ARGV, and store results in Handler
            def initialize
              super('Usage: secure-keys validate scan [path] [--options]')
              separator('')
              configure!
              parse!(into: Handler.arguments)
              Handler.set(key: :path, value: ARGV.shift) unless ARGV.empty?
            end

            private

            # Define all accepted options for the scan subcommand
            # @return [void]
            def configure!
              on('-h', '--help', 'Show help for the scan subcommand') do
                puts self
                exit(0)
              end
              on(
                '--staged',
                TrueClass,
                'Scan staged git changes instead of a directory (default: false)'
              )
              on(
                '-o', '--output FILE',
                String,
                'Save the scan report as JSON to FILE'
              )
              on(
                '--extensions EXTENSIONS',
                String,
                'Comma-separated file extensions to scan (e.g. .rb,.swift)'
              )
              on(
                '--excludes EXCLUDES',
                String,
                'Comma-separated directory names to exclude from the scan'
              )
              on('--verbose', TrueClass, 'Enable verbose output (default: false)') do
                Core::Console::Argument::Handler.set(key: :verbose, value: true)
              end
            end
          end
        end
      end
    end
  end
end
