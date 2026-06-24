#!/usr/bin/env ruby

require 'optparse'
require_relative '../../../core/console/logger'
require_relative 'scan/handler'
require_relative 'scan/parser'
require_relative 'key/handler'
require_relative 'key/parser'
require_relative '../../actions/scan'
require_relative '../../actions/key'

module SecureKeys
  module Validation
    module Console
      module Argument
        # Routes the `validate` subcommand to the appropriate sub-parser and action.
        # The constructor reads the subcommand token from ARGV; +execute+ then
        # delegates to the matching sub-parser and runs the action.
        class Parser < OptionParser
          # Initialize the validate argument parser and capture the subcommand token
          def initialize
            super('Usage: secure-keys validate [subcommand] [--options]')
            separator('')
            configure!
            @subcommand = ARGV.shift
          end

          # Dispatch to the correct sub-parser and action based on the subcommand
          # @return [void]
          def execute
            case @subcommand
            when 'scan'
              Scan::Parser.new
              Actions::Scan.new.run
            when 'key'
              Key::Parser.new
              Actions::Key.new.run
            when nil, '--help', '-h'
              puts self
              exit(0)
            else
              Core::Console::Logger.error(message: "Unknown validate subcommand: '#{@subcommand}'")
              puts self
              exit(1)
            end
          end

          private

          # Configure the validate-level help text and available subcommands
          # @return [void]
          def configure!
            on('-h', '--help', 'Show help for the validate command') do
              puts self
              exit(0)
            end
            separator('')
            separator('Subcommands:')
            separator("\tscan [path]          Scan a directory or staged git changes for exposed secrets")
            separator("\tkey <name> <value>   Validate a single secret value against security rules")
            separator('')
            separator('Examples:')
            separator("\tsecure-keys validate scan")
            separator("\tsecure-keys validate scan ./src")
            separator("\tsecure-keys validate scan --staged")
            separator("\tsecure-keys validate scan --output report.json")
            separator("\tsecure-keys validate key apiKey \"your-secret-value\"")
            separator("\tsecure-keys validate key stripeKey \"sk_live_...\" --check-entropy")
          end
        end
      end
    end
  end
end
