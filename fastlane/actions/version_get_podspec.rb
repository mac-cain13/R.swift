module Fastlane
  module Actions
    class VersionGetPodspecAction < Action
      def self.run(params)
        podspec_path = params[:path]

        UI.user_error!("Could not find podspec file at path '#{podspec_path}'") unless File.exist? podspec_path

        version_podspec_file = PodspecHelper.new(podspec_path)

        Actions.lane_context[SharedValues::PODSPEC_VERSION_NUMBER] = version_podspec_file.version_value
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Receive the version number from a podspec file"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_VERSION_PODSPEC_PATH",
                                       description: "You must specify the path to the podspec file",
                                       is_string: true,
                                       default_value: Dir["*.podspec"].last,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a path to the `version_get_podspec` action") if value.length == 0
                                       end)
        ]
      end

      def self.output
        [
          ['PODSPEC_VERSION_NUMBER', 'The podspec version number']
        ]
      end

      def self.authors
        ["Liquidsoul", "KrauseFx"]
      end

      def self.is_supported?(platform)
        true
      end
    end

    class PodspecHelper
      attr_accessor :path
      attr_accessor :podspec_content
      attr_accessor :version_regex
      attr_accessor :version_match
      attr_accessor :version_value

      def initialize(path = nil)
        version_var_name = 'version'
        @version_regex = /^(?<begin>[^#]*#{version_var_name}\s*=\s*['"])(?<value>(?<major>[0-9]+)(\.(?<minor>[0-9]+))?(\.(?<patch>[0-9]+))?(\.(?<type>[a-z]+))?(\.(?<buildnumber>[0-9]+))?)(?<end>['"])/i

        return unless (path || '').length > 0
        UI.user_error!("Could not find podspec file at path '#{path}'") unless File.exist?(path)

        @path = File.expand_path(path)
        podspec_content = File.read(path)

        parse(podspec_content)
      end

      def parse(podspec_content)
        @podspec_content = podspec_content
        @version_match = @version_regex.match(@podspec_content)
        UI.user_error!("AAAAAH!!! Could not find version in podspec content '#{@podspec_content}'") if @version_match.nil?
        @version_value = @version_match[:value]
      end

      def bump_version(bump_type)
        major = version_match[:major].to_i
        minor = version_match[:minor].to_i || 0
        patch = version_match[:patch].to_i || 0

        case bump_type
        when 'patch'
          patch += 1
        when 'minor'
          minor += 1
          patch = 0
        when 'major'
          major += 1
          minor = 0
          patch = 0
        end

        @version_value = "#{major}.#{minor}.#{patch}"
      end

      def update_podspec(version = nil)
        new_version = version || @version_value
        updated_podspec_content = @podspec_content.gsub(@version_regex, "#{@version_match[:begin]}#{new_version}#{@version_match[:end]}")

        File.open(@path, "w") { |file| file.puts updated_podspec_content } unless Helper.test?

        updated_podspec_content
      end
    end
  end
end
