# From: https://github.com/AFNetworking/fastlane/blob/master/fastlane/actions/af_insert_text_into_file.rb
module Fastlane
  module Actions

    # To share this integration with the other fastlane users:
    # - Fork https://github.com/KrauseFx/fastlane
    # - Clone the forked repository
    # - Move this integration into lib/fastlane/actions
    # - Commit, push and submit the pull request
    class AfInsertTextIntoFileAction < Action
      def self.replace(filepath, regexp, *args, &block)
        content = File.read(filepath).gsub(regexp, *args, &block)
        File.open(filepath, 'wb') { |file| file.write(content) }
      end
      
      def self.run(params)
        if params[:insert_delimiter]
          replace(params[:file_path], /^#{params[:insert_delimiter]}/mi) do |match| 
            "#{match} #{params[:text]}"
          end
        elsif params[:insert_at_bottom] == true
          open(params[:file_path], 'a') { |f| f.puts "#{params[:text]}" }
        else 
          file = IO.read(params[:file_path]) 
          open(params[:file_path], 'w') { |f| f << params[:text] << file} 
        end

        Helper.log.info "#{params[:file_path]} has been updated".green
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Insert text into a file"
      end

      def self.details
        "Insert text at the top, bottom, or after a delimiter in a file"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :file_path,
                                       description: "Path for the file",
                                       is_string: true,
                                       verify_block: proc do |value|
                                         raise "Couldn't find file at path '#{value}'".red unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :text,
                                       description: "The text to insert",
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :insert_delimiter,
                                       description: "The delimiter indicating where to insert the text in the file",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :insert_at_bottom,
                                       description: "If no 'insert_delimiter' is provided, the text will be appended to the bottom
of the file if this value is true, or to the top if this value is false",
                                       is_string: false,
                                       default_value: true),
        ]
      end

      def self.output
      end

      def self.return_value
      end

      def self.authors
        ["kcharwood"]
      end

      def self.is_supported?(platform)
        return true
      end
    end
  end
end