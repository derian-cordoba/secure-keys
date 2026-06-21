require 'environment/models/environment_config'

describe(SecureKeys::Environment::EnvironmentConfig) do
  # MARK: Initialization

  it('should set all attributes from named parameters') do
    # given / when
    config = described_class.new(
      name: 'production',
      identifier: 'secure-keys-prod',
      delimiter: '|',
      source: 'environment',
      keys: %w[apiKey analyticsKey],
      output: '.secure-keys/production'
    )

    # then
    expect(config.name).to(eq('production'))
    expect(config.identifier).to(eq('secure-keys-prod'))
    expect(config.delimiter).to(eq('|'))
    expect(config.source).to(eq('environment'))
    expect(config.keys).to(eq(%w[apiKey analyticsKey]))
    expect(config.output).to(eq('.secure-keys/production'))
  end

  it('should use default delimiter and output when not provided') do
    # given / when
    config = described_class.new(name: 'staging', identifier: 'secure-keys-staging')

    # then
    expect(config.delimiter).to(eq(','))
    expect(config.output).to(eq('.secure-keys/staging'))
  end

  it('should default source to keychain') do
    # given / when
    config = described_class.new(name: 'development', identifier: 'secure-keys-dev')

    # then
    expect(config.source).to(eq('keychain'))
  end

  # MARK: from_hash

  it('should build from a raw YAML hash using from_hash') do
    # given
    data = {
      'identifier' => 'my-app-prod',
      'delimiter' => ',',
      'source' => 'environment',
      'keys' => %w[apiKey stripeKey],
      'output' => '.secure-keys/production'
    }

    # when
    config = described_class.from_hash(name: 'production', data:)

    # then
    expect(config.name).to(eq('production'))
    expect(config.identifier).to(eq('my-app-prod'))
    expect(config.keys).to(eq(%w[apiKey stripeKey]))
  end

  it('should fall back to sensible defaults when hash values are missing') do
    # given / when
    config = described_class.from_hash(name: 'development', data: {})

    # then
    expect(config.identifier).to(eq('secure-keys-development'))
    expect(config.delimiter).to(eq(','))
    expect(config.source).to(eq('keychain'))
    expect(config.keys).to(eq([]))
    expect(config.output).to(eq('.secure-keys/development'))
  end

  # MARK: ci_mode?

  it('should return true when source is environment') do
    # given
    config = described_class.new(name: 'production', identifier: 'prod', source: 'environment')

    # then
    expect(config.ci_mode?).to(be(true))
  end

  it('should return false when source is keychain') do
    # given
    config = described_class.new(name: 'development', identifier: 'dev', source: 'keychain')

    # then
    expect(config.ci_mode?).to(be(false))
  end

  # MARK: to_h

  it('should serialize all fields to a hash') do
    # given
    config = described_class.new(
      name: 'staging',
      identifier: 'secure-keys-staging',
      delimiter: ',',
      source: 'environment',
      keys: %w[apiKey],
      output: '.secure-keys/staging'
    )

    # when
    result = config.to_h

    # then
    expect(result[:name]).to(eq('staging'))
    expect(result[:identifier]).to(eq('secure-keys-staging'))
    expect(result[:source]).to(eq('environment'))
    expect(result[:keys]).to(eq(%w[apiKey]))
  end
end
