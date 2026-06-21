require 'tmpdir'
require 'fileutils'
require 'validation/scanner'
require 'core/console/shell'

describe(SecureKeys::Validation::Scanner) do
  let(:scanner) { described_class.new }

  let(:temp_dir) { Dir.mktmpdir('secure_keys_scanner_spec') }

  after(:each) do
    FileUtils.rm_rf(temp_dir)
  end

  # Write a fixture file and return its path
  def write_fixture(name:, content:)
    path = File.join(temp_dir, name)
    File.write(path, content)
    path
  end

  # MARK: Initialization

  it('should initialize with default options') do
    # when
    extensions = scanner.send(:file_extensions)
    excludes   = scanner.send(:exclude_patterns)

    # then
    expect(extensions).to(include('.swift', '.rb'))
    expect(excludes).to(include('.git', 'node_modules'))
  end

  it('should merge custom options over the defaults') do
    # given
    custom_scanner = described_class.new(options: { extensions: ['.go'] })

    # when
    extensions = custom_scanner.send(:file_extensions)

    # then
    expect(extensions).to(eq(['.go']))
  end

  # MARK: mask_secret

  it('should return *** for secrets with 6 or fewer characters') do
    expect(scanner.send(:mask_secret, secret: 'abc')).to(eq('***'))
    expect(scanner.send(:mask_secret, secret: 'abcdef')).to(eq('***'))
  end

  it('should show the first 4 characters and mask the rest') do
    # given
    secret = 'ghp_abcdefghijklmnop'

    # when
    masked = scanner.send(:mask_secret, secret:)

    # then
    expect(masked).to(start_with('ghp_'))
    expect(masked).to(include('*'))
    expect(masked.length).to(eq(secret.length))
  end

  # MARK: scan_directory: clean results

  it('should return a clean result for an empty directory') do
    # when
    result = scanner.scan_directory(path: temp_dir)

    # then
    expect(result.clean?).to(eq(true))
    expect(result.files_count).to(eq(0))
  end

  it('should return a clean result for files with no secrets') do
    # given
    write_fixture(name: 'safe.rb', content: "puts 'hello world'\n")

    # when
    result = scanner.scan_directory(path: temp_dir)

    # then
    expect(result.clean?).to(eq(true))
    expect(result.files_count).to(eq(1))
  end

  # MARK: scan_directory: pattern detection

  it('should detect a GitHub personal access token in a .rb file') do
    # given
    token = "ghp_#{'a' * 36}"
    write_fixture(name: 'config.rb', content: "token = '#{token}'\n")

    # when
    result = scanner.scan_directory(path: temp_dir)

    # then
    expect(result.clean?).to(eq(false))
    github_finding = result.findings.find { |f| f.type == :github_token }
    expect(github_finding).not_to(be_nil)
    expect(github_finding.file).to(include('config.rb'))
    expect(github_finding.line).to(eq(1))
  end

  it('should detect an AWS access key in a .rb file') do
    # given
    write_fixture(name: 'aws.rb', content: "key = 'AKIAIOSFODNN7EXAMPLE'\n")

    # when
    result = scanner.scan_directory(path: temp_dir)

    # then
    aws_finding = result.findings.find { |f| f.type == :aws_access_key }
    expect(aws_finding).not_to(be_nil)
    expect(aws_finding.severity).to(eq(:critical))
  end

  it('should detect a Stripe secret key in a .rb file') do
    # given
    stripe_key = "sk_live_51H#{'a' * 24}"
    write_fixture(name: 'payment.rb', content: "key = '#{stripe_key}'\n")

    # when
    result = scanner.scan_directory(path: temp_dir)

    # then
    stripe_finding = result.findings.find { |f| f.type == :stripe_secret_key }
    expect(stripe_finding).not_to(be_nil)
  end

  it('should detect a Google Cloud API key in a .swift file') do
    # given
    write_fixture(name: 'Config.swift', content: "let apiKey = \"AIzaSyDaGmWKa4JsXZ-HjGw7ISLn_3namBGewQe\"\n")

    # when
    result = scanner.scan_directory(path: temp_dir)

    # then
    gcp_finding = result.findings.find { |f| f.type == :gcp_api_key }
    expect(gcp_finding).not_to(be_nil)
  end

  it('should set the correct file path on a finding') do
    # given
    token = "ghp_#{'a' * 36}"
    file_path = write_fixture(name: 'secrets.rb', content: "TOKEN = '#{token}'\n")

    # when
    result = scanner.scan_directory(path: temp_dir)

    # then
    expect(result.findings.first.file).to(eq(file_path))
  end

  it('should mask the matched text in findings') do
    # given
    token = "ghp_#{'a' * 36}"
    write_fixture(name: 'config.rb', content: "token = '#{token}'\n")

    # when
    result = scanner.scan_directory(path: temp_dir)

    # then
    finding = result.findings.find { |f| f.type == :github_token }
    expect(finding.matched_text).to(start_with('ghp_'))
    expect(finding.matched_text).to(include('*'))
    expect(finding.matched_text).not_to(include(token))
  end

  # MARK: scan_directory: line filtering

  it('should skip lines starting with a Ruby comment (#)') do
    # given
    token = "ghp_#{'a' * 36}"
    write_fixture(name: 'config.rb', content: "# token = '#{token}'\n")

    # when
    result = scanner.scan_directory(path: temp_dir)

    # then
    expect(result.clean?).to(eq(true))
  end

  it('should skip lines starting with a Swift comment (//)') do
    # given
    token = "ghp_#{'a' * 36}"
    write_fixture(name: 'Config.swift', content: "// let token = \"#{token}\"\n")

    # when
    result = scanner.scan_directory(path: temp_dir)

    # then
    expect(result.clean?).to(eq(true))
  end

  it('should skip lines shorter than 10 characters') do
    # given — "AKIA" alone is only 4 chars, well under the threshold
    write_fixture(name: 'short.rb', content: "AKIA\n")

    # when
    result = scanner.scan_directory(path: temp_dir)

    # then
    expect(result.clean?).to(eq(true))
  end

  # MARK: scan_directory: exclusions

  it('should not scan files in excluded directories') do
    # given
    excluded_dir = File.join(temp_dir, 'node_modules')
    FileUtils.mkdir_p(excluded_dir)
    token = "ghp_#{'a' * 36}"
    File.write(File.join(excluded_dir, 'secret.rb'), "token = '#{token}'\n")

    # when
    result = scanner.scan_directory(path: temp_dir)

    # then
    expect(result.clean?).to(eq(true))
  end

  it('should not scan files with extensions not in the inclusion list') do
    # given
    token = "ghp_#{'a' * 36}"
    write_fixture(name: 'config.txt', content: "token=#{token}\n")

    # when
    result = scanner.scan_directory(path: temp_dir)

    # then
    expect(result.clean?).to(eq(true))
  end

  it('should scan multiple files and aggregate findings') do
    # given
    token = "ghp_#{'a' * 36}"
    write_fixture(name: 'file_one.rb', content: "token = '#{token}'\n")
    write_fixture(name: 'file_two.rb', content: "key   = 'AKIAIOSFODNN7EXAMPLE'\n")

    # when
    result = scanner.scan_directory(path: temp_dir)

    # then
    expect(result.findings.length).to(be >= 2)
    expect(result.files_count).to(eq(2))
  end

  # MARK: scan_directory: suspicious assignments

  it('should detect a generic suspicious assignment not covered by specific patterns') do
    # given — "credential" is not matched by any specific PATTERN keyword,
    # so check_suspicious_assignments should catch it
    write_fixture(name: 'config.rb', content: "credential = 'my-internal-service-value-not-a-known-pattern'\n")

    # when
    result = scanner.scan_directory(path: temp_dir)

    # then
    suspicious = result.findings.find { |f| f.type == :suspicious_assignment }
    expect(suspicious).not_to(be_nil)
    expect(suspicious.severity).to(eq(:low))
  end

  # MARK: scan_git_diff

  it('should return a clean result when the git diff is empty') do
    # given
    allow(SecureKeys::Core::Console::Shell).to(
      receive(:sh).with(command: 'git diff --cached').and_return(['', nil, nil])
    )

    # when
    result = scanner.scan_git_diff

    # then
    expect(result.clean?).to(eq(true))
  end

  it('should detect a secret in a staged git diff addition') do
    # given
    token = "ghp_#{'a' * 36}"
    diff = <<~DIFF
      diff --git a/lib/config.rb b/lib/config.rb
      --- a/lib/config.rb
      +++ b/lib/config.rb
      @@ -1,0 +1 @@
      +token = '#{token}'
    DIFF

    allow(SecureKeys::Core::Console::Shell).to(
      receive(:sh).with(command: 'git diff --cached').and_return([diff, nil, nil])
    )

    # when
    result = scanner.scan_git_diff

    # then
    expect(result.clean?).to(eq(false))
    github_finding = result.findings.find { |f| f.type == :github_token }
    expect(github_finding).not_to(be_nil)
    expect(github_finding.addition?).to(eq(true))
  end

  it('should not flag removed lines (starting with -) in a git diff') do
    # given
    token = "ghp_#{'a' * 36}"
    diff = <<~DIFF
      diff --git a/lib/config.rb b/lib/config.rb
      --- a/lib/config.rb
      +++ b/lib/config.rb
      @@ -1 +0,0 @@
      -token = '#{token}'
    DIFF

    allow(SecureKeys::Core::Console::Shell).to(
      receive(:sh).with(command: 'git diff --cached').and_return([diff, nil, nil])
    )

    # when
    result = scanner.scan_git_diff

    # then
    expect(result.clean?).to(eq(true))
  end

  it('should scan unstaged changes when staged_only is false') do
    # given
    allow(SecureKeys::Core::Console::Shell).to(
      receive(:sh).with(command: 'git diff').and_return(['', nil, nil])
    )

    # when
    result = scanner.scan_git_diff(staged_only: false)

    # then
    expect(result).not_to(be_nil)
    expect(result.clean?).to(eq(true))
  end
end
