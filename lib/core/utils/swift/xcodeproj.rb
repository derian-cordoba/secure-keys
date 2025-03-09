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
        ::Xcodeproj::Project.open(Globals.xcodeproj_path)
      end

      # Remove all references to SecureKeys.xcframework from the Xcodeproj
      # @param xcodeproj [Xcodeproj::Project] The Xcodeproj to remove the XCFramework
      # @param xcodeproj_target [Xcodeproj::Project::Object::PBXNativeTarget] The target where the XCFramework is linked
      # @param xcframework_path [String] The XCFramework path to remove
      def remove_xcframework(xcodeproj:, xcodeproj_target:, xcframework_path:)
        xcframework_filename = File.basename(xcframework_path)

        remove_xcframework_from_build_phase(xcodeproj_target:, xcframework_filename:)
        remove_xcframework_file_references(xcodeproj:, xcframework_filename:)
        remove_xcframework_from_groups(xcodeproj:, xcframework_filename:)
        remove_xcframework_from_search_paths(xcodeproj_target:, xcframework_filename:)
      end

      # Get the XCFramework relative path
      # @return [Pathname] The XCFramework relative path
      def xcframework_relative_path
        Pathname.new(Globals.secure_keys_xcframework_path)
                .relative_path_from(Pathname.new(Globals.xcodeproj_path).dirname)
      end

      # Check if the Xcode project has the secure keys XCFramework
      # @param xcodeproj [Xcodeproj::Project] The Xcode project
      # @return [Bool] true if the Xcode project has the secure keys XCFramework
      def xcodeproj_has_secure_keys_xcframework?(xcodeproj:)
        xcodeproj.targets.any? do |target|
          target.frameworks_build_phase.files.any? do |file|
            return false if file.file_ref.nil?

            file.file_ref.path.include?(Globals.secure_keys_xcframework_path)
          end
        end
      end

      # Remove the XCFramework from the "Link Binary With Libraries" build phase
      # @param xcodeproj_target [Xcodeproj::Project::Object::PBXNativeTarget] The target where the XCFramework is linked
      # @param xcframework_filename [String] The XCFramework filename to remove
      def remove_xcframework_from_build_phase(xcodeproj_target:, xcframework_filename:)
        build_phase_files = xcodeproj_target.frameworks_build_phase.files.select do |file|
          file.file_ref&.path&.include?(xcframework_filename)
        end

        build_phase_files.each do |file|
          file.remove_from_project
          Core::Console::Logger.verbose(message: "Removed #{xcframework_filename} from Link Binary With Libraries in target #{xcodeproj_target.name}")
        end
      end

      # Remove the XCFramework from the file references
      # @param xcodeproj [Xcodeproj::Project] The Xcodeproj to remove the XCFramework
      # @param xcframework_filename [String] The XCFramework filename to remove
      def remove_xcframework_file_references(xcodeproj:, xcframework_filename:)
        file_references = xcodeproj.files.select { |file| file.path&.include?(xcframework_filename) }
        file_references.each do |file_ref|
          file_ref.remove_from_project
          Core::Console::Logger.verbose(message: "Removed #{xcframework_filename} file reference")
        end

        # Ensure no orphaned references remain
        xcodeproj.objects.select { |obj| obj.isa == 'PBXFileReference' && obj.path&.include?(xcframework_filename) }.each(&:remove_from_project)
        xcodeproj.objects.select { |obj| obj.isa == 'PBXBuildFile' && obj.file_ref&.path&.include?(xcframework_filename) }.each(&:remove_from_project)
      end

      # Remove the XCFramework from groups (e.g., Frameworks Group)
      # @param xcodeproj [Xcodeproj::Project] The Xcodeproj to remove the XCFramework
      # @param xcframework_filename [String] The XCFramework filename to remove
      def remove_xcframework_from_groups(xcodeproj:, xcframework_filename:)
        frameworks_group = xcodeproj.frameworks_group
        group_references = frameworks_group.files.select { |file| file.path&.include?(xcframework_filename) }

        group_references.each do |file_ref|
          frameworks_group.remove_reference(file_ref)
          Core::Console::Logger.verbose(message: "Removed #{xcframework_filename} from Frameworks group")
        end
      end

      # Remove the XCFramework from FRAMEWORK_SEARCH_PATHS
      # @param xcodeproj_target [Xcodeproj::Project::Object::PBXNativeTarget] The target where the XCFramework is linked
      # @param xcframework_filename [String] The XCFramework filename to remove
      def remove_xcframework_from_search_paths(xcodeproj_target:, xcframework_filename:)
        xcodeproj_target.build_configurations.each do |config|
          framework_search_paths = config.build_settings['FRAMEWORK_SEARCH_PATHS'] || []
          new_search_paths = framework_search_paths.reject { |path| path.include?(xcframework_filename) }
          config.build_settings['FRAMEWORK_SEARCH_PATHS'] = new_search_paths unless framework_search_paths == new_search_paths
        end
      end
    end
  end
end
