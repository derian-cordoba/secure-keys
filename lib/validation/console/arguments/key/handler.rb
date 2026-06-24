#!/usr/bin/env ruby

require_relative '../../../../core/console/arguments/fetchable'

module SecureKeys
  module Validation
    module Console
      module Argument
        module Key
          # Stores and provides access to the resolved CLI arguments for the key subcommand
          class Handler
            class << self
              include Core::Console::Argument::Fetchable

              attr_reader :arguments
            end

            # Default argument values for the key subcommand
            @arguments = {
              name: nil,
              value: nil,
              check_entropy: false,
              allow_production: false,
              warn_on_pattern: false,
            }
          end
        end
      end
    end
  end
end
