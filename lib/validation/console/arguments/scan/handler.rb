#!/usr/bin/env ruby

require_relative '../../../../core/console/arguments/fetchable'

module SecureKeys
  module Validation
    module Console
      module Argument
        module Scan
          # Stores and provides access to the resolved CLI arguments for the scan subcommand
          class Handler
            class << self
              include Core::Console::Argument::Fetchable

              attr_reader :arguments
            end

            # Default argument values for the scan subcommand
            @arguments = {
              path: '.',
              staged: false,
              output: nil,
              extensions: nil,
              excludes: nil,
            }
          end
        end
      end
    end
  end
end
