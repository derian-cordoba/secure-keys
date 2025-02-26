require 'core/globals/globals'
require 'core/console/arguments/handler'
require 'core/utils/swift/xcodeproj'

describe(SecureKeys::Swift::Xcodeproj) do
  before(:each) do
    # reset the argument handler
    SecureKeys::Core::Console::Argument::Handler.reset

    # reset the env variable
    ENV['SECURE_KEYS_XCODEPROJ'] = nil
  end

  it('should find the xcodeproj from env variables') do
    # given
    expected_target_name = 'SecureKeys'
    expected_xcodeproj_path = 'spec/fixtures/ios/SecureKeys/SecureKeys.xcodeproj'

    # when
    # define the env variable
    ENV['SECURE_KEYS_XCODEPROJ'] = expected_xcodeproj_path
    xcodeproj = SecureKeys::Swift::Xcodeproj.xcodeproj

    # then
    expect(xcodeproj).not_to(be_nil)
    expect(xcodeproj.targets.map(&:name)).to(include(expected_target_name))
  end

  it('should find the xcodeproj from argument handler') do
    # given
    expected_target_name = 'SecureKeys'
    expected_xcodeproj_path = 'spec/fixtures/ios/SecureKeys/SecureKeys.xcodeproj'

    # when
    # define the argument handler
    SecureKeys::Core::Console::Argument::Handler.set(key: :xcodeproj, value: expected_xcodeproj_path)
    xcodeproj = SecureKeys::Swift::Xcodeproj.xcodeproj

    # then
    expect(xcodeproj).not_to(be_nil)
    expect(xcodeproj.targets.map(&:name)).to(include(expected_target_name))
  end

  it('should find the xcodeproj target by target name') do
    # given
    expected_target_name = 'SecureKeys'
    expected_xcodeproj_path = 'spec/fixtures/ios/SecureKeys/SecureKeys.xcodeproj'

    # when
    # define the env variable
    ENV['SECURE_KEYS_XCODEPROJ'] = expected_xcodeproj_path
    xcodeproj = SecureKeys::Swift::Xcodeproj.xcodeproj
    xcodeproj_target = SecureKeys::Swift::Xcodeproj.xcodeproj_target_by_target_name(xcodeproj:,
                                                                                    target_name: expected_target_name)

    # then
    expect(xcodeproj_target).not_to(be_nil)
    expect(xcodeproj_target.name).to(eq(expected_target_name))
  end

  it("shouldn't find the xcodeproj target by target name") do
    # given
    expected_target_name = 'Invalid-SecureKeys'
    expected_error_message = "The target #{expected_target_name} was not found"
    expected_xcodeproj_path = 'spec/fixtures/ios/SecureKeys/SecureKeys.xcodeproj'

    # when
    # define the env variable
    ENV['SECURE_KEYS_XCODEPROJ'] = expected_xcodeproj_path
    xcodeproj = SecureKeys::Swift::Xcodeproj.xcodeproj

    # then
    expect do
      SecureKeys::Swift::Xcodeproj.xcodeproj_target_by_target_name(xcodeproj:,
                                                                   target_name: expected_target_name)
    end.to(raise_error(StandardError, expected_error_message))
  end
end
