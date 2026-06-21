require 'environment/console/arguments/parser'

describe(SecureKeys::Environment::Console::Argument::Parser) do
  # Absolute path to the binary so Dir.chdir tests can still invoke it
  let(:bin) { File.expand_path('../../../../bin/secure-keys', __dir__) }
  # MARK: Help

  it('should be the env help information from terminal output') do
    # given
    expected_help = [
      'Usage: secure-keys env [subcommand] [--options]',
      '',
      '-h, --help                       Show help for the env command',
      '',
      'Subcommands:',
      'init              Create a default .secure-keys.yml configuration file',
      'list              List all configured environments',
      'generate [name]   Generate an xcframework for the given environment',
      'diff <a> <b>      Compare two configured environments',
      '',
      'Examples:',
      'secure-keys env init',
      'secure-keys env list',
      'secure-keys env generate development',
      'secure-keys env generate --all',
      'secure-keys env diff development production'
    ]

    # when
    %w[-h --help].each do |option|
      output_lines = `./bin/secure-keys env #{option}`.split("\n")
                                                      .map(&:strip)

      # then
      expect(output_lines).to(eq(expected_help))
    end
  end

  # MARK: Unknown subcommand

  it('should exit with code 1 for an unknown env subcommand') do
    # when
    `./bin/secure-keys env unknown 2>&1`
    exit_code = $CHILD_STATUS.exitstatus

    # then
    expect(exit_code).to(eq(1))
  end

  # MARK: init

  it('should create .secure-keys.yml and exit with code 0') do
    # given
    Dir.chdir(Dir.mktmpdir) do
      # when
      `#{bin} env init 2>&1`
      exit_code = $CHILD_STATUS.exitstatus

      # then
      expect(exit_code).to(eq(0))
      expect(File.exist?('.secure-keys.yml')).to(be(true))
    end
  end

  it('should exit with code 1 when .secure-keys.yml already exists') do
    # given
    Dir.chdir(Dir.mktmpdir) do
      `#{bin} env init 2>&1`

      # when — run init a second time
      `#{bin} env init 2>&1`
      exit_code = $CHILD_STATUS.exitstatus

      # then
      expect(exit_code).to(eq(1))
    end
  end

  # MARK: list

  it('should list environments and exit with code 0') do
    # given
    Dir.chdir(Dir.mktmpdir) do
      `#{bin} env init 2>&1`

      # when
      output = `#{bin} env list 2>&1`
      exit_code = $CHILD_STATUS.exitstatus

      # then
      expect(exit_code).to(eq(0))
      expect(output).to(include('development'))
      expect(output).to(include('staging'))
      expect(output).to(include('production'))
    end
  end

  it('should exit with code 1 when .secure-keys.yml is missing for list') do
    # given
    Dir.chdir(Dir.mktmpdir) do
      # when
      `#{bin} env list 2>&1`
      exit_code = $CHILD_STATUS.exitstatus

      # then
      expect(exit_code).to(eq(1))
    end
  end

  # MARK: diff

  it('should compare two environments and exit with code 0') do
    # given
    Dir.chdir(Dir.mktmpdir) do
      `#{bin} env init 2>&1`

      # when
      output = `#{bin} env diff development production 2>&1`
      exit_code = $CHILD_STATUS.exitstatus

      # then
      expect(exit_code).to(eq(0))
      expect(output).to(include('development'))
      expect(output).to(include('production'))
    end
  end

  it('should show key differences in the diff output') do
    # given
    Dir.chdir(Dir.mktmpdir) do
      `#{bin} env init 2>&1`

      # when
      output = `#{bin} env diff development production 2>&1`

      # then — debugToken is only in development, analyticsKey only in production
      expect(output).to(include('debugToken'))
      expect(output).to(include('analyticsKey'))
    end
  end

  it('should exit with code 1 when a diff environment name is not found') do
    # given
    Dir.chdir(Dir.mktmpdir) do
      `#{bin} env init 2>&1`

      # when
      `#{bin} env diff development nonexistent 2>&1`
      exit_code = $CHILD_STATUS.exitstatus

      # then
      expect(exit_code).to(eq(1))
    end
  end

  # MARK: generate help

  it('should be the env generate help information from terminal output') do
    # given
    expected_help = [
      'Usage: secure-keys env generate [name] [--options]',
      '',
      '-h, --help                       Show help for the env generate subcommand',
      '--all                        Generate xcframeworks for all configured environments (default: false)'
    ]

    # when
    %w[-h --help].each do |option|
      output_lines = `./bin/secure-keys env generate #{option}`.split("\n")
                                                               .map(&:strip)

      # then
      expect(output_lines).to(eq(expected_help))
    end
  end
end
