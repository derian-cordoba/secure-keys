require 'validation/models/finding'
require 'validation/models/scan_result'

describe(SecureKeys::Validation::ScanResult) do
  def build_finding(severity: :high)
    SecureKeys::Validation::Finding.new(
      file: 'lib/config.rb',
      line: 1,
      column: 0,
      type: :github_token,
      description: 'GitHub Personal Access Token',
      severity:,
      matched_text: 'ghp_****',
      full_line: "token = 'ghp_abc'"
    )
  end

  let(:high_finding)     { build_finding(severity: :high) }
  let(:critical_finding) { build_finding(severity: :critical) }
  let(:medium_finding)   { build_finding(severity: :medium) }

  # MARK: Readers

  it('should expose the findings array') do
    result = described_class.new(findings: [high_finding], files_count: 5)
    expect(result.findings).to(eq([high_finding]))
  end

  it('should expose the files count') do
    result = described_class.new(findings: [], files_count: 10)
    expect(result.files_count).to(eq(10))
  end

  # MARK: clean?

  it('should be clean when there are no findings') do
    result = described_class.new(findings: [], files_count: 3)
    expect(result.clean?).to(eq(true))
  end

  it('should not be clean when findings are present') do
    result = described_class.new(findings: [high_finding], files_count: 3)
    expect(result.clean?).to(eq(false))
  end

  # MARK: by_severity

  it('should return findings matching the requested severity') do
    # given
    result = described_class.new(findings: [high_finding, critical_finding], files_count: 2)

    # when
    high_findings = result.by_severity(severity: :high)

    # then
    expect(high_findings.length).to(eq(1))
    expect(high_findings.first.severity).to(eq(:high))
  end

  it('should return an empty array when no findings match the requested severity') do
    result = described_class.new(findings: [high_finding], files_count: 1)
    expect(result.by_severity(severity: :critical)).to(be_empty)
  end

  it('should correctly separate findings by severity when multiple severities are present') do
    # given
    result = described_class.new(
      findings: [high_finding, critical_finding, medium_finding],
      files_count: 3
    )

    # when / then
    expect(result.by_severity(severity: :high).length).to(eq(1))
    expect(result.by_severity(severity: :critical).length).to(eq(1))
    expect(result.by_severity(severity: :medium).length).to(eq(1))
    expect(result.by_severity(severity: :low).length).to(eq(0))
  end

  # MARK: to_h

  it('should return a hash with the expected top-level keys') do
    result = described_class.new(findings: [high_finding], files_count: 5)
    hash = result.to_h

    expect(hash).to(have_key(:files_scanned))
    expect(hash).to(have_key(:total_findings))
    expect(hash).to(have_key(:by_severity))
    expect(hash).to(have_key(:findings))
  end

  it('should reflect the correct file and finding counts in the hash') do
    # given
    result = described_class.new(findings: [high_finding, critical_finding], files_count: 7)

    # when
    hash = result.to_h

    # then
    expect(hash[:files_scanned]).to(eq(7))
    expect(hash[:total_findings]).to(eq(2))
  end

  it('should include severity breakdown counts in the hash') do
    result = described_class.new(findings: [high_finding, critical_finding], files_count: 2)
    hash = result.to_h

    expect(hash[:by_severity][:high]).to(eq(1))
    expect(hash[:by_severity][:critical]).to(eq(1))
    expect(hash[:by_severity][:medium]).to(eq(0))
    expect(hash[:by_severity][:low]).to(eq(0))
  end

  it('should include serialized findings in the hash') do
    result = described_class.new(findings: [high_finding], files_count: 1)
    hash = result.to_h

    expect(hash[:findings]).to(be_a(Array))
    expect(hash[:findings].first).to(have_key(:file))
    expect(hash[:findings].first).to(have_key(:severity))
  end

  it('should return an empty findings array in the hash when there are no findings') do
    result = described_class.new(findings: [], files_count: 5)
    expect(result.to_h[:findings]).to(be_empty)
    expect(result.to_h[:total_findings]).to(eq(0))
  end
end
