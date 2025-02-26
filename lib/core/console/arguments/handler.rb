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
            target: nil,
            verbose: false,
            xcodeproj: nil,
          }

          # Fetch the argument value by key
          # from CLI arguments or environment variables
          #
          # @param key [Symbol] the argument key
          # @param default [String] the default value
          #
          # @return [String] the argument value
          def self.fetch(key:, default: nil)
            @arguments[key.to_sym] || ENV.fetch("secure_keys_#{key}".upcase, nil) || default
          end
        end
      end
    end
  end
end
