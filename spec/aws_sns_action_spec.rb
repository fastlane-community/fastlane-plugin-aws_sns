describe Fastlane do
  describe Fastlane::FastFile do
    describe 'aws_sns' do
      it 'returns the FCM Platform ARN' do
        expect(Fastlane::UI).to receive(:important).with('Created String')
        result = Fastlane::FastFile.new.parse("
        lane :test do
          aws_sns_client = Aws::SNS::Client.new(stub_responses: true)

          arn = aws_sns({
            aws_sns_client: aws_sns_client,
            platform: 'FCM',
            platform_name: 'FCM_SNS_PLATFORM_APP',
            platform_fcm_server_key: 'PLACEHOLDER_FCM_KEY',
            attributes_override: {}
          })
        end
        ").runner.execute(:test)

        expect(result).to eq("String")
      end
    end
  end
end
