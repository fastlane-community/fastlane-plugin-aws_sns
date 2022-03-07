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
            platform_fcm_server_key: 'PLACEHOLDER_FCM_KEY'
          })
        end
        ").runner.execute(:test)

        expect(result).to eq("String")
      end

      it 'raises an error if no AWS client can be created' do
        expect do
          Fastlane::FastFile.new.parse("
            lane :test do

              # Just in case they are set
              ENV.delete('AWS_SNS_ACCESS_KEY')
              ENV.delete('AWS_SNS_SECRET_ACCESS_KEY')
              ENV.delete('AWS_SNS_REGION')

              arn = aws_sns({
                platform: 'FCM',
                platform_name: 'FCM_SNS_PLATFORM_APP',
                platform_fcm_server_key: 'PLACEHOLDER_FCM_KEY'
              })
            end
          ").runner.execute(:test)
        end.to raise_error(FastlaneCore::Interface::FastlaneError)
      end
    end
  end
end
