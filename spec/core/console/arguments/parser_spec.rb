require 'core/console/arguments/parser'
require 'version'

describe(SecureKeys::Core::Console::Argument::Parser) do
  it('should be the current version from terminal output') do
    # given
    expected_version = "secure-keys version: v#{SecureKeys::VERSION}"

    # when
    %w[-v --version].each do |option|
      output = `./bin/secure-keys #{option}`.strip

      # then
      expect(output).to(eq(expected_version))
    end
  end

  it('should be the help information from terminal output') do
    # given
    expected_help = [
      'Usage: secure-keys [--options]',
      '',
      '-h, --help                       Use the provided commands to select the params',
      '--xcframework                Add the xcframework to the target',
      '-d, --delimiter DELIMITER        The delimiter to use for the key access (default: ",")',
      '--[no-]generate              Generate the SecureKeys.xcframework',
      '-i, --identifier IDENTIFIER      The identifier to use for the key access (default: "secure-keys")',
      '--verbose                    Enable verbose mode (default: false)',
      '-v, --version                    Show the secure-keys version'
    ]

    # when
    %w[-h --help].each do |option|
      output_lines = `./bin/secure-keys #{option}`.split("\n")
                                                  .map(&:strip)

      # then
      expect(output_lines).to(eq(expected_help))
    end
  end

  it('should be the XCFramework help information from terminal output') do
    # given
    expected_help = [
      'Usage: secure-keys --xcframework [--options]',
      '',
      '-h, --help                       Use the provided commands to select the params',
      '--[no-]add                   Add the SecureKeys XCFramework to the Xcode project (default: true)',
      '-t, --target TARGET              The target to add the xcframework',
      '-r, --replace                    Replace the existing xcframework in the Xcode project (default: false)',
      '-x, --xcodeproj XCODEPROJ        The Xcode project path (default: the first found Xcode project)'
    ]

    # when
    %w[-h --help].each do |option|
      output_lines = `./bin/secure-keys --xcframework #{option}`.split("\n")
                                                                .map(&:strip)

      # then
      expect(output_lines).to(eq(expected_help))
    end
  end
end
