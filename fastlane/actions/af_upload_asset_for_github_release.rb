# From: https://github.com/AFNetworking/fastlane/blob/master/fastlane/actions/af_upload_asset_for_github_release.rb
module Fastlane
  module Actions
    module SharedValues
      GITHUB_UPLOAD_ASSET_URL = :GITHUB_UPLOAD_ASSET_URL
    end

    # To share this integration with the other fastlane users:
    # - Fork https://github.com/KrauseFx/fastlane
    # - Clone the forked repository
    # - Move this integration into lib/fastlane/actions
    # - Commit, push and submit the pull request

    class AfUploadAssetForGithubReleaseAction < Action
      def self.run(params)
        require 'net/http'
        require 'net/https'
        require 'json'
        require 'base64'
        require 'addressable/template'

        begin
          name = params[:name] ? params[:name] : File.basename(params[:file_path])
          expanded_url = Addressable::Template.new(params[:upload_url_template]).expand({name: name, label:params[:label]}).to_s
          
          uri = URI(expanded_url)

          # Create client
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          

          # Create Request
          req =  Net::HTTP::Post.new(uri)
          # Add headers
          req.add_field "Content-Type", params[:content_type]
          # Add headers
          api_token = params[:api_token]
          req.add_field "Authorization", "Basic #{Base64.strict_encode64(api_token)}"
          # Add headers
          req.add_field "Accept", "application/vnd.github.v3+json"
          # Set header and body
          req.add_field "Content-Type", "application/json"
          req.body = File.read(params[:file_path])

          # Fetch Request
          res = http.request(req)
        rescue StandardError => e
          UI.message "HTTP Request failed (#{e.message})".red
        end
        
        case res.code.to_i
          when 201
          json = JSON.parse(res.body)
          UI.message "#{json["name"]} has been uploaded to the release".green
          Actions.lane_context[SharedValues::GITHUB_UPLOAD_ASSET_URL] = json["browser_download_url"]
          return json
          when 400..499 
          json = JSON.parse(res.body)
          raise "Error Creating Github Release (#{res.code}): #{json}".red
          else
            UI.message "Status Code: #{res.code} Body: #{res.body}"
          raise "Error Creating Github Release".red
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload an asset to a Github Release"
      end

      def self.available_options
        # Define all options your action supports. 
        
        # Below a few examples
        [
                       FastlaneCore::ConfigItem.new(key: :api_token,
                                                    env_name: "GITHUB_API_TOKEN",
                                                    description: "Personal API Token for GitHub - generate one at https://github.com/settings/tokens",
                                                    is_string: true,
                                                    optional: false),
                       FastlaneCore::ConfigItem.new(key: :upload_url_template,
                                                    env_name: "GITHUB_RELEASE_UPLOAD_URL_TEMPLATE",
                                                    description: "The Github Release Upload URL",
                                                    is_string:true,
                                                    default_value:Actions.lane_context[SharedValues::GITHUB_RELEASE_UPLOAD_URL_TEMPLATE]),
                       FastlaneCore::ConfigItem.new(key: :file_path,
                                                    env_name: "GITHUB_RELEASE_UPLOAD_FILE_PATH",
                                                    description: "Path for the file",
                                                    is_string: true,
                                                    verify_block: proc do |value|
                                                      raise "Couldn't find file at path '#{value}'".red unless File.exist?(value)
                                                    end),   
                       FastlaneCore::ConfigItem.new(key: :name,
                                                    env_name: "GITHUB_RELEASE_UPLOAD_NAME",
                                                    description: "Name of the upload asset. Defaults to the base name of 'file_path'}",
                                                    is_string: true,
                                                    optional: true),
                       FastlaneCore::ConfigItem.new(key: :label,
                                                    env_name: "GITHUB_RELEASE_UPLOAD_LABEL",
                                                    description: "An alternate short description of the asset",
                                                    is_string: true,
                                                    optional: true),
                       FastlaneCore::ConfigItem.new(key: :content_type,
                                                    env_name: "GITHUB_RELEASE_UPLOAD_CONTENT_TYPE",
                                                    description: "The content type for the upload",
                                                    is_string: true,
                                                    default_value: "application/zip")
        ]
      end

      def self.output
        [
          ['GITHUB_UPLOAD_ASSET_URL', 'A url for the newly created asset']
        ]
      end

      def self.return_value
        "The hash representing the API response"
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