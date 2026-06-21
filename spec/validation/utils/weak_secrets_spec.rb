require 'validation/utils/weak_secrets'

describe(SecureKeys::Validation) do
  subject(:weak_secrets) { described_class::WEAK_SECRETS }

  it('should be an Array') do
    expect(weak_secrets).to(be_a(Array))
  end

  it('should be frozen') do
    expect(weak_secrets).to(be_frozen)
  end

  it('should not be empty') do
    expect(weak_secrets).not_to(be_empty)
  end

  it('should contain common weak passwords') do
    expect(weak_secrets).to(include('password'))
    expect(weak_secrets).to(include('secret'))
    expect(weak_secrets).to(include('123456'))
  end

  it('should contain common placeholder values') do
    expect(weak_secrets).to(include('test'))
    expect(weak_secrets).to(include('demo'))
    expect(weak_secrets).to(include('example'))
  end

  it('should contain common default credentials') do
    expect(weak_secrets).to(include('admin'))
    expect(weak_secrets).to(include('default'))
    expect(weak_secrets).to(include('changeme'))
  end

  it('should contain all String elements') do
    weak_secrets.each do |entry|
      expect(entry).to(be_a(String))
    end
  end
end
