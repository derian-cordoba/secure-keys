#!/usr/bin/env ruby

require 'optparse'
require_relative '../../config'
require_relative '../../actions/init'
require_relative '../../actions/list'
require_relative '../../actions/generate'
require_relative '../../actions/diff'
require_relative 'generate/handler'
require_relative 'generate/parser'
require_relative '../../../core/console/logger'

module SecureKeys
  module Environment
    module Console
      module Argument
        # Routes the `env` subcommand to the appropriate sub-parser and action.
        # The constructor reads the subcommand token from ARGV; +execute+ then
        # delegates to the matching sub-parser and runs the action.
        class Parser < OptionParser
          # Initialize the env argument parser and capture the subcommand token
          def initialize
            super('Usage: secure-keys env [subcommand] [--options]')
            separator('')
            configure!
            @subcommand = ARGV.shift
          end

          # Dispatch to the correct sub-parser and action based on the subcommand
          # @return [void]
          def execute
            case @subcommand
            when 'init'
              Actions::Init.new.run
            when 'list'
              Actions::List.new.run
            when 'generate'
              Generate::Parser.new
              Actions::Generate.new.run
            when 'diff'
              name_a = ARGV.shift
              name_b = ARGV.shift
              unless name_a && name_b
                Core::Console::Logger.error(message: 'Usage: secure-keys env diff <environment1> <environment2>')
                exit(1)
              end
              Actions::Diff.new(name_a:, name_b:).run
            when nil, '--help', '-h'
              puts self
              exit(0)
            else
              Core::Console::Logger.error(message: "Unknown env subcommand: '#{@subcommand}'")
              puts self
              exit(1)
            end
          end

          private

          # Configure the env-level help text and available subcommands
          # @return [void]
          def configure!
            on('-h', '--help', 'Show help for the env command') do
              puts self
              exit(0)
            end
            separator('')
            separator('Subcommands:')
            separator("\tinit              Create a default .secure-keys.yml configuration file")
            separator("\tlist              List all configured environments")
            separator("\tgenerate [name]   Generate an xcframework for the given environment")
            separator("\tdiff <a> <b>      Compare two configured environments")
            separator('')
            separator('Examples:')
            separator("\tsecure-keys env init")
            separator("\tsecure-keys env list")
            separator("\tsecure-keys env generate development")
            separator("\tsecure-keys env generate --all")
            separator("\tsecure-keys env diff development production")
          end
        end
      end
    end
  end
end
