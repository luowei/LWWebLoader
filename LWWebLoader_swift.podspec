#
# Be sure to run `pod lib lint LWWebLoader_swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LWWebLoader_swift'
  s.version          = '1.0.0'
  s.summary          = 'Swift版本的LWWebLoader - 基于WKWebView的数据加载器'

  s.description      = <<-DESC
LWWebLoader_swift 是 LWWebLoader 的 Swift 版本实现。
提供了现代化的 Swift API，通过 WKWebView 的独立网络进程通道下载和上传二进制数据。
包含 UIKit 和 SwiftUI 两种使用方式。
                       DESC

  s.homepage         = 'https://github.com/luowei/LWWebLoader'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'luowei' => 'luowei@wodedata.com' }
  s.source           = { :git => 'https://github.com/luowei/LWWebLoader.git', :tag => "swift-#{s.version}" }

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'

  s.source_files = 'LWWebLoader_swift/Classes/**/*.swift'

  s.resource_bundles = {
    'LWWebLoader' => ['LWWebLoader/Assets/**/*']
  }

  s.frameworks = 'UIKit', 'WebKit'
end
