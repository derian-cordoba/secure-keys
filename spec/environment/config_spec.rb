require 'tmpdir'
require 'fileutils'
require 'environment/config'

describe(SecureKeys::Environment::Config) do
  let(:temp_dir) { Dir.mktmpdir('secure_keys_env_config_spec') }
  let(:config_path) { File.join(temp_dir, '.secure-keys.yml') }

  after(:each) do
    FileUtils.rm_rf(temp_dir)
  end

  # MARK: create_default

  it('should write the default YAML template to disk') do
    # when
    path = described_class.create_default(path: config_path)

    # then
    expect(File.exist?(path)).to(be(true))
    expect(File.read(path)).to(include('environments:'))
    expect(File.read(path)).to(include('development:'))
    expect(File.read(path)).to(include('staging:'))
    expect(File.read(path)).to(include('production:'))
  end

  it('should return the path of the written file from create_default') do
    # when
    result = described_class.create_default(path: config_path)

    # then
    expect(result).to(eq(config_path))
  end

  # MARK: Loading environments

  it('should load all environments from a valid YAML file') do
    # given
    described_class.create_default(path: config_path)

    # when
    config = described_class.new(path: config_path)

    # then
    expect(config.environment_names).to(include('development', 'staging', 'production'))
  end

  it('should parse environment attributes correctly') do
    # given
    described_class.create_default(path: config_path)

    # when
    config = described_class.new(path: config_path)
    dev = config.get(name: 'development')

    # then
    expect(dev.identifier).to(eq('secure-keys-dev'))
    expect(dev.source).to(eq('keychain'))
    expect(dev.keys).to(include('apiKey'))
  end

  it('should return an empty environments hash when the file does not exist') do
    # when
    config = described_class.new(path: config_path)

    # then
    expect(config.environments).to(be_empty)
  end

  # MARK: exists?

  it('should return true when the config file exists') do
    # given
    described_class.create_default(path: config_path)

    # when
    config = described_class.new(path: config_path)

    # then
    expect(config.exists?).to(be(true))
  end

  it('should return false when the config file does not exist') do
    # when
    config = described_class.new(path: config_path)

    # then
    expect(config.exists?).to(be(false))
  end

  # MARK: get

  it('should return the correct EnvironmentConfig for a valid name') do
    # given
    described_class.create_default(path: config_path)
    config = described_class.new(path: config_path)

    # when
    env = config.get(name: 'production')

    # then
    expect(env.name).to(eq('production'))
    expect(env.source).to(eq('environment'))
  end

  it('should raise an Error when the environment name is not found') do
    # given
    described_class.create_default(path: config_path)
    config = described_class.new(path: config_path)

    # then
    expect { config.get(name: 'nonexistent') }.to(raise_error(SecureKeys::Environment::Error))
  end

  # MARK: Custom YAML

  it('should load a custom environment defined in the YAML file') do
    # given
    yaml = <<~YAML
      environments:
        custom:
          identifier: my-custom-app
          delimiter: "|"
          source: keychain
          keys:
            - secretOne
            - secretTwo
          output: .secure-keys/custom
    YAML
    File.write(config_path, yaml)

    # when
    config = described_class.new(path: config_path)
    env = config.get(name: 'custom')

    # then
    expect(env.identifier).to(eq('my-custom-app'))
    expect(env.delimiter).to(eq('|'))
    expect(env.keys).to(eq(%w[secretOne secretTwo]))
    expect(env.output).to(eq('.secure-keys/custom'))
  end
end
