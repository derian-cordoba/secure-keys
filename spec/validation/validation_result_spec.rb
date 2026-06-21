require 'validation/validation_result'
require 'validation/validation_issue'

describe(SecureKeys::Validation::ValidationResult) do
  let(:critical_issue) do
    SecureKeys::Validation::ValidationIssue.new(
      severity: :critical,
      type: :weak_secret,
      message: 'Weak secret detected',
      recommendation: 'Use a stronger secret'
    )
  end

  let(:error_issue) do
    SecureKeys::Validation::ValidationIssue.new(
      severity: :error,
      type: :empty_value,
      message: 'Value is empty',
      recommendation: 'Provide a non-empty value'
    )
  end

  let(:warning_issue) do
    SecureKeys::Validation::ValidationIssue.new(
      severity: :warning,
      type: :too_short,
      message: 'Value is too short',
      recommendation: 'Use a longer value'
    )
  end

  let(:detected_type) do
    { type: :github_token, description: 'GitHub Personal Access Token', severity: :high }
  end

  def build_result(issues: [], detected_type: nil)
    described_class.new(key: :api_key, value: 'some_value', issues:, detected_type:)
  end

  # MARK: valid?

  it('should be valid when there are no issues') do
    result = build_result
    expect(result.valid?).to(eq(true))
  end

  it('should not be valid when there is a critical issue') do
    result = build_result(issues: [critical_issue])
    expect(result.valid?).to(eq(false))
  end

  it('should not be valid when there is an error issue') do
    result = build_result(issues: [error_issue])
    expect(result.valid?).to(eq(false))
  end

  it('should be valid when there are only warnings') do
    result = build_result(issues: [warning_issue])
    expect(result.valid?).to(eq(true))
  end

  # MARK: critical? / errors? / warnings?

  it('should return true for critical? when a critical issue is present') do
    result = build_result(issues: [critical_issue])
    expect(result.critical?).to(eq(true))
  end

  it('should return false for critical? when no critical issue is present') do
    result = build_result(issues: [error_issue])
    expect(result.critical?).to(eq(false))
  end

  it('should return true for errors? when an error issue is present') do
    result = build_result(issues: [error_issue])
    expect(result.errors?).to(eq(true))
  end

  it('should return false for errors? when no error issue is present') do
    result = build_result(issues: [warning_issue])
    expect(result.errors?).to(eq(false))
  end

  it('should return true for warnings? when a warning issue is present') do
    result = build_result(issues: [warning_issue])
    expect(result.warnings?).to(eq(true))
  end

  it('should return false for warnings? when no warning issue is present') do
    result = build_result
    expect(result.warnings?).to(eq(false))
  end

  # MARK: severity_level

  it('should return :ok when there are no issues') do
    expect(build_result.severity_level).to(eq(:ok))
  end

  it('should return :warning when only warnings are present') do
    expect(build_result(issues: [warning_issue]).severity_level).to(eq(:warning))
  end

  it('should return :error when an error is present') do
    expect(build_result(issues: [error_issue]).severity_level).to(eq(:error))
  end

  it('should return :critical when a critical issue is present') do
    expect(build_result(issues: [critical_issue]).severity_level).to(eq(:critical))
  end

  it('should return :critical when both critical and error issues are present') do
    result = build_result(issues: [critical_issue, error_issue])
    expect(result.severity_level).to(eq(:critical))
  end

  # MARK: summary

  it('should include a pass indicator in the summary when valid') do
    result = build_result
    expect(result.summary).to(include('✅'))
  end

  it('should include the key name in the summary') do
    result = build_result
    expect(result.summary).to(include('api_key'))
  end

  it('should include the issue count in the summary when invalid') do
    # given
    result = build_result(issues: [critical_issue, warning_issue])

    # when
    summary = result.summary

    # then
    expect(summary).to(include('2'))
  end

  # MARK: detected_type

  it('should expose the detected type when provided') do
    result = build_result(detected_type:)
    expect(result.detected_type).to(eq(detected_type))
  end

  it('should expose nil when no detected type was provided') do
    result = build_result
    expect(result.detected_type).to(be_nil)
  end

  # MARK: to_h

  it('should return a hash with the expected top-level keys') do
    # when
    hash = build_result(issues: [warning_issue]).to_h

    # then
    expect(hash).to(have_key(:key))
    expect(hash).to(have_key(:valid))
    expect(hash).to(have_key(:severity))
    expect(hash).to(have_key(:detected_type))
    expect(hash).to(have_key(:issues))
  end

  it('should reflect the correct valid flag in the hash') do
    expect(build_result.to_h[:valid]).to(eq(true))
    expect(build_result(issues: [error_issue]).to_h[:valid]).to(eq(false))
  end

  it('should include serialized issues in the hash') do
    # when
    hash = build_result(issues: [warning_issue]).to_h

    # then
    expect(hash[:issues]).to(be_a(Array))
    expect(hash[:issues].first).to(have_key(:severity))
    expect(hash[:issues].first).to(have_key(:message))
  end

  # MARK: print

  it('should not raise when printing a valid result') do
    result = build_result
    expect { result.print }.not_to(raise_error)
  end

  it('should not raise when printing an invalid result with detected type') do
    result = build_result(issues: [critical_issue], detected_type:)
    expect { result.print }.not_to(raise_error)
  end
end
