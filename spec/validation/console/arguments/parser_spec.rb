require 'validation/console/arguments/parser'

describe(SecureKeys::Validation::Console::Argument::Parser) do
  # MARK: Help

  it('should be the validate help information from terminal output') do
    # given
    expected_help = [
      'Usage: secure-keys validate [subcommand] [--options]',
      '',
      '-h, --help                       Show help for the validate command',
      '',
      'Subcommands:',
      'scan [path]   Scan a directory or staged git changes for exposed secrets',
      '',
      'Examples:',
      'secure-keys validate scan',
      'secure-keys validate scan ./src',
      'secure-keys validate scan --staged',
      'secure-keys validate scan --output report.json'
    ]

    # when
    %w[-h --help].each do |option|
      output_lines = `./bin/secure-keys validate #{option}`.split("\n")
                                                           .map(&:strip)

      # then
      expect(output_lines).to(eq(expected_help))
    end
  end

  # MARK: Unknown subcommand

  it('should exit with code 1 for an unknown validate subcommand') do
    # when
    `./bin/secure-keys validate unknown 2>&1`
    exit_code = $CHILD_STATUS.exitstatus

    # then
    expect(exit_code).to(eq(1))
  end
end
