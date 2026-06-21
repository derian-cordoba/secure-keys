#!/usr/bin/env ruby

require 'optparse'
require_relative '../../globals/globals'
require_relative 'handler'
require_relative 'xcframework/parser'

module SecureKeys
  module Core
    module Console
      module Argument
        class Parser < OptionParser
          # Initialize the argument parser with the default options
          def initialize
            super('Usage: secure-keys [--options]')
            separator('')

            # Route known subcommands before processing flags.
            # Like --help and --version, subcommand handlers exit internally,
            # so the generator is never reached.
            route_subcommand!

            # Configure the argument parser
            configure!
            order!(into: Handler.arguments)
            configure_sub_arguments
          end

          private

          # Known positional subcommands mapped to their handler lambdas.
          # Each lambda is expected to handle its own output and exit.
          SUBCOMMANDS = {
            'validate' => lambda {
              require_relative '../../../validation/console/arguments/parser'
              Validation::Console::Argument::Parser.new.execute
            },
          }.freeze

          # Detect a known positional subcommand as the first ARGV token and delegate
          # to its handler. Like --help and --version, the handler exits internally so
          # the generator is never reached.
          # @return [void]
          def route_subcommand!
            token = ARGV.first
            return unless SUBCOMMANDS.key?(token)

            ARGV.shift
            SUBCOMMANDS[token].call
          end

          # Configure the argument parser
          def configure!
            on('-h', '--help', 'Use the provided commands to select the params') do
              puts self
              exit(0)
            end
            on('--ci', TrueClass, 'Enable CI mode (default: false)')
            on('-d', '--delimiter DELIMITER', String, "The delimiter to use for the key access (default: \"#{Globals.default_key_delimiter}\")")
            on('--[no-]generate', TrueClass, 'Generate the SecureKeys.xcframework')
            on('-i', '--identifier IDENTIFIER', String, "The identifier to use for the key access (default: \"#{Globals.default_key_access_identifier}\")")
            on('--verbose', TrueClass, 'Enable verbose mode (default: false)')
            on('-v', '--version', 'Show the secure-keys version') do
              puts "secure-keys version: v#{SecureKeys::VERSION}"
              exit(0)
            end
            on('--xcframework', 'Add the xcframework to the target') do
              XCFramework::Parser.new
            end
          end

          # Configure the sub arguments
          def configure_sub_arguments
            Handler.set(key: :xcframework, value: XCFramework::Handler.arguments)
          end
        end
      end
    end
  end
end
