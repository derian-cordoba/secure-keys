#!/usr/bin/env ruby

require_relative './core/utils/extensions/kernel'
require_relative './core/globals/globals'
require_relative './core/environment/ci'
require_relative './core/environment/keychain'
require_relative './core/utils/swift/writer'
require_relative './core/utils/swift/package'
require_relative './core/utils/swift/swift'
require_relative './core/utils/swift/xcframework'
require_relative './core/utils/openssl/cipher'
require_relative './core/console/arguments/parser'

module SecureKeys
  class Generator
    private

    attr_accessor :cipher, :secrets_source, :secret_keys, :mapped_keys

    public

    def initialize
      # Configure the argument parser
      SecureKeys::Core::Console::Argument::Parser.new

      puts "🔔 You're using a custom delimiter '#{SecureKeys::Globals.key_delimiter}'" unless SecureKeys::Globals.key_delimiter.eql?(SecureKeys::Globals.default_key_delimiter)
      puts "🔔 You're using a custom key access identifier '#{SecureKeys::Globals.key_access_identifier}'" unless SecureKeys::Globals.key_access_identifier.eql?(SecureKeys::Globals.default_key_access_identifier)

      # Configure cipher
      self.cipher = SecureKeys::OpenSSL::Cipher.new

      # Configure the secret source based on the environment
      if SecureKeys::Globals.ci?
        self.secrets_source = SecureKeys::Core::Environment::CI.new
      else
        self.secrets_source = SecureKeys::Core::Environment::Keychain.new
      end

      # Define the keys that we want to map
      self.secret_keys = secrets_source.fetch(key: SecureKeys::Globals.key_access_identifier)
                                       .to_s
                                       .split(SecureKeys::Globals.key_delimiter)
                                       .map(&:strip)

      # Add the keys that we want to map
      self.mapped_keys = secret_keys.map do |key|
        encrypted_data = cipher.encrypt(value: secrets_source.fetch(key:))
        # Convert the first key chart to downcase
        key[0] = key[0].downcase
        { name: key, **encrypted_data }
      end
    end

    def setup
      pre_actions

      package = SecureKeys::Swift::Package.new
      package.generate

      writer = SecureKeys::Swift::Writer.new(mapped_keys: mapped_keys,
                                             secure_key_bytes: cipher.secure_key_bytes)
      writer.write

      xcframework = SecureKeys::Swift::XCFramework.new
      xcframework.generate

      post_actions
    end

    private

    def pre_actions
      # Remove the keys directory
      system("rm -rf #{SecureKeys::Swift::KEYS_DIRECTORY}")
    end

    def post_actions
      # Remove the keys directory
      system("rm -rf #{SecureKeys::Swift::SWIFT_PACKAGE_DIRECTORY}")

      # Remove the build directory
      system("rm -rf #{SecureKeys::Swift::KEYS_DIRECTORY}/#{SecureKeys::Swift::BUILD_DIRECTORY}")
    end
  end
end
