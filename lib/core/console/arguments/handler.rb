require_relative 'fetchable'

module SecureKeys
  module Core
    module Console
      module Argument
        class Handler
          class << self
            include Fetchable

            attr_reader :arguments
          end

          # Configure the default arguments
          @arguments = {
            ci: false,
            delimiter: nil,
            generate: true,
            identifier: nil,
            verbose: false,
          }

          # Append a hash value into a nested key, initialising it when absent
          # @param key [Symbol] the argument key
          # @param value [Hash] the hash to merge in
          def self.deep_merge(key:, value:)
            @arguments[key.to_sym] ||= {}
            @arguments[key.to_sym].merge!(value)
          end
        end
      end
    end
  end
end
