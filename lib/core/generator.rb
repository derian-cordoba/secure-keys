#!/usr/bin/env ruby

require_relative './globals/globals'
require_relative './environment/ci'
require_relative './environment/keychain'
require_relative './utils/swift/writer'
require_relative './utils/swift/package'
require_relative './utils/swift/swift'
require_relative './utils/swift/xcframework'
require_relative './utils/openssl/cipher'

module SecureKeys
  module Core
    class Generator
      private

      attr_accessor :cipher, :secrets_source, :secret_keys, :mapped_keys

      public

      def initialize
        # Configure cipher
        self.cipher = OpenSSL::Cipher.new
        self.secrets_source = Globals.secret_keys_source

        # Define the keys that we want to map
        self.secret_keys = secrets_source.fetch(key: Globals.key_access_identifier)
                                         .to_s
                                         .split(Globals.key_delimiter)
                                         .map(&:strip)

        # Add the keys that we want to map
        self.mapped_keys = secret_keys.map do |key|
          encrypted_data = cipher.encrypt(value: secrets_source.fetch(key:))
          { name: key.camelize, **encrypted_data }
        end
      end

      def generate
        pre_actions

        package = Swift::Package.new
        package.generate

        writer = Swift::Writer.new(mapped_keys:,
                                   secure_key_bytes: cipher.secure_key_bytes)
        writer.write

        xcframework = Swift::XCFramework.new
        xcframework.generate

        post_actions
      end

      private

      def pre_actions
        # Remove the keys directory
        system("rm -rf #{Swift::KEYS_DIRECTORY}")
      end

      def post_actions
        # Remove the keys directory
        system("rm -rf #{Swift::SWIFT_PACKAGE_DIRECTORY}")

        # Remove the build directory
        system("rm -rf #{Swift::KEYS_DIRECTORY}/#{Swift::BUILD_DIRECTORY}")
      end
    end
  end
end
