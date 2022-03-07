require 'aws-sdk-sns'

module Fastlane
  module Actions
    module SharedValues
      AWS_SNS_PLATFORM_APPLICATION_ARN = :AWS_SNS_PLATFORM_APPLICATION_ARN
    end

    class AwsSnsAction < Action
      def self.run(params)

        access_key = params[:access_key]
        secret_access_key = params[:secret_access_key]
        region = params[:region]
        client = params[:aws_sns_client]

        platform = params[:platform]
        platform_name = params[:platform_name]
        update_attributes = params[:update_if_exists]
        attributes_override = params[:attributes_override]
        platform_apns_private_key_path = params[:platform_apns_private_key_path]
        platform_apns_private_key_password = params[:platform_apns_private_key_password]

        platform_fcm_server_key = params[:platform_fcm_server_key]
        platform_fcm_server_key ||= params[:platform_gcm_api_key]

        if client.nil?
          UI.user_error!("No AWS access key given, pass using `access_key: 'key'`") unless access_key.to_s.length > 0
          UI.user_error!("No AWS secret access key given, pass using `secret_access_key: 'secret key'`") unless secret_access_key.to_s.length > 0
          UI.user_error!("No AWS region given, pass using `region: 'region'`") unless region.to_s.length > 0
        end
        UI.user_error!("No notification platform given, pass using `platform: 'platform'`") unless platform.to_s.length > 0
        UI.user_error!("No SNS platform application name given, pass using `platform_name: 'platform_name'`") unless platform_name.to_s.length > 0

        #
        # Initialize AWS client
        #
        client ||= Aws::SNS::Client.new(
          access_key_id: access_key,
          secret_access_key: secret_access_key,
          region: region
        )

        #
        # Create APNS and GCM attributes
        #
        if ['APNS', 'APNS_SANDBOX'].include?(platform)
          UI.user_error!("Platform private key does not exist at path: #{platform_apns_private_key_path}") unless File.exist?(platform_apns_private_key_path)

          file = File.read(platform_apns_private_key_path)
          p12 = OpenSSL::PKCS12.new(file, platform_apns_private_key_password)
          cert = p12.certificate

          attributes = {
            'PlatformCredential': p12.key.to_s,
            'PlatformPrincipal': cert.to_s
          }
        elsif ['GCM', 'FCM'].include?(platform) && !platform_fcm_server_key.nil?
          platform = 'GCM'
          attributes = {
            'PlatformCredential': platform_fcm_server_key
          }
        end

        # Set additional AWS platform attributes
        if attributes.nil?
          attributes = attributes_override
        else
          attributes = attributes.merge(attributes_override)
        end

        #
        #
        #
        UI.crash!("Unable to create any attributes to create platform application") unless attributes
        begin

          arn = nil
          
          #
          # Try to find the arn for platform_name
          #
          if update_attributes

            # Loop as long as list platform applications returns next_page or return the desired name
            next_token = nil
            loop do

              resp = client.list_platform_applications({
                next_token: next_token,
              })

              next_token = resp.next_token
              # TODO: Must find a best search method !
              platform_application = resp.platform_applications.find { |platform_application| platform_application.platform_application_arn.end_with? platform_name }
              
              unless platform_application.nil? 
                arn = platform_application.platform_application_arn
                break
              end
              break if next_token.nil?
            end

          end
          
          # Not arn? OK, we create it !
          if arn.nil?  
            resp = client.create_platform_application({
              name: platform_name,
              platform: platform,
              attributes: attributes,
            })
            arn = resp.platform_application_arn
            UI.important("Created #{arn}")
          else
            # else, updating
            client.set_platform_application_attributes({
              platform_application_arn: arn,
              attributes: attributes,
            })
            UI.important("Updated #{arn}")
          end

          Actions.lane_context[SharedValues::AWS_SNS_PLATFORM_APPLICATION_ARN] = arn
          ENV[SharedValues::AWS_SNS_PLATFORM_APPLICATION_ARN.to_s] = arn
        rescue => error
          UI.crash!("Create Platform Error: #{error.inspect}")
        end

        Actions.lane_context[SharedValues::AWS_SNS_PLATFORM_APPLICATION_ARN]
      end

      def self.description
        "Creates AWS SNS platform applications"
      end

      def self.authors
        ["Josh Holtz"]
      end

      def self.return_value
        "Platform Application ARN"
      end

      def self.details
        "Creates AWS SNS platform applications for iOS and Android"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :access_key,
                                      env_name: "AWS_SNS_ACCESS_KEY",
                                      description: "AWS Access Key ID",
                                      optional: true,
                                      sensitive: true,
                                      conflicting_options: [:aws_sns_client],
                                      conflict_block: proc do |value|
                                        UI.user_error!("You can't use option '#{value.key}' along with 'access_key'")
                                      end),
          FastlaneCore::ConfigItem.new(key: :secret_access_key,
                                      env_name: "AWS_SNS_SECRET_ACCESS_KEY",
                                      description: "AWS Secret Access Key",
                                      optional: true,
                                      sensitive: true,
                                      conflicting_options: [:aws_sns_client],
                                      conflict_block: proc do |value|
                                        UI.user_error!("You can't use option '#{value.key}' along with 'secret_access_key'")
                                      end),
          FastlaneCore::ConfigItem.new(key: :region,
                                      env_name: "AWS_SNS_REGION",
                                      description: "AWS Region",
                                      optional: true,
                                      sensitive: true,
                                      conflicting_options: [:aws_sns_client],
                                      conflict_block: proc do |value|
                                        UI.user_error!("You can't use option '#{value.key}' along with 'region'")
                                      end),
          FastlaneCore::ConfigItem.new(key: :aws_sns_client,
                                      description: "AWS SNS Client, useful in case of special credentials or custom logging",
                                      type: Aws::SNS::Client,
                                      optional: true,
                                      conflicting_options: [:access_key, :secret_access_key, :region],
                                      conflict_block: proc do |value|
                                        UI.user_error!("You can't use option '#{value.key}' along with 'aws_sns_client'")
                                      end),
          FastlaneCore::ConfigItem.new(key: :platform,
                                      env_name: "AWS_SNS_PLATFORM",
                                      description: "AWS Platform",
                                      optional: false,
                                      verify_block: proc do |value|
                                        UI.user_error!("Invalid platform #{value}") unless ['APNS', 'APNS_SANDBOX', 'GCM', 'FCM'].include?(value)
                                      end),
          FastlaneCore::ConfigItem.new(key: :platform_name,
                                      env_name: "AWS_SNS_PLATFORM_NAME",
                                      description: "AWS Platform Name",
                                      optional: false),
          FastlaneCore::ConfigItem.new(key: :platform_apns_private_key_path,
                                      env_name: "AWS_SNS_PLATFORM_APNS_PRIVATE_KEY_PATH",
                                      description: "AWS Platform APNS Private Key Path",
                                      optional: true),
          FastlaneCore::ConfigItem.new(key: :platform_apns_private_key_password,
                                      env_name: "AWS_SNS_PLATFORM_APNS_PRIVATE_KEY_PASSWORD",
                                      description: "AWS Platform APNS Private Key Password",
                                      optional: true,
                                      sensitive: true,
                                      default_value: ""),
          FastlaneCore::ConfigItem.new(key: :platform_fcm_server_key,
                                      env_name: "AWS_SNS_PLATFORM_FCM_SERVER_KEY",
                                      description: "AWS Platform FCM SERVER KEY",
                                      optional: true,
                                      sensitive: true),
          FastlaneCore::ConfigItem.new(key: :platform_gcm_api_key,
                                      env_name: "AWS_SNS_PLATFORM_GCM_API_KEY",
                                      description: "AWS Platform GCM API KEY",
                                      deprecated: "Use :platform_fcm_server_key instead",
                                      optional: true,
                                      sensitive: true),
          FastlaneCore::ConfigItem.new(key: :update_if_exists,
                                      env_name: "AWS_SNS_UDPATE_IF_EXISTS",
                                      description: "updating certificate/key if platform_name already exists",
                                      default_value: false,
                                      is_string: false,
                                      optional: true),
          FastlaneCore::ConfigItem.new(key: :attributes_override,
                                      env_name: "AWS_SNS_PLATFORM_ATTRIBUTES_OVERRIDE",
                                      description: "additional AWS platform attributes such as EventEndpointCreated or SuccessFeedbackRoleArn",
                                      default_value: {},
                                      is_string: false,
                                      optional: true)
        ]
      end

      def self.is_supported?(platform)
        [:ios, :android].include?(platform)
      end
    end
  end
end
