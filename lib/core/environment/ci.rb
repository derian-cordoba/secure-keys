#!/usr/bin/env ruby

module SecureKeys
  module Core
    module Environment
      class CI
        # Fetches the value of the environment variable with the given key.
        # @param key [String] the key of the environment variable to fetch
        # @return [String] the value of the environment variable
        def fetch(key:)
          ENV[key]
        rescue StandardError
          puts "❌ Error fetching the key: #{key} from ENV variables"
        end
      end
    end
  end
end
