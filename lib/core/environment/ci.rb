#!/usr/bin/env ruby

require_relative '../console/logger'

module SecureKeys
  module Core
    module Environment
      class CI
        # Fetches the value of the environment variable with the given key.
        # @param key [String] the key of the environment variable to fetch
        # @return [String] the value of the environment variable
        def fetch(key:)
          normalized_key = key.to_s.tr('-', '_').upcase

          ENV[key.to_s] ||
            ENV[normalized_key] ||
            ENV["SECURE_KEYS_#{normalized_key}"] ||
            inline_identifier_value(key)
        rescue StandardError
          Core::Console::Logger.error(message: "Error fetching the key '#{key}' from ENV variables")
        end

        private

        def inline_identifier_value(key)
          key if key.to_s.include?(SecureKeys::Globals.key_delimiter)
        end
      end
    end
  end
end
