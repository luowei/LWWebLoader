# LWWebLoader

[![CI Status](https://img.shields.io/travis/luowei/LWWebLoader.svg?style=flat)](https://travis-ci.org/luowei/LWWebLoader)
[![Version](https://img.shields.io/cocoapods/v/LWWebLoader.svg?style=flat)](https://cocoapods.org/pods/LWWebLoader)
[![License](https://img.shields.io/cocoapods/l/LWWebLoader.svg?style=flat)](https://cocoapods.org/pods/LWWebLoader)
[![Platform](https://img.shields.io/cocoapods/p/LWWebLoader.svg?style=flat)](https://cocoapods.org/pods/LWWebLoader)

## 简介

LWWebLoader 是一个基于 WKWebView 的强大数据加载器，利用 WKWebView 独立的网络进程通道实现二进制数据的下载和上传功能。该框架为 iOS 应用提供了一种创新的网络数据处理方案，通过 JavaScript 与原生代码的桥接，实现了灵活的数据传输机制。

### 核心特性

- **独立网络进程**：利用 WKWebView 的独立网络进程，避免影响主应用性能
- **多种加载方式**：支持 GET、POST、文件上传、文件下载、流式下载等多种数据加载方式
- **流式传输**：支持大文件的流式下载，实时监控下载进度
- **WebSocket 支持**：可与 LWWebSocket 配合使用，实现双向通信功能
- **Base64 编码传输**：自动处理二进制数据的编码与解码
- **异步回调机制**：提供完善的异步数据处理回调

## 系统要求

- iOS 9.0 及以上版本
- Xcode 10.0 及以上版本
- Objective-C

## 安装方式

### CocoaPods

LWWebLoader 可以通过 [CocoaPods](https://cocoapods.org) 进行安装。在你的 Podfile 中添加以下内容：

```ruby
pod 'LWWebLoader'
```

然后执行：

```bash
pod install
```

### 手动安装

1. 下载或克隆本仓库
2. 将 `LWWebLoader/Classes` 目录下的文件添加到你的项目中
3. 将 `LWWebLoader/Assets` 目录下的资源文件添加到你的项目中

## 使用示例

### 运行示例项目

要运行示例项目，请按以下步骤操作：

1. 克隆仓库
2. 进入 Example 目录
3. 执行 `pod install`
4. 打开 `LWWebLoader.xcworkspace`

## 功能详解

### 1. 基础使用 - WKWebView 模式

#### 初始化 WebLoader

```objective-c
@property (nonatomic, strong) LWWebLoader *webloader;

- (LWWebLoader *)webloader {
    if (!_webloader) {
        _webloader = LWWebLoader.webloader;
    }
    return _webloader;
}
```

#### GET 请求

```objective-c
- (void)getBtnAction {
    NSString *urlString = @"http://mytest.com/test.json";

    WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString
                                                           method:GetData
                                                  methodArguments:nil
                                                        userAgent:nil
                                                      contentType:nil
                                                         postData:nil
                                                       uploadData:nil];

    __weak typeof(self) weakSelf = self;
    [self.webloader evaluateWithBody:evaluateBody
                          parentView:self.view
           dataLoadCompletionHandler:^(WLHanderBody *body, NSError *error) {
        if (error) {
            NSLog(@"请求失败：%@", error);
            return;
        }
        [weakSelf handleWithBody:body];
    }];
}
```

#### POST 请求

```objective-c
- (void)postBtnAction {
    NSString *urlString = @"http://mytest.com/api";
    NSString *contentType = @"application/json";
    NSDictionary *postData = @{@"name": @"张三", @"age": @25};

    WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString
                                                           method:PostData
                                                  methodArguments:nil
                                                        userAgent:nil
                                                      contentType:contentType
                                                         postData:postData
                                                       uploadData:nil];

    __weak typeof(self) weakSelf = self;
    [self.webloader evaluateWithBody:evaluateBody
                          parentView:self.view
           dataLoadCompletionHandler:^(WLHanderBody *body, NSError *error) {
        if (error) {
            NSLog(@"POST 请求失败：%@", error);
            return;
        }
        [weakSelf handleWithBody:body];
    }];
}
```

#### 文件上传

```objective-c
- (void)uploadBtnAction {
    NSString *urlString = @"http://mytest.com:8000/upload";

    // 准备要上传的文件数据
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"file.zip"];
    NSData *uploadData = [NSData dataWithContentsOfFile:filePath];

    // 附加的表单数据
    NSDictionary *postData = @{
        @"filename": @"file.zip",
        @"description": @"文件描述"
    };

    WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString
                                                           method:UploadData
                                                  methodArguments:nil
                                                        userAgent:nil
                                                      contentType:nil
                                                         postData:postData
                                                       uploadData:uploadData];

    __weak typeof(self) weakSelf = self;
    [self.webloader evaluateWithBody:evaluateBody
                          parentView:self.view
           dataLoadCompletionHandler:^(WLHanderBody *body, NSError *error) {
        if (error) {
            NSLog(@"上传失败：%@", error);
            return;
        }
        [weakSelf handleWithBody:body];
    }];
}
```

#### 文件下载（整体下载）

```objective-c
- (void)downloadFileBtnAction {
    NSString *urlString = @"http://mytest.com/file.zip";

    WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString
                                                           method:DownloadFile
                                                  methodArguments:nil
                                                        userAgent:nil
                                                      contentType:nil
                                                         postData:nil
                                                       uploadData:nil];

    __weak typeof(self) weakSelf = self;
    [self.webloader evaluateWithBody:evaluateBody
                          parentView:self.view
           dataLoadCompletionHandler:^(WLHanderBody *body, NSError *error) {
        if (error) {
            NSLog(@"下载失败：%@", error);
            return;
        }

        // body.handlerResult 为 NSData 类型
        [weakSelf handleWithBody:body];
    }];
}
```

#### 流式下载（适用于大文件）

```objective-c
- (void)downloadStreamBtnAction {
    NSString *urlString = @"http://oss.wodedata.com/Fonts/font.ttf";

    WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString
                                                           method:DownloadStream
                                                  methodArguments:nil
                                                        userAgent:nil
                                                      contentType:nil
                                                         postData:nil
                                                       uploadData:nil];

    __weak typeof(self) weakSelf = self;
    [self.webloader evaluateWithBody:evaluateBody
                          parentView:self.view
           dataLoadCompletionHandler:^(WLHanderBody *body, NSError *error) {
        if (error) {
            NSLog(@"流式下载失败：%@", error);
            return;
        }

        // 流式下载会收到多次回调，根据 bodyType 判断状态
        [weakSelf handleWithBody:body];
    }];
}
```

#### 响应数据处理

```objective-c
- (void)handleWithBody:(WLHanderBody *)body {
    switch (body.bodyType) {
        case BodyType_Error: {
            NSLog(@"错误：%@", body.handlerResult);
            break;
        }
        case BodyType_Json: {
            NSLog(@"JSON 数据：%@", body.handlerResult);
            break;
        }
        case BodyType_PlainText: {
            NSLog(@"文本数据：%@", body.handlerResult);
            break;
        }
        case BodyType_Data: {
            // 二进制数据，可保存为文件
            NSData *data = body.handlerResult;
            [self writeToFileWithData:data];
            break;
        }
        case BodyType_StreamStart: {
            NSLog(@"流式下载开始：%@", body.handlerResult);
            break;
        }
        case BodyType_Streaming: {
            // body.handlerResult 为下载进度 (0.0 - 1.0)
            double progress = [body.handlerResult doubleValue];
            NSLog(@"下载中：%.2f%%", progress * 100);
            break;
        }
        case BodyType_StreamEnd: {
            // body.handlerResult 为文件保存路径
            NSString *filePath = body.handlerResult;
            NSLog(@"下载完成，文件路径：%@", filePath);
            break;
        }
        default:
            break;
    }
}

- (void)writeToFileWithData:(NSData *)data {
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"download.zip"];
    NSError *error;
    [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
    if (error) {
        NSLog(@"保存文件失败：%@", error);
    } else {
        NSLog(@"文件已保存至：%@", filePath);
    }
}
```

### 2. WebSocket 模式

LWWebLoader 支持与 LWWebSocket 配合使用，实现 WebSocket 双向通信功能。

#### 初始化 WebSocket WebLoader

```objective-c
@property (nonatomic, strong) LWWebLoader *wsWebloader;

- (LWWebLoader *)wsWebloader {
    if (!_wsWebloader) {
        _wsWebloader = LWWebLoader.webloader;
    }
    return _wsWebloader;
}
```

#### 启动 WebSocket 服务

```objective-c
- (void)startWSAction {
    // 设置 WebSocket 服务器工作目录
    NSString *webPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                            NSUserDomainMask,
                                                            YES).firstObject;

    // 启动 WebSocket 服务器，监听端口 11335
    [[WebSocketManager sharedManager] startServerWithPort:11335 webPath:webPath];

    // 设置接收文本消息的回调
    [WebSocketManager sharedManager].handleReceiveMessage = ^(uint32_t messageType, NSString *message) {
        switch (messageType) {
            case SocketMessageType_String: {
                NSLog(@"收到文本消息：%@", message);
                break;
            }
            default:
                break;
        }
    };

    // 设置接收二进制数据的回调
    [WebSocketManager sharedManager].handleReceiveData = ^(uint32_t messageType, NSData *data) {
        switch (messageType) {
            case SocketMessageType_StreamStart: {
                NSLog(@"开始接收文件流");
                break;
            }
            case SocketMessageType_Streaming: {
                NSLog(@"正在接收文件流...");
                break;
            }
            case SocketMessageType_StreamEnd: {
                NSString *dataPath = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"文件流接收完成，路径：%@", dataPath);
                break;
            }
            case SocketMessageType_Data: {
                NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"收到二进制数据：%@", text);
                break;
            }
            default:
                break;
        }
    };

    // 设置 WebSocket 数据接收处理器
    void (^receiveWSDataHandler)(WLHanderBody *, NSError *) = ^(WLHanderBody *body, NSError *error) {
        switch (body.bodyType) {
            case BodyType_Error: {
                NSLog(@"WebSocket 错误：%@", body.handlerResult);
                break;
            }
            case BodyType_PlainText: {
                NSLog(@"WebSocket 文本：%@", body.handlerResult);
                break;
            }
            case BodyType_Data: {
                NSString *dataString = [[NSString alloc] initWithData:body.handlerResult
                                                              encoding:NSUTF8StringEncoding];
                NSLog(@"WebSocket 数据：%@", dataString);
                break;
            }
            case BodyType_StreamStart: {
                NSLog(@"WebSocket 流开始：%@", body.handlerResult);
                break;
            }
            case BodyType_Streaming: {
                NSLog(@"WebSocket 流传输中...");
                break;
            }
            case BodyType_StreamEnd: {
                NSLog(@"WebSocket 流完成，文件路径：%@", body.handlerResult);
                break;
            }
            case BodyType_WSOpened: {
                NSLog(@"WebSocket 已连接");
                break;
            }
            case BodyType_WSClosed: {
                NSLog(@"WebSocket 已断开");
                break;
            }
            default:
                break;
        }
    };

    // 启动 WebSocket WebView
    [self.wsWebloader startWSWebViewWithParentView:self.view
                             receiveWSDataHandler:receiveWSDataHandler];
}
```

#### 连接 WebSocket

```objective-c
- (void)connectWSAction {
    [self.wsWebloader wsConnect];
}
```

#### 发送文本消息

```objective-c
NSString *message = @"Hello WebSocket!";
[self.wsWebloader wsSendString:message];
```

#### 发送二进制数据

```objective-c
NSData *data = [@"binary data" dataUsingEncoding:NSUTF8StringEncoding];
[self.wsWebloader wsSendData:data];
```

#### 发送文件流

```objective-c
- (void)sendFileStream {
    NSBundle *bundle = [NSBundle bundleForClass:[self.wsWebloader class]];
    NSURL *fileURL = [bundle URLForResource:@"file" withExtension:@"pdf"];

    // 开始发送文件流
    [self.wsWebloader wsSendStreamStart];

    NSError *error;
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingFromURL:fileURL error:&error];
    if (error) {
        NSLog(@"打开文件失败：%@", error.localizedDescription);
        return;
    }

    // 分块读取并发送文件
    NSData *data = nil;
    while ((data = [fileHandle readDataOfLength:10240])) {
        if (data.length > 0) {
            [self.wsWebloader wsSendStreaming:data];
        } else {
            break;
        }
    }

    // 结束文件流发送
    [self.wsWebloader wsSendStreamEnd];
}
```

#### 通过原生 WebSocket 发送文件

```objective-c
- (void)sendWSByNativeSendAction {
    NSBundle *bundle = [NSBundle bundleForClass:[self.wsWebloader class]];
    NSURL *fileURL = [bundle URLForResource:@"influence" withExtension:@"pdf"];

    // 直接通过 WebSocketManager 发送文件
    [[WebSocketManager sharedManager] sendDataWithFileURL:fileURL];
}
```

#### 停止 WebSocket 服务

```objective-c
- (void)stopWSAction {
    [[WebSocketManager sharedManager] stopServer];
    [self.wsWebloader removeWSWebView];
    self.wsWebloader = nil;
}
```

## API 参考

### LWWebLoader 类

#### 类方法

```objective-c
// 创建 WebLoader 实例
+ (LWWebLoader *)webloader;

// 创建请求体
+ (WLEvaluateBody *)bodyWithURLString:(NSString *)urlString
                               method:(LWWebLoadMethod)method
                      methodArguments:(NSString *)methodArguments
                            userAgent:(NSString *)userAgent
                          contentType:(NSString *)contentType
                             postData:(NSDictionary *)postData
                           uploadData:(NSData *)uploadData;
```

#### 实例方法

```objective-c
// 执行数据加载请求
- (void)evaluateWithBody:(WLEvaluateBody *)evaluateBody
              parentView:(UIView *)parentView
dataLoadCompletionHandler:(void (^)(BOOL, WLHanderBody *, NSError *))dataLoadCompletionHandler;
```

### LWWebLoadMethod 枚举

数据加载方法类型：

```objective-c
typedef NS_OPTIONS(NSUInteger, LWWebLoadMethod) {
    GetData = 0,           // GET 请求
    PostData = 1,          // POST 请求
    UploadData = 2,        // 文件上传
    DownloadFile = 3,      // 文件下载（整体）
    DownloadStream = 4,    // 流式下载
    GetClipboardText = 5,  // 获取剪贴板文本
    NativeLog = 6,         // 原生日志
};
```

### WLHanderBodyType 枚举

响应数据类型：

```objective-c
typedef NS_OPTIONS(NSUInteger, WLHanderBodyType) {
    BodyType_Error = 0,        // 错误
    BodyType_Json = 1,         // JSON 数据
    BodyType_PlainText = 2,    // 纯文本
    BodyType_Data = 3,         // 二进制数据
    BodyType_StreamStart = 4,  // 流开始
    BodyType_Streaming = 5,    // 流传输中
    BodyType_StreamEnd = 6,    // 流结束
    BodyType_Other = 7,        // 其他
};
```

### WLEvaluateBody 类

请求体对象，包含以下属性：

```objective-c
@property (nonatomic, strong) NSURL *url;                   // 请求 URL
@property (nonatomic, copy) NSString *requestId;            // 请求 ID
@property (nonatomic, copy) NSString *evalueteJSMethod;     // 执行的 JS 方法
@property (nonatomic, copy) NSString *methodArguments;      // 方法参数
@property (nonatomic, copy) NSString *jsCode;               // JS 代码
```

### WLHanderBody 类

响应体对象，包含以下属性：

```objective-c
@property (nonatomic, copy) NSString *requestId;            // 请求 ID
@property (nonatomic, assign) WLHanderBodyType bodyType;    // 响应类型
@property (nonatomic, strong) id handlerResult;             // 响应结果
```

## 实现原理

### 架构设计

LWWebLoader 采用了创新的架构设计，主要包含以下几个核心组件：

1. **LWWebLoader**：主控制器，负责管理 WebView 实例和协调数据传输
2. **WLWebView**：自定义 WKWebView，处理页面导航和 JavaScript 执行
3. **LWWLWKScriptMessageHandler**：脚本消息处理器，负责 JavaScript 与原生代码的通信
4. **loader.html**：内置的 HTML 页面，包含数据加载的 JavaScript 实现

### 工作流程

#### 数据加载流程

1. **创建请求**：调用 `bodyWithURLString:method:...` 创建 `WLEvaluateBody` 对象
2. **初始化 WebView**：创建 WLWebView 实例并加载 loader.html
3. **注入脚本**：通过 WKUserScript 注入 JavaScript 代码
4. **执行请求**：在 WebView 中执行 JavaScript fetch 请求
5. **数据传输**：JavaScript 通过 `window.webkit.messageHandlers` 将数据传回原生代码
6. **数据处理**：原生代码接收数据并进行 Base64 解码（如果需要）
7. **回调通知**：通过 completion handler 将结果返回给调用者

#### 流式下载流程

流式下载特别适用于大文件下载，流程如下：

1. **开始下载**：发送 `b64streamstart` 消息，通知开始下载
2. **分块传输**：JavaScript 读取 Response Stream，分块发送 `b64streaming` 消息
3. **写入文件**：原生代码使用 NSOutputStream 将数据块写入临时文件
4. **进度更新**：实时计算并回调下载进度
5. **完成下载**：发送 `b64streamend` 消息，返回文件路径

### 技术特点

#### 1. JavaScript Bridge 通信

使用 WKWebView 的 Script Message Handler 机制实现 JavaScript 与原生代码的双向通信：

```javascript
// JavaScript 向原生发送消息
window.webkit.messageHandlers.bridge.postMessage({
    requestId: requestId,
    type: 'json',
    value: data
});
```

```objective-c
// 原生代码注册消息处理器
[webConfiguration.userContentController addScriptMessageHandler:messageHandler
                                                           name:@"bridge"];
```

#### 2. Base64 编码传输

对于二进制数据，使用 Base64 编码在 JavaScript 和原生代码之间传输：

```javascript
// JavaScript 端编码
function arrayBufferToBase64(buffer) {
    let binary = '';
    let bytes = new Uint8Array(buffer);
    for (let i = 0; i < bytes.byteLength; i++) {
        binary += String.fromCharCode(bytes[i]);
    }
    return window.btoa(binary);
}
```

```objective-c
// Objective-C 端解码
NSData *data = [[NSData alloc] initWithBase64EncodedString:body.value options:0];
```

#### 3. 流式数据处理

利用 Fetch API 的 Stream 功能实现流式下载：

```javascript
fetch(url, requestInit).then(res => {
    let reader = res.body.getReader();
    const totalLength = +res.headers.get('Content-Length');
    let receivedLength = 0;

    let pump = () => reader.read()
        .then(response => {
            if (response.done) {
                // 下载完成
                return null;
            } else {
                receivedLength += response.value.length;
                // 发送数据块到原生代码
                window.webkit.messageHandlers.bridge.postMessage({
                    requestId: requestId,
                    type: 'b64streaming',
                    total: totalLength,
                    received: receivedLength,
                    value: arrayBufferToBase64(response.value.buffer)
                });
                return pump();
            }
        });
    pump();
});
```

#### 4. WebView 生命周期管理

LWWebLoader 实现了智能的 WebView 生命周期管理：

- **复用机制**：对于相同 host 的请求，复用已有的 WebView 实例
- **自动释放**：请求完成后自动清理 WebView，避免内存泄漏
- **delegate 管理**：正确处理 WKNavigationDelegate 和 WKScriptMessageHandler 的注册与注销

## 高级用法

### 自定义 User-Agent

```objective-c
NSString *customUA = @"MyApp/1.0 (iOS; iPhone)";
WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString
                                                       method:GetData
                                              methodArguments:nil
                                                    userAgent:customUA
                                                  contentType:nil
                                                     postData:nil
                                                   uploadData:nil];
```

### 设置 Content-Type

```objective-c
NSString *contentType = @"application/x-www-form-urlencoded";
WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString
                                                       method:PostData
                                              methodArguments:nil
                                                    userAgent:nil
                                                  contentType:contentType
                                                     postData:postData
                                                   uploadData:nil];
```

### 并发请求

LWWebLoader 支持并发请求，每个请求都有独立的 requestId 进行标识：

```objective-c
// 创建多个 webloader 实例进行并发请求
LWWebLoader *loader1 = LWWebLoader.webloader;
LWWebLoader *loader2 = LWWebLoader.webloader;

[loader1 evaluateWithBody:body1 parentView:self.view dataLoadCompletionHandler:^(BOOL finish, WLHanderBody *body, NSError *error) {
    // 处理第一个请求的响应
}];

[loader2 evaluateWithBody:body2 parentView:self.view dataLoadCompletionHandler:^(BOOL finish, WLHanderBody *body, NSError *error) {
    // 处理第二个请求的响应
}];
```

### 调试模式

在 DEBUG 模式下，框架会输出详细的日志信息：

```objective-c
#ifdef DEBUG
#define WLLog(fmt, ...) NSLog((@"%s [Line %d]\n" fmt @"\n\n\n"), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define WLLog(...)
#endif
```

查看 WebKit 缓存路径：

```objective-c
- (void)showWebCachePath {
    NSString *libraryDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                                NSUserDomainMask,
                                                                YES)[0];
    NSString *bundleId = [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
    NSString *webKitFolder = [NSString stringWithFormat:@"%@/Caches/%@/WebKit",
                                                        libraryDir, bundleId];
    NSLog(@"WebKit 缓存目录：%@", webKitFolder);
}
```

## 性能优化建议

### 1. WebView 复用

对于频繁请求同一域名的场景，LWWebLoader 会自动复用 WebView 实例：

```objective-c
// 判断是否可以复用 WebView
BOOL isSameHost = [self.webview.URL.host isEqualToString:evaluateBody.url.host]
                   && self.webview.URL.port.integerValue == evaluateBody.url.port.integerValue;

if (!self.webview || !self.webview.didCommitNavigation || !isSameHost) {
    // 创建新的 WebView
} else {
    // 复用现有 WebView
}
```

### 2. 选择合适的下载方式

- **小文件（< 10MB）**：使用 `DownloadFile` 方式，一次性加载到内存
- **大文件（> 10MB）**：使用 `DownloadStream` 方式，流式写入文件，节省内存

### 3. 内存管理

- 及时释放不再使用的 WebLoader 实例
- 对于流式下载，框架会自动管理 NSOutputStream 的生命周期
- 避免在 completion handler 中持有强引用，使用 `__weak` 修饰符

### 4. 错误处理

完善的错误处理机制：

```objective-c
[self.webloader evaluateWithBody:evaluateBody
                      parentView:self.view
       dataLoadCompletionHandler:^(BOOL finish, WLHanderBody *body, NSError *error) {
    if (error) {
        // 处理网络错误、超时等异常情况
        NSLog(@"请求失败：%@", error.localizedDescription);
        return;
    }

    if (body.bodyType == BodyType_Error) {
        // 处理业务错误
        NSLog(@"业务错误：%@", body.handlerResult);
        return;
    }

    // 正常处理数据
}];
```

## 常见问题

### Q1: 为什么要使用 WKWebView 来加载数据？

**A:** 使用 WKWebView 有以下优势：
1. 独立的网络进程，不会阻塞主线程
2. 可以利用浏览器的缓存机制
3. 支持标准的 Web API（如 Fetch、WebSocket）
4. 可以绕过某些网络限制

### Q2: 流式下载和普通下载有什么区别？

**A:**
- **普通下载（DownloadFile）**：将整个文件加载到内存中，适合小文件
- **流式下载（DownloadStream）**：边下载边写入磁盘，实时监控进度，适合大文件

### Q3: 如何处理 HTTPS 证书验证？

**A:** WKWebView 会自动处理 HTTPS 证书验证。如果需要自定义证书验证逻辑，可以实现 WKNavigationDelegate 的相关方法。

### Q4: 是否支持文件上传进度监控？

**A:** 当前版本不支持上传进度监控。JavaScript Fetch API 的上传进度监控功能尚未得到广泛支持。

### Q5: WebSocket 功能需要额外的依赖吗？

**A:** 是的，WebSocket 功能需要依赖 `LWWebSocket` 库。可以通过 CocoaPods 安装：

```ruby
pod 'LWWebSocket', :source => 'https://gitee.com/lw_ios_project/mylibrepo.git'
```

### Q6: 如何处理大文件下载时的内存问题？

**A:** 使用 `DownloadStream` 方法进行流式下载，框架会自动将数据分块写入磁盘，避免内存溢出：

```objective-c
WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString
                                                       method:DownloadStream
                                              methodArguments:nil
                                                    userAgent:nil
                                                  contentType:nil
                                                     postData:nil
                                                   uploadData:nil];
```

### Q7: 是否支持断点续传？

**A:** 当前版本不直接支持断点续传，但可以通过在 HTTP 请求头中设置 Range 字段来实现。

## 注意事项

1. **线程安全**：LWWebLoader 的所有 API 都应该在主线程调用
2. **WebView 限制**：iOS 对 WKWebView 的数量有限制，避免同时创建过多实例
3. **内存管理**：及时释放不再使用的 WebLoader 实例
4. **网络权限**：确保在 Info.plist 中配置了必要的网络权限
5. **ATS 设置**：如果需要访问 HTTP 资源，需要在 Info.plist 中配置 ATS

Info.plist 配置示例：

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 更新日志

### Version 1.0.0
- 初始版本发布
- 支持 GET、POST、上传、下载功能
- 支持流式下载
- 支持 WebSocket 通信（配合 LWWebSocket 使用）

## 贡献指南

欢迎提交 Issue 和 Pull Request 来帮助改进这个项目。

1. Fork 本仓库
2. 创建你的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交你的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开一个 Pull Request

## 许可证

LWWebLoader 使用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

```
Copyright (c) 2019 luowei <luowei@wodedata.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```

## 作者

**luowei** - [luowei@wodedata.com](mailto:luowei@wodedata.com)

## 相关项目

- [LWWebSocket](https://gitee.com/lw_ios_project/mylibrepo) - WebSocket 支持库

## 致谢

感谢所有为这个项目做出贡献的开发者。

---

如有问题或建议，请通过 [GitHub Issues](https://github.com/luowei/LWWebLoader/issues) 联系我们。
