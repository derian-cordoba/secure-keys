require 'core/utils/swift/writer'
require 'core/utils/swift/swift'

describe(SecureKeys::Swift::Writer) do
  after(:each) do
    # Remove secure keys temporary directory
    FileUtils.rm_rf(SecureKeys::Swift::KEYS_DIRECTORY)
  end

  it('should initialize the writer with the mapped keys and the secure key bytes') do
    # given
    mapped_keys = [{ name: 'key', value: 'value', iv: 'iv', tag: 'tag' }]
    secure_key_bytes = [1, 2, 3, 4]
    writer = SecureKeys::Swift::Writer.new(mapped_keys: mapped_keys, secure_key_bytes: secure_key_bytes)

    # when
    mapped_keys_result = writer.instance_variable_get(:@mapped_keys)
    secure_key_bytes_result = writer.instance_variable_get(:@secure_key_bytes)

    # then
    expect(mapped_keys_result).to(eq(mapped_keys))
    expect(secure_key_bytes_result).to(eq(secure_key_bytes))
  end

  it('should write the keys to the file') do
    # given
    mapped_keys = [{ name: 'key', value: 'value', iv: 'iv', tag: 'tag' }]
    secure_key_bytes = [1, 2, 3, 4]
    writer = SecureKeys::Swift::Writer.new(mapped_keys: mapped_keys, secure_key_bytes: secure_key_bytes)

    # when
    allow(writer).to(receive(:key_swift_file_template).and_return('content'))

    # Create temporary directory
    FileUtils.mkdir_p(writer.instance_variable_get(:@key_directory))
    writer.write

    # then
    key_directory = writer.instance_variable_get(:@key_directory)
    key_file = writer.instance_variable_get(:@key_file)
    expect(File).to(exist("#{key_directory}/#{key_file}"))
  end

  it('should be swift template same as expected') do
    # given
    expected_secure_key_bytes = [1, 2, 3, 4]
    expected_iv = [5, 6, 7, 8]
    expected_tag = [9, 10, 11, 12]
    mapped_keys = [{ name: 'key', value: 'value', iv: expected_iv, tag: expected_tag }]
    writer = SecureKeys::Swift::Writer.new(mapped_keys:, secure_key_bytes: expected_secure_key_bytes)

    # when
    formatted_keys = writer.formatted_keys

    # then
    # The identification of the content is correct although at first glance it seems to be wrong.
    expect(formatted_keys).to(eq(<<~SWIFT
      case key

          case unknown

          // MARK: - Properties

          /// The decrypted value of the key
          public var decryptedValue: String {
              switch self {
                  case .key: value.decrypt(key: #{expected_secure_key_bytes}, iv: #{expected_iv}, tag: #{expected_tag})

                  case .unknown: fatalError("Unknown key \\(rawValue)")
              }
          }
    SWIFT
                                ))
  end

  it('should be swift file template same as expected') do
    # given
    expected_secure_key_bytes = [1, 2, 3, 4]
    expected_iv = [5, 6, 7, 8]
    expected_tag = [9, 10, 11, 12]
    mapped_keys = [{ name: 'mySuperSecretKey', value: 'value', iv: expected_iv, tag: expected_tag }]
    writer = SecureKeys::Swift::Writer.new(mapped_keys:, secure_key_bytes: expected_secure_key_bytes)

    # when
    key_swift_file_template = writer.key_swift_file_template(content: writer.formatted_keys)

    # then
    expect(key_swift_file_template).to(eq(<<~SWIFT
      // swiftlint:disable all

      import Foundation
      import CryptoKit

      // MARK: - Global methods

      /// Fetch the decrypted value of the key
      ///
      /// - Parameter:
      ///    - key: The key to fetch the decrypted value for
      ///
      /// - Returns: The decrypted value of the key
      @available(iOS 13.0, *)
      public func key(for key: SecureKey) -> String { key.decryptedValue }

      /// Fetch the decrypted value of the key
      ///
      /// - Parameter:
      ///    - key: The key to fetch the decrypted value for
      ///
      /// - Returns: The decrypted value of the key
      @available(iOS 13.0, *)
      public func key(_ key: SecureKey) -> String { key.decryptedValue }


      // MARK: - SecureKey enum

      /// Keys is a class that contains all the keys that are used in the application.
      @available(iOS 13.0, *)
      public enum SecureKey: String {

          // MARK: - Cases

          case mySuperSecretKey

          case unknown

          // MARK: - Properties

          /// The decrypted value of the key
          public var decryptedValue: String {
              switch self {
                  case .mySuperSecretKey: value.decrypt(key: #{expected_secure_key_bytes}, iv: #{expected_iv}, tag: #{expected_tag})

                  case .unknown: fatalError("Unknown key \\(rawValue)")
              }
          }

      }

      // MARK: - Decrypt keys from array extension

      @available(iOS 13.0, *)
      extension Array where Element == UInt8 {

          // MARK: - Methods

          func decrypt(key: [UInt8], iv: [UInt8], tag: [UInt8]) -> String {
              guard let sealedBox = try? AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: Data(iv)),
                                                          ciphertext: Data(self),
                                                          tag: Data(tag)),
                    let decryptedData = try? AES.GCM.open(sealedBox, using: SymmetricKey(data: Data(key))),
                    let decryptedKey = String(data: decryptedData, encoding: .utf8) else {
                  fatalError("Failed to decrypt the key")
              }
              return decryptedKey
          }
      }


      // MARK: - String extension for secure keys

      @available(iOS 13.0, *)
      extension String {

          // MARK: - Methods

          /// Fetch the key from the secure keys enum
          public var secretKey: SecureKey { SecureKey(rawValue: self) ?? .unknown }

          /// Fetch the decrypted value of the key
          ///
          /// - Parameters:
          ///    - key: The key to fetch the decrypted value for
          ///
          /// - Returns: The decrypted value of the key
          public static func key(for key: SecureKey) -> String { key.decryptedValue }
      }


      // swiftlint:enable all
    SWIFT
                                         ))
  end
end
