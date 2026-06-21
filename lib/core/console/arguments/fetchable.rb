#!/usr/bin/env ruby

module SecureKeys
  module Core
    module Console
      module Argument
        # Shared fetch/set behaviour for argument handler classes.
        # Include this module inside +class << self+ so the methods become
        # class-level accessors that check the handler's own +arguments+ hash
        # before falling back to environment variables.
        #
        # The including class must expose +arguments+ as a class-level reader
        # (via +attr_reader :arguments+ inside +class << self+).
        module Fetchable
          # Fetch an argument value, falling back to SECURE_KEYS_<KEY>,
          # then the bare <KEY> environment variable, then +default+.
          #
          # @param key [Symbol, Array<Symbol>] The argument key (or nested key path)
          # @param default [Object] The value to return when nothing is found
          # @return [Object] The resolved value
          def fetch(key:, default: nil)
            keys = Array(key).map(&:to_sym)
            joined_keys = keys.join('_').upcase
            arguments.dig(*keys) || ENV["SECURE_KEYS_#{joined_keys}"] || ENV[joined_keys] || default
          end

          # Update a single argument value
          # @param key [Symbol] The argument key to update
          # @param value [Object] The new value
          # @return [void]
          def set(key:, value:)
            arguments[key.to_sym] = value
          end
        end
      end
    end
  end
end
