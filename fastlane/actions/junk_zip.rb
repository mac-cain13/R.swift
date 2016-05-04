# Based on: https://github.com/fastlane/fastlane/blob/master/fastlane/lib/fastlane/actions/zip.rb
module Fastlane
  module Actions
    class JunkZipAction < Action
      def self.run(params)
        UI.message "Compressing files..."

        escapedPaths = params[:paths].map do |path|
          File.expand_path("..", path).shellescape
        end
        Actions.sh "zip -rj #{params[:output_path].shellescape} #{escapedPaths.join(" ")}"

        UI.success "Successfully generated zip file at path '#{File.expand_path(params[:output_path])}'"
        return File.expand_path(params[:output_path])
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Compress files or folders to a zip without their path"
      end

      def self.details
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :paths,
                                       env_name: "FL_ZIP_PATHS",
                                       description: "Paths to the directories or files to be zipped",
                                       verify_block: proc do |paths|
                                         paths.each do |path|
                                          UI.user_error!("Couldn't find file/folder at path '#{File.expand_path(value)}'") unless File.exist?(path)
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :output_path,
                                       env_name: "FL_ZIP_OUTPUT_NAME",
                                       description: "The name of the resulting zip file",
                                       optional: false)
        ]
      end

      def self.output
        []
      end

      def self.return_value
        "The path to the output zip file"
      end

      def self.authors
        ["KrauseFx", "mac-cain13"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end