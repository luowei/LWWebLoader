#
# Be sure to run `pod lib lint LWWebLoader.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LWWebLoader'
  s.version          = '1.0.0'
  s.summary          = '基于WKWebView的数据加载器'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
LWWebLoader，一个基于WKWebView的数据加载器，通过WKWebView的独立的网络进程的通道下载和上传二进制数据.
                       DESC

  s.homepage         = 'https://github.com/luowei/LWWebLoader'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'luowei' => 'luowei@wodedata.com' }
  s.source           = { :git => 'https://github.com/luowei/LWWebLoader.git'}
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'LWWebLoader/Classes/**/*'
  
  s.resource_bundles = {
    'LWWebLoader' => ['LWWebLoader/Assets/**/*']
  }

  s.public_header_files = 'LWWebLoader/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
