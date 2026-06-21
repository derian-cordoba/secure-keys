require 'validation/models/finding'

describe(SecureKeys::Validation::Finding) do
  let(:finding) do
    described_class.new(
      file: 'lib/config.rb',
      line: 12,
      column: 8,
      type: :github_token,
      description: 'GitHub Personal Access Token',
      severity: :high,
      matched_text: 'ghp_****',
      full_line: "token = 'ghp_abcdefghijklmnopqrstuvwxyz1234567890'"
    )
  end

  let(:addition_finding) do
    described_class.new(
      file: 'lib/config.rb',
      line: 5,
      column: 0,
      type: :aws_access_key,
      description: 'AWS Access Key ID',
      severity: :critical,
      matched_text: 'AKIA****',
      full_line: 'key = "AKIAIOSFODNN7EXAMPLE"',
      is_addition: true
    )
  end

  # MARK: Readers

  it('should expose the file path') do
    expect(finding.file).to(eq('lib/config.rb'))
  end

  it('should expose the line number') do
    expect(finding.line).to(eq(12))
  end

  it('should expose the column offset') do
    expect(finding.column).to(eq(8))
  end

  it('should expose the pattern type') do
    expect(finding.type).to(eq(:github_token))
  end

  it('should expose the description') do
    expect(finding.description).to(eq('GitHub Personal Access Token'))
  end

  it('should expose the severity') do
    expect(finding.severity).to(eq(:high))
  end

  it('should expose the masked matched text') do
    expect(finding.matched_text).to(eq('ghp_****'))
  end

  it('should expose the full line') do
    expect(finding.full_line).to(include('ghp_'))
  end

  # MARK: addition?

  it('should return false for addition? by default') do
    expect(finding.addition?).to(eq(false))
  end

  it('should return true for addition? when is_addition was set to true') do
    expect(addition_finding.addition?).to(eq(true))
  end

  # MARK: to_s

  it('should include the file path in the string representation') do
    expect(finding.to_s).to(include('lib/config.rb'))
  end

  it('should include the line number in the string representation') do
    expect(finding.to_s).to(include('12'))
  end

  it('should include the type in the string representation') do
    expect(finding.to_s).to(include('github_token'))
  end

  it('should include the masked text in the string representation') do
    expect(finding.to_s).to(include('ghp_****'))
  end

  it('should include a severity icon in the string representation') do
    expect(finding.to_s).to(include('🟠')) # :high icon
  end

  it('should include the critical icon for critical severity') do
    expect(addition_finding.to_s).to(include('🔴'))
  end

  # MARK: to_h

  it('should return a hash with all expected keys') do
    hash = finding.to_h

    expect(hash).to(have_key(:file))
    expect(hash).to(have_key(:line))
    expect(hash).to(have_key(:column))
    expect(hash).to(have_key(:type))
    expect(hash).to(have_key(:description))
    expect(hash).to(have_key(:severity))
    expect(hash).to(have_key(:matched_text))
    expect(hash).to(have_key(:full_line))
    expect(hash).to(have_key(:is_addition))
  end

  it('should return the correct values in the hash') do
    hash = finding.to_h

    expect(hash[:file]).to(eq('lib/config.rb'))
    expect(hash[:line]).to(eq(12))
    expect(hash[:type]).to(eq(:github_token))
    expect(hash[:severity]).to(eq(:high))
    expect(hash[:is_addition]).to(eq(false))
  end

  it('should reflect is_addition: true in the hash') do
    expect(addition_finding.to_h[:is_addition]).to(eq(true))
  end
end
