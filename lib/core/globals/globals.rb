#!/usr/bin/env ruby

require_relative '../console/arguments/handler'
require_relative '../utils/swift/swift'

module SecureKeys
  module Globals
    module_function

    # Source: https://github.com/fastlane/fastlane/blob/b626fb18597eee88de0e08beba77070e2fecc299/fastlane_core/lib/fastlane_core/helper.rb#L73
    # Check if the current build is running on a CI
    # @return [Bool] true if the current build is running on a CI
    def ci?
      return true if circle_ci?

      # Check for Jenkins, Travis CI, ... environment variables
      %w[JENKINS_HOME JENKINS_URL TRAVIS CI APPCENTER_BUILD_ID TEAMCITY_VERSION GO_PIPELINE_NAME bamboo_buildKey GITLAB_CI XCS TF_BUILD GITHUB_ACTION GITHUB_ACTIONS BITRISE_IO BUDDY CODEBUILD_BUILD_ARN].any? do |current|
        ENV[current].to_s.to_boolean
      end
    end

    # Check if the current build is running on CircleCI
    # @return [Bool] true if the current build is running on CircleCI
    def circle_ci?
      ENV.key?('CIRCLECI')
    end

    # Check if the current instance is verbose
    # @return [Bool] true if the current instance is verbose
    def verbose?
      Core::Console::Argument::Handler.fetch(key: :verbose)
                                      .to_s
                                      .to_boolean
    end

    # Check if the SecureKeys XCFramework should be generated
    # @return [Bool] true if the SecureKeys XCFramework should be generated
    def generate_xcframework?
      Core::Console::Argument::Handler.fetch(key: :generate)
                                      .to_s
                                      .to_boolean
    end

    # Check if the SecureKeys XCFramework should be replaced
    # @return [Bool] true if the SecureKeys XCFramework should be replaced
    def replace_xcframework?
      Core::Console::Argument::Handler.fetch(key: %i[xcframework replace])
                                      .to_s
                                      .to_boolean
    end

    # Check if the SecureKeys XCFramework should be added
    # @return [Bool] true if the SecureKeys XCFramework should be added
    def add_xcframework?
      Core::Console::Argument::Handler.fetch(key: %i[xcframework add])
                                      .to_s
                                      .to_boolean
    end

    # Returns the Xcode project path
    # @return [String] Xcode project path
    def xcodeproj_path
      Core::Console::Argument::Handler.fetch(key: %i[xcframework xcodeproj],
                                             default: Dir.glob('**/*.xcodeproj').first)
    end

    # Returns the secure keys XCFramework path
    # @return [String] secure keys XCFramework path
    def secure_keys_xcframework_path
      Dir.glob("**/#{Swift::KEYS_DIRECTORY}/#{Swift::XCFRAMEWORK_DIRECTORY}").first
    end

    # Determine the secret keys source based on the environment
    # @return [Object] secret keys source
    def secret_keys_source
      return SecureKeys::Core::Environment::CI.new if ci?

      SecureKeys::Core::Environment::Keychain.new
    end

    # Returns the supported iOS platforms
    # @return [Array] supported iOS platforms
    def ios_platforms
      [
        {
          name: 'iOS Simulator',
          path: 'iphonesimulator'
        },
        {
          name: 'iOS',
          path: 'iphoneos'
        }
      ]
    end

    # Returns the identifier to get all the key names
    # @return [String] key access identifier
    def key_access_identifier
      Core::Console::Argument::Handler.fetch(key: :identifier,
                                             default: default_key_access_identifier)
    end

    # Returns the keys delimiter
    # @return [String] keys delimiter
    def key_delimiter
      Core::Console::Argument::Handler.fetch(key: :delimiter,
                                             default: default_key_delimiter)
    end

    # Returns the default key access identifier
    # @return [String] default key access identifier
    def default_key_access_identifier
      'secure-keys'
    end

    # Returns the default keys delimiter
    # @return [String] default keys delimiter
    def default_key_delimiter
      ','
    end
  end
end
