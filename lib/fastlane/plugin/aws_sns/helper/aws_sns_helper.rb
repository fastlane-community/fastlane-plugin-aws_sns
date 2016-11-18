module Fastlane
  module Helper
    class AwsSnsHelper
      # class methods that you define here become available in your action
      # as `Helper::AwsSnsHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the aws_sns plugin helper!")
      end
    end
  end
end
