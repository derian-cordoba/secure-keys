require 'core/environment/ci'
require 'core/globals/globals'

describe(SecureKeys::Core::Environment::CI) do
  let(:environment) { described_class.new }

  after(:each) do
    %w[
      API_KEY
      GITHUB_TOKEN
      SECURE_KEYS_FIREBASE_TOKEN
      SECURE_KEYS_IDENTIFIER
      SECURE_KEYS_DELIMITER
      CUSTOM_SECRET_LIST
    ].each { |key| ENV.delete(key) }
  end

  it('fetches exact environment variable names') do
    ENV['CUSTOM_SECRET_LIST'] = 'apiKey,github-token'

    expect(environment.fetch(key: 'CUSTOM_SECRET_LIST')).to(eq('apiKey,github-token'))
  end

  it('fetches normalized secret keys') do
    ENV['GITHUB_TOKEN'] = 'github-token-value'

    expect(environment.fetch(key: 'github-token')).to(eq('github-token-value'))
  end

  it('fetches secure keys prefixed normalized secret keys') do
    ENV['SECURE_KEYS_FIREBASE_TOKEN'] = 'firebase-token-value'

    expect(environment.fetch(key: 'firebase-token')).to(eq('firebase-token-value'))
  end

  it('allows inline identifier values for documented CI usage') do
    ENV['SECURE_KEYS_IDENTIFIER'] = 'github-token,api_key'

    expect(environment.fetch(key: 'github-token,api_key')).to(eq('github-token,api_key'))
  end
end
