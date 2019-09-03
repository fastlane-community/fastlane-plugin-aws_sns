# aws_sns `fastlane` plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-aws_sns)

## Getting Started

This project is a [fastlane](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-aws_sns`, add it to your project by running:

```bash
fastlane add_plugin aws_sns
```

## About aws_sns

[AWS SNS](https://aws.amazon.com/sns/) is fully manage push notification service. This plugin creates an AWS SNS platform application for iOS and Android apps.

iOS app are created by uploading a private key (p12) to AWS SNS - which can easily be created with [PEM](https://github.com/fastlane/fastlane/tree/master/pem)

Android apps are created by sending up a GCM Api Key to AWS SNS - obtained through your [Google Cloud Platform dashboard](https://console.cloud.google.com)

The call to `aws_sns` will return the AWS SNS plattform application's [ARN](http://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html) (if you need it). The platform application's ARN is what is used to actually send notifications to your app(s) later on.

## Example

### iOS
```ruby
aws_sns(
  platform: 'APNS',
  platform_name: 'your_awesome_ios_app',
  platform_apns_private_key_path: 'path/to/cert.p12',

  # Optional private key password
  # platform_apns_private_key_password: 'joshissupercool'
)
```

### Android
```ruby
aws_sns(
  platform: 'GCM',
  platform_name: 'your_awesome_android_app',
  platform_gcm_api_key: 'your_gcm_api_key'
)
```

### iOS (using the ARN)
```ruby
ios_arn = aws_sns(
  platform: 'APNS',
  platform_name: 'your_awesome_ios_app',
  platform_apns_private_key_path: 'path/to/cert.p12',
)

# TODO: Possibly send this ARN to someone important who needs to configure stuff
puts "ARN: #{ios_arn}"
```

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/PluginsTroubleshooting.md) doc in the main `fastlane` repo.

## Using `fastlane` Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Plugins.md).

## About `fastlane`

`fastlane` is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).

## Author

Josh Holtz, me@joshholtz.com, [@joshdholtz](https://twitter.com/joshdholtz)

I'm available for freelance work (Fastlane, iOS, and Android development) :muscle:
Feel free to contact me :rocket:
