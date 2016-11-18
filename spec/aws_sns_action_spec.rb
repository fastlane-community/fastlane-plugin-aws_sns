describe Fastlane::Actions::AwsSnsAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The aws_sns plugin is working!")

      Fastlane::Actions::AwsSnsAction.run(nil)
    end
  end
end
