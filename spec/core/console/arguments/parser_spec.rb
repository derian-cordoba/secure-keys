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
      '--add-xcframework-to-target TARGET',
      'Add the xcframework to the target',
      '-d, --delimiter DELIMITER        The delimiter to use for the key access (default: ",")',
      '-i, --identifier IDENTIFIER      The identifier to use for the key access (default: "secure-keys")',
      '--verbose                    Enable verbose mode (default: false)',
      '-v, --version                    Show the secure-keys version',
      '-x, --xcodeproj XCODEPROJ        The Xcode project path (default: the first found Xcode project)'
    ]

    # when
    %w[-h --help].each do |option|
      output_lines = `./bin/secure-keys #{option}`.split("\n")
                                                  .map(&:strip)

      # then
      expect(output_lines).to(eq(expected_help))
    end
  end
end
