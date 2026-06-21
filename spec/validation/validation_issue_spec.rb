require 'validation/validation_issue'

describe(SecureKeys::Validation::ValidationIssue) do
  let(:issue) do
    described_class.new(
      severity: :warning,
      type: :too_short,
      message: 'Key is too short',
      recommendation: 'Use a longer secret'
    )
  end

  let(:issue_without_recommendation) do
    described_class.new(
      severity: :info,
      type: :pattern_detected,
      message: 'Pattern matched',
      recommendation: nil
    )
  end

  # MARK: Initialization

  it('should expose the severity') do
    expect(issue.severity).to(eq(:warning))
  end

  it('should expose the type') do
    expect(issue.type).to(eq(:too_short))
  end

  it('should expose the message') do
    expect(issue.message).to(eq('Key is too short'))
  end

  it('should expose the recommendation') do
    expect(issue.recommendation).to(eq('Use a longer secret'))
  end

  it('should expose a nil recommendation when none was given') do
    expect(issue_without_recommendation.recommendation).to(be_nil)
  end

  # MARK: to_s

  it('should include the severity in the string representation') do
    expect(issue.to_s).to(include('WARNING'))
  end

  it('should include the message in the string representation') do
    expect(issue.to_s).to(include('Key is too short'))
  end

  it('should include the recommendation in the string representation when present') do
    expect(issue.to_s).to(include('Use a longer secret'))
  end

  it('should not include a recommendation line when the recommendation is nil') do
    expect(issue_without_recommendation.to_s).not_to(include('💡'))
  end

  # MARK: Severity icons

  it('should use the critical icon for critical severity') do
    # given
    critical_issue = described_class.new(severity: :critical, type: :t, message: 'm', recommendation: nil)

    # when / then
    expect(critical_issue.to_s).to(include('🔴'))
  end

  it('should use the error icon for error severity') do
    # given
    error_issue = described_class.new(severity: :error, type: :t, message: 'm', recommendation: nil)

    # when / then
    expect(error_issue.to_s).to(include('❌'))
  end

  it('should use the warning icon for warning severity') do
    expect(issue.to_s).to(include('⚠️'))
  end

  it('should use the info icon for info severity') do
    expect(issue_without_recommendation.to_s).to(include('ℹ️'))
  end

  # MARK: to_h

  it('should return a hash with all expected keys') do
    # when
    hash = issue.to_h

    # then
    expect(hash).to(have_key(:severity))
    expect(hash).to(have_key(:type))
    expect(hash).to(have_key(:message))
    expect(hash).to(have_key(:recommendation))
  end

  it('should return the correct values in the hash') do
    # when
    hash = issue.to_h

    # then
    expect(hash[:severity]).to(eq(:warning))
    expect(hash[:type]).to(eq(:too_short))
    expect(hash[:message]).to(eq('Key is too short'))
    expect(hash[:recommendation]).to(eq('Use a longer secret'))
  end
end
