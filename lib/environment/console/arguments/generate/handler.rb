#!/usr/bin/env ruby

require_relative '../../../../core/console/arguments/fetchable'

module SecureKeys
  module Environment
    module Console
      module Argument
        module Generate
          # Stores and provides access to the resolved CLI arguments for the env generate subcommand
          class Handler
            class << self
              include Core::Console::Argument::Fetchable

              attr_reader :arguments
            end

            # Default argument values for the env generate subcommand
            @arguments = {
              name: nil,
              all: false,
            }
          end
        end
      end
    end
  end
end
