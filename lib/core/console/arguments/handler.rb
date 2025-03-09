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
            # We need to check if the key is an array to handle the fetch
            # as deep search
            @arguments.dig(*Array(key).map(&:to_sym)) || ENV.fetch("secure_keys_#{key}".upcase, nil) || default
          end

          # Append the argument value by key
          # @param key [Symbol] the argument key
          # @param value [String] the argument value
          def self.append(key:, value:)
            # We need to check if the key is already set to avoid overriding
            return unless @arguments[key.to_sym].nil?

            @arguments[key.to_sym] = value
          end
        end
      end
    end
  end
end
