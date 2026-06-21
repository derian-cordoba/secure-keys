require 'validation/utils/entropy'

describe(SecureKeys::Validation::Entropy) do
  it('should return 0.0 for an empty string') do
    # when
    entropy = described_class.calculate(string: '')

    # then
    expect(entropy).to(eq(0.0))
  end

  it('should return 0.0 for a string with a single unique character') do
    # when
    entropy = described_class.calculate(string: 'aaaa')

    # then
    expect(entropy).to(eq(0.0))
  end

  it('should return 1.0 for a string with two equally distributed characters') do
    # given — two chars, equal probability each → entropy = 1 bit
    string = 'ab'

    # when
    entropy = described_class.calculate(string:)

    # then
    expect(entropy).to(eq(1.0))
  end

  it('should return higher entropy for a random-looking string than a repetitive one') do
    # given
    repetitive = 'aaabbbccc'
    random     = 'aB3!xZ9#mQ'

    # when
    repetitive_entropy = described_class.calculate(string: repetitive)
    random_entropy     = described_class.calculate(string: random)

    # then
    expect(random_entropy).to(be > repetitive_entropy)
  end

  it('should return a Float') do
    # when
    result = described_class.calculate(string: 'hello')

    # then
    expect(result).to(be_a(Float))
  end

  it('should return positive entropy for a string with mixed characters') do
    # when
    entropy = described_class.calculate(string: 'abc123!@#')

    # then
    expect(entropy).to(be > 0.0)
  end
end
