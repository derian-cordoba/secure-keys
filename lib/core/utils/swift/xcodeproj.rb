require 'xcodeproj'
require_relative '../../globals/globals'
require_relative '../../utils/swift/swift'
require_relative '../../console/logger'

module SecureKeys
  module Swift
    module Xcodeproj
      module_function

      # Add the SecureKeys XCFramework to the Xcodeproj target build settings
      # @param target_name [String] The target name to add the XCFramework
      # @param configurations [Array<String>] The configurations to add the XCFramework
      def add_framework_search_path(xcodeproj_target:, configurations: %w[Debug Release])
        configurations.each do |config|
          paths = ['$(inherited)', "$(SRCROOT)/#{xcframework_relative_path}"]
          xcodeproj_target.build_settings(config)['FRAMEWORK_SEARCH_PATHS'] = paths
        end
      end

      # Add the SecureKeys XCFramework to the Xcodeproj target build phases
      # @param xcodeproj [Xcodeproj::Project] The Xcodeproj to add the XCFramework
      # @param xcodeproj_target [Xcodeproj] The Xcodeproj target to add the XCFramework
      def add_xcframework_to_build_phases(xcodeproj:, xcodeproj_target:)
        Core::Console::Logger.crash!(message: "The xcodeproj #{xcodeproj} already have the #{XCFRAMEWORK_DIRECTORY}") if xcodeproj_has_secure_keys_xcframework?(xcodeproj:)
        xcframework_reference = xcodeproj.frameworks_group.new_file(xcframework_relative_path)
        xcodeproj_target.frameworks_build_phase.add_file_reference(xcframework_reference)
      end

      # Get the Xcodeproj target by target name
      # @param xcodeproj [Xcodeproj::Project] The Xcodeproj to get the target
      # @param target_name [String] The target name to get
      # @return [Xcodeproj] The Xcodeproj target
      # @raise [StandardError] If the target was not found
      def xcodeproj_target_by_target_name(xcodeproj:, target_name:)
        xcodeproj_target = xcodeproj.targets.find { |target| target.name.eql?(target_name) }
        Core::Console::Logger.crash!(message: "The target #{target_name} was not found") if xcodeproj_target.nil?

        xcodeproj_target
      end

      # Get the Xcodeproj
      # @return [Xcodeproj] The Xcodeproj
      def xcodeproj
        ::Xcodeproj::Project.open(SecureKeys::Globals.xcodeproj_path)
      end

      # Get the XCFramework relative path
      # @return [Pathname] The XCFramework relative path
      def xcframework_relative_path
        Pathname.new(SecureKeys::Globals.secure_keys_xcframework_path)
                .relative_path_from(Pathname(SecureKeys::Globals.xcodeproj_path).dirname)
      end

      # Check if the Xcode project has the secure keys XCFramework
      # @param xcodeproj [Xcodeproj::Project] The Xcode project
      # @return [Bool] true if the Xcode project has the secure keys XCFramework
      def xcodeproj_has_secure_keys_xcframework?(xcodeproj:)
        xcodeproj.targets.any? do |target|
          target.frameworks_build_phase.files.any? do |file|
            return false if file.file_ref.nil?

            file.file_ref.path.include?(SecureKeys::Globals.secure_keys_xcframework_path)
          end
        end
      end
    end
  end
end
