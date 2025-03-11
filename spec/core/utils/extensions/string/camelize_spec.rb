require 'core/utils/extensions/string/camelize'

describe Camelize do
  it('should convert a string to camel case format') do
    # given
    word = 'hello world'
    expected_camelized_word = 'helloWorld'

    # when
    camelized_word = word.camelize

    # then
    expect(camelized_word).to(eq(expected_camelized_word))
  end

  it('should convert an snake case string to camel case format') do
    # given
    snake_case_word = 'hello_world'
    expected_camelized_word = 'helloWorld'

    # when
    camelized_word = snake_case_word.camelize

    # then
    expect(camelized_word).to(eq(expected_camelized_word))
  end

  it('should convert a kebab case string to camel case format') do
    # given
    kebab_case_word = 'hello-world'
    expected_camelized_word = 'helloWorld'

    # when
    camelized_word = kebab_case_word.camelize

    # then
    expect(camelized_word).to(eq(expected_camelized_word))
  end

  it('should convert a string with multiple spaces to camel case format') do
    # given
    spaced_word = 'hello   world'
    expected_camelized_word = 'helloWorld'

    # when
    camelized_word = spaced_word.camelize

    # then
    expect(camelized_word).to(eq(expected_camelized_word))
  end

  it('should convert a string with multiple underscores to camel case format') do
    # given
    underscored_word = 'hello___world'
    expected_camelized_word = 'helloWorld'

    # when
    camelized_word = underscored_word.camelize

    # then
    expect(camelized_word).to(eq(expected_camelized_word))
  end

  it('should convert a string with multiple dashes to camel case format') do
    # given
    dashed_word = 'hello---world'
    expected_camelized_word = 'helloWorld'

    # when
    camelized_word = dashed_word.camelize

    # then
    expect(camelized_word).to(eq(expected_camelized_word))
  end

  it('should convert a string with multiple mixed separators to camel case format') do
    # given
    mixed_word = 'hello -_ world'
    expected_camelized_word = 'helloWorld'

    # when
    camelized_word = mixed_word.camelize

    # then
    expect(camelized_word).to(eq(expected_camelized_word))
  end

  it('should convert a string with uppercase letters to camel case format') do
    # given
    uppercase_word = 'HELLO_WORLD'
    expected_camelized_word = 'helloWorld'

    # when
    camelized_word = uppercase_word.camelize

    # then
    expect(camelized_word).to(eq(expected_camelized_word))
  end

  it('should convert a string with uppercase letters and mixed separators to camel case format') do
    # given
    mixed_word = 'HELLO -_ WORLD'
    expected_camelized_word = 'helloWorld'

    # when
    camelized_word = mixed_word.camelize

    # then
    expect(camelized_word).to(eq(expected_camelized_word))
  end

  it('should convert a string with uppercase letters and lowercase letters to camel case format') do
    # given
    mixed_word = 'HELLO -_ world'
    expected_camelized_word = 'helloWorld'

    # when
    camelized_word = mixed_word.camelize

    # then
    expect(camelized_word).to(eq(expected_camelized_word))
  end

  it('should convert a upper camel case string to camel case format') do
    # given
    mixed_word = 'HelloTheWorld'
    expected_camelized_word = 'helloTheWorld'

    # when
    camelized_word = mixed_word.camelize

    # then
    expect(camelized_word).to(eq(expected_camelized_word))
  end
end
