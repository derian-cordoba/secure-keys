module SecureKeys
  module Core
    module Console
      module Argument
        class Handler
          class << self
            attr_reader :arguments
          end

          # Configure the default arguments
          @arguments = {
            delimiter: nil,
            identifier: nil,
            verbose: false,
          }

          # Fetch the argument value by key
          # from CLI arguments or environment variables
          #
          # @param key [Symbol] the argument key
          # @param default [String] the default value
          #
          # @return [String] the argument value
          def self.fetch(key:, default: nil)
            @arguments.dig(*Array(key).map(&:to_sym)) || ENV.fetch("secure_keys_#{key}".upcase, nil) || default
          end

          # Set the value of the key
          # @param key [Symbol] the key to be updated
          # @param value [String] the value to be updated
          def self.set(key:, value:)
            @arguments[key.to_sym] = value
          end

          # Append the argument value by key
          # @param key [Symbol] the argument key
          # @param value [String] the argument value
          def self.deep_merge(key:, value:)
            @arguments[key.to_sym].deep_merge(value)
          end
        end
      end
    end
  end
end
