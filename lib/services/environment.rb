#!/usr/bin/env ruby

module SecureKeys
  module Services
    module Environment
      module_function

      # Fetches the value of an environment variable with support for SecureKeys prefix
      # @param key [Symbol] The environment variable key to fetch
      # @param default [Object] The default value to return if the environment variable is not set
      # @return [Object, nil] The value of the environment variable or the default value
      def fetch(key:, default: nil)
        formatted_key = key.to_s.upcase
        ENV[formatted_key] || ENV["SECURE_KEYS_#{formatted_key}"] || default
      end

      # Fetches the integer value of an environment variable with support for SecureKeys prefix
      # @param key [Symbol] The environment variable key to fetch
      # @param default [Object] The default value to return if the environment variable is not set or cannot be converted to an integer
      # @return [Integer, nil] The integer value of the environment variable or the default value
      def integer(key:, default: nil)
        value = fetch(key:, default:)
        Integer(value)
      rescue ArgumentError, TypeError
        # Returns default if it's nil or integer, otherwise, force return nil
        default.is_a?(Integer) || default.nil? ? default : nil
      end

      def decimal(key:, default: nil)
        value = fetch(key:, default:)
        Float(value)
      rescue ArgumentError, TypeError
        # Returns default if it's nil or float, otherwise, force return nil
        default.is_a?(Float) || default.nil? ? default : nil
      end
    end
  end
end
