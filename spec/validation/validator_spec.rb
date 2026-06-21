require 'validation/validator'

describe(SecureKeys::Validation::Validator) do
  let(:validator) { described_class.new }

  # MARK: validate: empty value

  it('should return an error issue when the value is empty') do
    # when
    result = validator.validate(key: :api_key, value: '')

    # then
    expect(result.errors?).to(eq(true))
    expect(result.valid?).to(eq(false))
  end

  it('should return an error issue when the value is nil-like (empty string)') do
    # when
    result = validator.validate(key: :myToken, value: '')

    # then
    issue = result.issues.find { |i| i.type == :empty_value }
    expect(issue).not_to(be_nil)
    expect(issue.severity).to(eq(:error))
  end

  # MARK: validate: weak secret

  it('should return a critical issue for a common weak value') do
    # when
    result = validator.validate(key: :apiKey, value: 'password')

    # then
    expect(result.critical?).to(eq(true))
    issue = result.issues.find { |i| i.type == :weak_secret }
    expect(issue).not_to(be_nil)
  end

  it('should return a critical issue when the value contains a weak substring') do
    # when
    result = validator.validate(key: :apiKey, value: 'password123')

    # then
    expect(result.critical?).to(eq(true))
  end

  it('should return a critical issue for the placeholder value "test"') do
    # when
    result = validator.validate(key: :mySecret, value: 'test')

    # then
    expect(result.critical?).to(eq(true))
  end

  # MARK: validate: minimum length

  it('should return a warning when the value is shorter than the minimum for its type') do
    # given — api_key minimum is 20 chars
    result = validator.validate(key: :api_key, value: 'short')

    # then
    expect(result.warnings?).to(eq(true))
    issue = result.issues.find { |i| i.type == :too_short }
    expect(issue).not_to(be_nil)
    expect(issue.severity).to(eq(:warning))
  end

  it('should infer api_key type for a key name containing "api" and "key"') do
    # given — api_key minimum is 20 chars; value is 5 chars
    result = validator.validate(key: :my_api_key, value: 'short')

    # then
    expect(result.warnings?).to(eq(true))
  end

  it('should infer token type for a key name containing "token"') do
    # given — token minimum is 20 chars; value is 5 chars
    result = validator.validate(key: :githubToken, value: 'short')

    # then
    expect(result.warnings?).to(eq(true))
  end

  it('should infer password type for a key name containing "password"') do
    # given — password minimum is 12 chars; value is 5 chars
    result = validator.validate(key: :adminPassword, value: 'short')

    # then
    expect(result.warnings?).to(eq(true))
  end

  # MARK: validate: good value

  it('should be valid for a long, non-weak, non-patterned value') do
    # given
    value = 'a_very_long_and_unpredictable_api_key_that_is_definitely_fine_123'

    # when
    result = validator.validate(key: :api_key, value:)

    # then
    expect(result.valid?).to(eq(true))
    expect(result.severity_level).to(eq(:ok))
  end

  it('should produce no issues for a strong value') do
    # given
    value = 'a_very_long_and_unpredictable_api_key_that_is_definitely_fine_123'

    # when
    result = validator.validate(key: :api_key, value:)

    # then
    expect(result.issues).to(be_empty)
  end

  # MARK: validate: production key detection

  it('should return a critical issue for a live Stripe key when production is not allowed') do
    # given
    stripe_key = "sk_live_51H#{'a' * 24}"

    # when
    result = validator.validate(key: :stripeKey, value: stripe_key)

    # then
    expect(result.critical?).to(eq(true))
    issue = result.issues.find { |i| i.type == :production_key_detected }
    expect(issue).not_to(be_nil)
  end

  it('should not flag a critical pattern when allow_production option is true') do
    # given
    stripe_key = "sk_live_51H#{'a' * 24}"

    # when
    result = validator.validate(key: :stripeKey, value: stripe_key, options: { allow_production: true })

    # then
    production_issue = result.issues.find { |i| i.type == :production_key_detected }
    expect(production_issue).to(be_nil)
  end

  it('should emit an informational issue when warn_on_pattern option is true') do
    # given — publishable key is :medium severity, so it won't hit the critical path
    stripe_publishable_key = "pk_test_51H#{'a' * 24}"

    # when
    result = validator.validate(key: :stripeKey, value: stripe_publishable_key, options: { warn_on_pattern: true })

    # then
    pattern_issue = result.issues.find { |i| i.type == :pattern_detected }
    expect(pattern_issue).not_to(be_nil)
    expect(pattern_issue.severity).to(eq(:info))
  end

  # MARK: validate: entropy check

  it('should return a warning for a low-entropy value when check_entropy is enabled') do
    # given — 'aaaaaaaaaaaaaaaaaaaaaa' is long but has zero entropy
    result = validator.validate(
      key: :api_key,
      value: 'a' * 30,
      options: { check_entropy: true }
    )

    # then
    entropy_issue = result.issues.find { |i| i.type == :low_entropy }
    expect(entropy_issue).not_to(be_nil)
  end

  it('should not check entropy when the option is not set') do
    # given
    result = validator.validate(key: :api_key, value: 'a' * 30)

    # then
    entropy_issue = result.issues.find { |i| i.type == :low_entropy }
    expect(entropy_issue).to(be_nil)
  end

  # MARK: detect_type

  it('should return nil when no pattern matches') do
    expect(validator.detect_type(value: 'not-a-secret')).to(be_nil)
  end

  it('should detect a GitHub personal access token') do
    # given — 36 alphanumeric chars after prefix
    token = "ghp_#{'a' * 36}"

    # when
    result = validator.detect_type(value: token)

    # then
    expect(result).not_to(be_nil)
    expect(result[:type]).to(eq(:github_token))
  end

  it('should detect an AWS access key') do
    # given
    key = 'AKIAIOSFODNN7EXAMPLE'

    # when
    result = validator.detect_type(value: key)

    # then
    expect(result).not_to(be_nil)
    expect(result[:type]).to(eq(:aws_access_key))
  end

  it('should detect a Stripe secret key') do
    # given
    key = "sk_live_51H#{'a' * 24}"

    # when
    result = validator.detect_type(value: key)

    # then
    expect(result).not_to(be_nil)
    expect(result[:type]).to(eq(:stripe_secret_key))
  end

  it('should detect a Google Cloud API key') do
    result = validator.detect_type(value: 'AIzaSyDaGmWKa4JsXZ-HjGw7ISLn_3namBGewQe')
    expect(result[:type]).to(eq(:gcp_api_key))
  end

  it('should include the :type key in the detect_type result') do
    result = validator.detect_type(value: 'AKIAIOSFODNN7EXAMPLE')
    expect(result).to(have_key(:type))
    expect(result).to(have_key(:description))
    expect(result).to(have_key(:severity))
  end

  # MARK: recommendations

  it('should return GitHub recommendations for a key named githubToken') do
    # when
    recs = validator.recommendations(key: :githubToken)

    # then
    expect(recs).not_to(be_empty)
    expect(recs.any? { |r| r.downcase.include?('github') }).to(eq(true))
  end

  it('should return AWS recommendations for a key named awsAccessKey') do
    # when
    recs = validator.recommendations(key: :awsAccessKey)

    # then
    expect(recs).not_to(be_empty)
    expect(recs.any? { |r| r.downcase.include?('aws') }).to(eq(true))
  end

  it('should return Stripe recommendations for a key named stripeSecretKey') do
    # when
    recs = validator.recommendations(key: :stripeSecretKey)

    # then
    expect(recs).not_to(be_empty)
    expect(recs.any? { |r| r.downcase.include?('stripe') }).to(eq(true))
  end

  it('should return generic rotation recommendations for a key named apiKey') do
    # when
    recs = validator.recommendations(key: :apiKey)

    # then
    expect(recs).not_to(be_empty)
    expect(recs.any? { |r| r.downcase.include?('rotat') }).to(eq(true))
  end

  it('should return an empty array for a key name with no recognizable provider or type') do
    # given — no "github", "aws", "stripe", "api", or "key" substring
    expect(validator.recommendations(key: :databaseHost)).to(be_empty)
  end
end
