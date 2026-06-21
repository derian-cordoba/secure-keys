require 'tmpdir'
require 'fileutils'
require 'json'
require 'validation/console/arguments/scan/parser'

describe(SecureKeys::Validation::Console::Argument::Scan::Parser) do
  let(:temp_dir) { Dir.mktmpdir('secure_keys_scan_parser_spec') }

  after(:each) do
    FileUtils.rm_rf(temp_dir)
  end

  # Write a fixture file inside the temp directory and return its path
  def write_fixture(name:, content:)
    path = File.join(temp_dir, name)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
    path
  end

  # MARK: Help

  it('should be the scan help information from terminal output') do
    # given
    expected_help = [
      'Usage: secure-keys validate scan [path] [--options]',
      '',
      '-h, --help                       Show help for the scan subcommand',
      '--staged                     Scan staged git changes instead of a directory (default: false)',
      '-o, --output FILE                Save the scan report as JSON to FILE',
      '--extensions EXTENSIONS      Comma-separated file extensions to scan (e.g. .rb,.swift)',
      '--excludes EXCLUDES          Comma-separated directory names to exclude from the scan',
      '--verbose                    Enable verbose output (default: false)'
    ]

    # when
    %w[-h --help].each do |option|
      output_lines = `./bin/secure-keys validate scan #{option}`.split("\n")
                                                                .map(&:strip)

      # then
      expect(output_lines).to(eq(expected_help))
    end
  end

  # MARK: Exit codes

  it('should exit with code 0 when no secrets are found') do
    # given
    write_fixture(name: 'clean.rb', content: "puts 'hello world'\n")

    # when
    `./bin/secure-keys validate scan #{temp_dir} 2>&1`
    exit_code = $CHILD_STATUS.exitstatus

    # then
    expect(exit_code).to(eq(0))
  end

  it('should exit with code 1 when secrets are detected') do
    # given
    write_fixture(name: 'aws.rb', content: "key = 'AKIAIOSFODNN7EXAMPLE'\n")

    # when
    `./bin/secure-keys validate scan #{temp_dir} 2>&1`
    exit_code = $CHILD_STATUS.exitstatus

    # then
    expect(exit_code).to(eq(1))
  end

  # MARK: Path argument

  it('should scan the default path (.) when no path is given') do
    # when
    output = `./bin/secure-keys validate scan 2>&1`

    # then
    expect(output).to(include('Scanning directory: .'))
  end

  it('should scan a custom path passed as a positional argument') do
    # when
    output = `./bin/secure-keys validate scan #{temp_dir} 2>&1`

    # then
    expect(output).to(include("Scanning directory: #{temp_dir}"))
  end

  # MARK: --extensions

  it('should skip files whose extension is not in --extensions') do
    # given — secret is in a .rb file; scan is restricted to .swift only
    write_fixture(name: 'aws.rb', content: "key = 'AKIAIOSFODNN7EXAMPLE'\n")

    # when
    `./bin/secure-keys validate scan #{temp_dir} --extensions .swift 2>&1`
    exit_code = $CHILD_STATUS.exitstatus

    # then
    expect(exit_code).to(eq(0))
  end

  it('should scan files whose extension matches --extensions') do
    # given
    write_fixture(name: 'aws.rb', content: "key = 'AKIAIOSFODNN7EXAMPLE'\n")

    # when
    `./bin/secure-keys validate scan #{temp_dir} --extensions .rb 2>&1`
    exit_code = $CHILD_STATUS.exitstatus

    # then
    expect(exit_code).to(eq(1))
  end

  # MARK: --excludes

  it('should skip directories listed in --excludes') do
    # given — secret lives inside an excluded subdirectory
    write_fixture(name: 'vendor/aws.rb', content: "key = 'AKIAIOSFODNN7EXAMPLE'\n")

    # when
    `./bin/secure-keys validate scan #{temp_dir} --excludes vendor 2>&1`
    exit_code = $CHILD_STATUS.exitstatus

    # then
    expect(exit_code).to(eq(0))
  end

  it('should scan directories not listed in --excludes') do
    # given — secret is NOT inside an excluded directory
    write_fixture(name: 'src/aws.rb', content: "key = 'AKIAIOSFODNN7EXAMPLE'\n")

    # when
    `./bin/secure-keys validate scan #{temp_dir} --excludes vendor 2>&1`
    exit_code = $CHILD_STATUS.exitstatus

    # then
    expect(exit_code).to(eq(1))
  end

  # MARK: --output

  it('should save a JSON report to the path given by --output') do
    # given
    write_fixture(name: 'aws.rb', content: "key = 'AKIAIOSFODNN7EXAMPLE'\n")
    report_path = File.join(temp_dir, 'report.json')

    # when
    `./bin/secure-keys validate scan #{temp_dir} --output #{report_path} 2>&1`
    report = JSON.parse(File.read(report_path))

    # then
    expect(report).to(include('files_scanned', 'total_findings', 'findings'))
    expect(report['total_findings']).to(eq(1))
  end

  it('should include finding details in the JSON report') do
    # given
    write_fixture(name: 'aws.rb', content: "key = 'AKIAIOSFODNN7EXAMPLE'\n")
    report_path = File.join(temp_dir, 'report.json')

    # when
    `./bin/secure-keys validate scan #{temp_dir} --output #{report_path} 2>&1`
    finding = JSON.parse(File.read(report_path))['findings'].first

    # then
    expect(finding['type']).to(eq('aws_access_key'))
    expect(finding['severity']).to(eq('critical'))
  end

  it('should not create a report file when --output is not specified') do
    # given
    write_fixture(name: 'aws.rb', content: "key = 'AKIAIOSFODNN7EXAMPLE'\n")
    report_path = File.join(temp_dir, 'report.json')

    # when
    `./bin/secure-keys validate scan #{temp_dir} 2>&1`

    # then
    expect(File.exist?(report_path)).to(be(false))
  end
end
