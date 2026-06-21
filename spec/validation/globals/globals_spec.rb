require 'validation/globals/globals'

describe(SecureKeys::Validation::Globals) do
  before(:each) do
    %w[
      API_KEY_LENGTH SECURE_KEYS_API_KEY_LENGTH
      TOKEN_LENGTH SECURE_KEYS_TOKEN_LENGTH
      SECRET_LENGTH SECURE_KEYS_SECRET_LENGTH
      PASSWORD_LENGTH SECURE_KEYS_PASSWORD_LENGTH
      KEY_LENGTH SECURE_KEYS_KEY_LENGTH
      SCAN_EXTENSIONS SECURE_KEYS_SCAN_EXTENSIONS
      SCAN_EXCLUDES SECURE_KEYS_SCAN_EXCLUDES
      MAX_SCAN_DEPTH SECURE_KEYS_MAX_SCAN_DEPTH
      MIN_ENTROPY_THRESHOLD SECURE_KEYS_MIN_ENTROPY_THRESHOLD
    ].each { |key| ENV.delete(key) }
  end

  # MARK: Length defaults

  it('should return the default minimum API key length') do
    # given
    expected_length = 20

    # when / then
    expect(described_class.api_key_length).to(eq(expected_length))
  end

  it('should return the default minimum token length') do
    # given
    expected_length = 20

    # when / then
    expect(described_class.token_length).to(eq(expected_length))
  end

  it('should return the default minimum secret length') do
    # given
    expected_length = 16

    # when / then
    expect(described_class.secret_length).to(eq(expected_length))
  end

  it('should return the default minimum password length') do
    # given
    expected_length = 12

    # when / then
    expect(described_class.password_length).to(eq(expected_length))
  end

  it('should return the default minimum key length') do
    # given
    expected_length = 16

    # when / then
    expect(described_class.key_length).to(eq(expected_length))
  end

  # MARK: Length env var overrides

  it('should return the API key length from the environment (SECURE_KEYS prefix)') do
    # given
    expected_length = 32

    # when
    ENV['SECURE_KEYS_API_KEY_LENGTH'] = expected_length.to_s

    # then
    expect(described_class.api_key_length).to(eq(expected_length))
  end

  it('should return the API key length from the environment (no prefix)') do
    # given
    expected_length = 40

    # when
    ENV['API_KEY_LENGTH'] = expected_length.to_s

    # then
    expect(described_class.api_key_length).to(eq(expected_length))
  end

  it('should return the token length from the environment') do
    # given
    expected_length = 24

    # when
    ENV['SECURE_KEYS_TOKEN_LENGTH'] = expected_length.to_s

    # then
    expect(described_class.token_length).to(eq(expected_length))
  end

  it('should return the secret length from the environment') do
    # given
    expected_length = 24

    # when
    ENV['SECURE_KEYS_SECRET_LENGTH'] = expected_length.to_s

    # then
    expect(described_class.secret_length).to(eq(expected_length))
  end

  it('should return the password length from the environment') do
    # given
    expected_length = 20

    # when
    ENV['SECURE_KEYS_PASSWORD_LENGTH'] = expected_length.to_s

    # then
    expect(described_class.password_length).to(eq(expected_length))
  end

  it('should return the key length from the environment') do
    # given
    expected_length = 24

    # when
    ENV['SECURE_KEYS_KEY_LENGTH'] = expected_length.to_s

    # then
    expect(described_class.key_length).to(eq(expected_length))
  end

  # MARK: Scan configuration defaults

  it('should return the default file extensions as an array') do
    # when
    extensions = described_class.default_scan_extensions

    # then
    expect(extensions).to(be_a(Array))
    expect(extensions).to(include('.swift', '.rb', '.py', '.js'))
    expect(extensions).not_to(be_empty)
  end

  it('should return the default scan excludes as an array') do
    # when
    excludes = described_class.default_scan_excludes

    # then
    expect(excludes).to(be_a(Array))
    expect(excludes).to(include('.git', 'node_modules', 'Pods'))
    expect(excludes).not_to(be_empty)
  end

  it('should return the default maximum scan depth') do
    # given
    expected_depth = 10

    # when / then
    expect(described_class.max_scan_depth).to(eq(expected_depth))
  end

  it('should return the default minimum entropy threshold') do
    # given
    expected_threshold = 3.0

    # when / then
    expect(described_class.min_entropy_threshold).to(eq(expected_threshold))
  end

  # MARK: Scan configuration env var overrides

  it('should return custom scan extensions from the environment') do
    # given
    expected_extensions = %w[.rb .go]

    # when
    ENV['SECURE_KEYS_SCAN_EXTENSIONS'] = expected_extensions.join(',')

    # then
    expect(described_class.default_scan_extensions).to(eq(expected_extensions))
  end

  it('should return custom scan excludes from the environment') do
    # given
    expected_excludes = %w[vendor tmp]

    # when
    ENV['SECURE_KEYS_SCAN_EXCLUDES'] = expected_excludes.join(',')

    # then
    expect(described_class.default_scan_excludes).to(eq(expected_excludes))
  end

  it('should return a custom maximum scan depth from the environment') do
    # given
    expected_depth = 5

    # when
    ENV['SECURE_KEYS_MAX_SCAN_DEPTH'] = expected_depth.to_s

    # then
    expect(described_class.max_scan_depth).to(eq(expected_depth))
  end

  it('should return a custom entropy threshold from the environment') do
    # given
    expected_threshold = 4.5

    # when
    ENV['SECURE_KEYS_MIN_ENTROPY_THRESHOLD'] = expected_threshold.to_s

    # then
    expect(described_class.min_entropy_threshold).to(eq(expected_threshold))
  end
end
