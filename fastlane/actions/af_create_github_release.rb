# From: https://github.com/AFNetworking/fastlane/blob/master/fastlane/actions/af_create_github_release.rb
module Fastlane
  module Actions
    module SharedValues
      GITHUB_RELEASE_ID = :GITHUB_RELEASE_ID
      GITHUB_RELEASE_HTML_URL = :GITHUB_RELEASE_HTML_URL
      GITHUB_RELEASE_UPLOAD_URL_TEMPLATE = :GITHUB_RELEASE_UPLOAD_URL_TEMPLATE
    end

    # To share this integration with the other fastlane users:
    # - Fork https://github.com/KrauseFx/fastlane
    # - Clone the forked repository
    # - Move this integration into lib/fastlane/actions
    # - Commit, push and submit the pull request

    class AfCreateGithubReleaseAction < Action
      def self.run(params)
        require 'net/http'
        require 'net/https'
        require 'json'
        require 'base64'

        begin
          uri = URI("https://api.github.com/repos/#{params[:owner]}/#{params[:repository]}/releases")

          # Create client
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          
          dict = Hash.new
          dict["draft"] = params[:draft] 
          dict["prerelease"] = params[:prerelease]
          dict["body"] = params[:body] if params[:body]
          dict["tag_name"] = params[:tag_name] if params[:tag_name]
          dict["name"] = params[:name] if params[:name]
          body = JSON.dump(dict)

          # Create Request
          req =  Net::HTTP::Post.new(uri)
          # Add headers
          req.add_field "Content-Type", "application/json"
          # Add headers
          api_token = params[:api_token]
          req.add_field "Authorization", "Basic #{Base64.strict_encode64(api_token)}"
          # Add headers
          req.add_field "Accept", "application/vnd.github.v3+json"
          # Set header and body
          req.add_field "Content-Type", "application/json"
          req.body = body

          # Fetch Request
          res = http.request(req)
        rescue StandardError => e
          Helper.log.info "HTTP Request failed (#{e.message})".red
        end
        
        case res.code.to_i
          when 201
          json = JSON.parse(res.body)
          Helper.log.info "Github Release Created (#{json["id"]})".green
          Helper.log.info "#{json["html_url"]}".green
          
          Actions.lane_context[SharedValues::GITHUB_RELEASE_ID] = json["id"]
          Actions.lane_context[SharedValues::GITHUB_RELEASE_HTML_URL] = json["html_url"]
          Actions.lane_context[SharedValues::GITHUB_RELEASE_UPLOAD_URL_TEMPLATE] = json["upload_url"]
          return json
          when 400..499 
          json = JSON.parse(res.body)
          raise "Error Creating Github Release (#{res.code}): #{json}".red
          else
          Helper.log.info "Status Code: #{res.code} Body: #{res.body}"
          raise "Error Creating Github Release".red
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Create a Github Release"
      end
      
      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :owner,
                                       env_name: "GITHUB_OWNER",
                                       description: "The Github Owner",
                                       is_string:true,
                                       optional:false),
           FastlaneCore::ConfigItem.new(key: :repository,
                                        env_name: "GITHUB_REPOSITORY",
                                        description: "The Github Repository",
                                        is_string:true,
                                        optional:false),
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "GITHUB_API_TOKEN",
                                       description: "Personal API Token for GitHub - generate one at https://github.com/settings/tokens",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :tag_name,
                                       env_name: "GITHUB_RELEASE_TAG_NAME",
                                       description: "Pass in the tag name",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :target_commitish,
                                       env_name: "GITHUB_TARGET_COMMITISH",
                                       description: "Specifies the commitish value that determines where the Git tag is created from. Can be any branch or commit SHA. Unused if the Git tag already exists",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :name,
                                       env_name: "GITHUB_RELEASE_NAME",
                                       description: "The name of the release",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :body,
                                       env_name: "GITHUB_RELEASE_BODY",
                                       description: "Text describing the contents of the tag",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :draft,
                                       env_name: "GITHUB_RELEASE_DRAFT",
                                       description: "true to create a draft (unpublished) release, false to create a published one",
                                       is_string: false,
                                       default_value: false),                                       
          FastlaneCore::ConfigItem.new(key: :prerelease,
                                       env_name: "GITHUB_RELEASE_PRERELEASE",
                                       description: "true to identify the release as a prerelease. false to identify the release as a full release",
                                       is_string: false,
                                       default_value: false),                                       
                                       
        ]
      end

      def self.output
        [
          ['GITHUB_RELEASE_ID', 'The Github Release ID'],
          ['GITHUB_RELEASE_HTML_URL', 'The Github Release URL'],
          ['GITHUB_RELEASE_UPLOAD_URL_TEMPLATE', 'The Github Release Upload URL']
        ]
      end

      def self.return_value
        "The Hash representing the API response"
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