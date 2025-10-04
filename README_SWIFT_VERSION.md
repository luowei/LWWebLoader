# LWWebLoader Swift Version

## 概述

LWWebLoader_swift 是 LWWebLoader 的 Swift 版本实现，提供了现代化的 Swift API 用于通过 WKWebView 的独立网络进程通道下载和上传二进制数据。

## 安装

### CocoaPods

在您的 `Podfile` 中添加：

```ruby
pod 'LWWebLoader_swift'
```

然后运行：

```bash
pod install
```

## 使用方法

### Swift

```swift
import LWWebLoader_swift

// 创建 WebLoader 实例
let webLoader = LWWebLoader()

// 下载数据
webLoader.download(from: "https://example.com/file.zip") { data, error in
    if let data = data {
        // 处理下载的数据
        print("Downloaded \(data.count) bytes")
    } else if let error = error {
        print("Error: \(error.localizedDescription)")
    }
}

// 上传数据
let uploadData = "Hello, World!".data(using: .utf8)!
webLoader.upload(uploadData, to: "https://example.com/upload") { response, error in
    if let response = response {
        print("Upload successful: \(response)")
    }
}
```

### SwiftUI

```swift
import SwiftUI
import LWWebLoader_swift

struct ContentView: View {
    @StateObject private var loader = LWWebLoaderSwiftUI()

    var body: some View {
        VStack {
            if loader.isLoading {
                ProgressView("Loading...")
            } else if let data = loader.data {
                Text("Loaded \(data.count) bytes")
            }

            Button("Download") {
                loader.download(from: "https://example.com/file.zip")
            }
        }
    }
}
```

## 主要特性

- **独立网络进程**: 利用 WKWebView 的独立网络进程通道
- **异步操作**: 基于回调的异步 API
- **SwiftUI 支持**: 提供 ObservableObject 用于 SwiftUI 集成
- **二进制数据处理**: 支持下载和上传二进制数据
- **错误处理**: 完善的错误处理机制

## 系统要求

- iOS 11.0+
- Swift 5.0+
- Xcode 12.0+

## 与 Objective-C 版本的关系

- **LWWebLoader**: Objective-C 版本，适用于传统的 Objective-C 项目
- **LWWebLoader_swift**: Swift 版本，提供现代化的 Swift API 和 SwiftUI 支持

您可以根据项目需要选择合适的版本。两个版本功能相同，但 Swift 版本提供了更好的类型安全性和 SwiftUI 集成。

## License

LWWebLoader_swift is available under the MIT license. See the LICENSE file for more info.
