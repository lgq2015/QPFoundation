#
# Be sure to run `pod lib lint QPFoundation.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'QPFoundation'
  s.version          = '1.0.0'
  s.summary          = 'Provides a general and convenient framework for building App, including UI, enhancement tool classes, network interface, debugging, etc.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Provides a general and convenient framework for building App, including UI,
enhancement tool classes, network interface, debugging, etc.
                       DESC

  s.homepage         = 'https://github.com/keqiongpan/QPFoundation'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Qiongpan Ke' => 'keqiongpan@163.com' }
  s.source           = { :git => 'https://github.com/keqiongpan/QPFoundation.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.8'
  # s.tvos.deployment_target = '9.0'
  # s.watchos.deployment_target = '2.0'

  s.ios.source_files = 'QPFoundation/Classes/**/*'
  s.osx.source_files = ['QPFoundation/Classes/**/Networking/*',
                        'QPFoundation/Classes/**/QPPublicHeader.h',
                        'QPFoundation/Classes/**/QPFoundation.h',]

  s.ios.resource_bundles = {
    'QPFoundation' => ['QPFoundation/Assets/**/*']
  }

  s.ios.public_header_files = 'QPFoundation/Classes/**/*.h'
  s.osx.public_header_files = ['QPFoundation/Classes/**/Networking/*.h',
                               'QPFoundation/Classes/**/QPPublicHeader.h',
                               'QPFoundation/Classes/**/QPFoundation.h',]

  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
