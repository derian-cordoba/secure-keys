require 'validation/utils/patterns'

describe(SecureKeys::Validation) do
  subject(:patterns) { described_class::PATTERNS }

  it('should be frozen') do
    expect(patterns).to(be_frozen)
  end

  it('should not be empty') do
    expect(patterns).not_to(be_empty)
  end

  it('should have required keys on every entry') do
    patterns.each do |type, config|
      expect(config.keys).to(include(:pattern, :description, :severity),
                             "#{type} is missing one or more required keys")
    end
  end

  it('should have a Regexp as the :pattern value on every entry') do
    patterns.each do |type, config|
      expect(config[:pattern]).to(be_a(Regexp),
                                  "#{type} :pattern is not a Regexp, got #{config[:pattern].class}")
    end
  end

  it('should have a valid severity symbol on every entry') do
    valid_severities = %i[low medium high critical]

    patterns.each do |type, config|
      expect(valid_severities).to(include(config[:severity]),
                                  "#{type} has unknown severity: #{config[:severity]}")
    end
  end

  # MARK: Provider-specific pattern smoke tests

  it('should detect a GitHub personal access token') do
    # given — 36 alphanumeric chars after prefix
    token = "ghp_#{'a' * 36}"

    # when / then
    expect(token).to(match(patterns[:github_token][:pattern]))
  end

  it('should detect a GitHub OAuth access token') do
    token = "gho_#{'a' * 36}"
    expect(token).to(match(patterns[:github_oauth][:pattern]))
  end

  it('should detect a GitHub App token') do
    token = "ghu_#{'a' * 36}"
    expect(token).to(match(patterns[:github_app][:pattern]))
  end

  it('should detect an AWS access key ID') do
    # given — AKIA followed by 16 uppercase alphanumeric chars
    key = 'AKIAIOSFODNN7EXAMPLE'
    expect(key).to(match(patterns[:aws_access_key][:pattern]))
  end

  it('should detect a Google Cloud API key') do
    key = 'AIzaSyDaGmWKa4JsXZ-HjGw7ISLn_3namBGewQe'
    expect(key).to(match(patterns[:gcp_api_key][:pattern]))
  end

  it('should detect a Stripe secret key') do
    key = "sk_live_51H#{'a' * 24}"
    expect(key).to(match(patterns[:stripe_secret_key][:pattern]))
  end

  it('should detect a Stripe test key') do
    key = "sk_test_51H#{'a' * 24}"
    expect(key).to(match(patterns[:stripe_secret_key][:pattern]))
  end

  it('should detect a Slack bot token') do
    token = "xoxb-123456789012-123456789012-#{'a' * 18}"
    expect(token).to(match(patterns[:slack_token][:pattern]))
  end

  it('should detect a JWT token') do
    token = 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.signature'
    expect(token).to(match(patterns[:jwt_token][:pattern]))
  end

  it('should detect a PEM private key header') do
    header = '-----BEGIN PRIVATE KEY-----'
    expect(header).to(match(patterns[:private_key][:pattern]))
  end

  it('should detect an RSA private key header') do
    header = '-----BEGIN RSA PRIVATE KEY-----'
    expect(header).to(match(patterns[:private_key][:pattern]))
  end

  it('should detect a SendGrid API key') do
    key = "SG.#{'a' * 22}.#{'b' * 43}"
    expect(key).to(match(patterns[:sendgrid_api_key][:pattern]))
  end

  it('should not match a plain string against a GitHub token pattern') do
    expect('not_a_token').not_to(match(patterns[:github_token][:pattern]))
  end

  it('should not match a short string against an AWS access key pattern') do
    expect('AKIA123').not_to(match(patterns[:aws_access_key][:pattern]))
  end
end
