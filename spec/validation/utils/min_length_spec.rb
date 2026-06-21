require 'validation/utils/min_length'

describe(SecureKeys::Validation) do
  subject(:min_lengths) { described_class::MIN_LENGTHS }

  it('should be a Hash') do
    expect(min_lengths).to(be_a(Hash))
  end

  it('should be frozen') do
    expect(min_lengths).to(be_frozen)
  end

  it('should contain all expected key type entries') do
    expect(min_lengths).to(have_key(:api_key))
    expect(min_lengths).to(have_key(:token))
    expect(min_lengths).to(have_key(:secret))
    expect(min_lengths).to(have_key(:password))
    expect(min_lengths).to(have_key(:key))
  end

  it('should have Integer values for every entry') do
    min_lengths.each_value do |length|
      expect(length).to(be_a(Integer))
    end
  end

  it('should have positive length values for every entry') do
    min_lengths.each_value do |length|
      expect(length).to(be > 0)
    end
  end

  it('should set the api_key minimum length to the default') do
    # given
    expected_length = SecureKeys::Validation::Globals.api_key_length

    # when / then
    expect(min_lengths[:api_key]).to(eq(expected_length))
  end

  it('should set the token minimum length to the default') do
    expected_length = SecureKeys::Validation::Globals.token_length
    expect(min_lengths[:token]).to(eq(expected_length))
  end

  it('should set the secret minimum length to the default') do
    expected_length = SecureKeys::Validation::Globals.secret_length
    expect(min_lengths[:secret]).to(eq(expected_length))
  end

  it('should set the password minimum length to the default') do
    expected_length = SecureKeys::Validation::Globals.password_length
    expect(min_lengths[:password]).to(eq(expected_length))
  end

  it('should set the key minimum length to the default') do
    expected_length = SecureKeys::Validation::Globals.key_length
    expect(min_lengths[:key]).to(eq(expected_length))
  end
end
