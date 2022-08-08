# LWWebLoader

[![CI Status](https://img.shields.io/travis/luowei/LWWebLoader.svg?style=flat)](https://travis-ci.org/luowei/LWWebLoader)
[![Version](https://img.shields.io/cocoapods/v/LWWebLoader.svg?style=flat)](https://cocoapods.org/pods/LWWebLoader)
[![License](https://img.shields.io/cocoapods/l/LWWebLoader.svg?style=flat)](https://cocoapods.org/pods/LWWebLoader)
[![Platform](https://img.shields.io/cocoapods/p/LWWebLoader.svg?style=flat)](https://cocoapods.org/pods/LWWebLoader)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### WebSocket Turnner  


```Objective-C

-(LWWebLoader *)wsWebloader {
    if(!_webloader){
        _webloader = LWWebLoader.webloader;
    }
    return _webloader;
}

- (void)startWSAction {
    NSString *webPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    [[WebSocketManager sharedManager] startServerWithPort:11335 webPath:webPath];

    [WebSocketManager sharedManager].handleReceiveMessage = ^(uint32_t messageType,NSString *message){

        switch (messageType){
            case SocketMessageType_String:{
                NSLog(@"handleReceiveMessage Type:%d,text:%@", messageType, message);
                break;
            }
            default:{
                break;
            }
        }

    };

    [WebSocketManager sharedManager].handleReceiveData = ^(uint32_t messageType,NSData *data){
        switch (messageType){
            case SocketMessageType_StreamStart:{
                NSLog(@"handleReceiveMessage StreamStart");
                break;
            }
            case SocketMessageType_Streaming:{
                break;
            }
            case SocketMessageType_StreamEnd:{
                NSString *dataPath = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"handleReceiveMessage StreamEnd, dataPath:%@",dataPath);
                break;
            }
            case SocketMessageType_Data:{
                //handle received binary data
                NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"handleReceiveData Type:%d,text:%@", messageType, text);
                break;
            }
            default:{
                break;
            }
        }

    };

    void (^receiveWSDataHandler)(WLHanderBody *_Nonnull, NSError *) = ^(WLHanderBody *body,NSError *error){
        switch (body.bodyType) {
            case BodyType_Error: {
                NSLog(@"======ws error:%@\n", body.handlerResult);
                break;
            }
            case BodyType_PlainText: {
                NSLog(@"==========ws handlerBody text:%@", body.handlerResult);
                break;
            }
            case BodyType_Data: {
                NSString *dataString = [[NSString alloc] initWithData:body.handlerResult encoding:NSUTF8StringEncoding];
                NSLog(@"==========ws data:%@", dataString);
//                [self writeToFileWithData:body.handlerResult];
                break;
            }
            case BodyType_StreamStart: {
                NSLog(@"==========ws stream start:%@", body.handlerResult);
                break;
            }
            case BodyType_Streaming: {
                NSLog(@"==========ws streaming  ...");
                break;
            }
            case BodyType_StreamEnd: {
                NSLog(@"==========ws streamed file path:%@", body.handlerResult);
                break;
            }
            case BodyType_WSOpened:{
                NSLog(@"==========ws opened ! ");
                break;
            }
            case BodyType_WSClosed:{
                NSLog(@"==========ws closed ! ");
                break;
            }
            default: {
                break;
            }
        }
    };

    [self.wsWebloader startWSWebViewWithParentView:self.view receiveWSDataHandler:receiveWSDataHandler];
}

- (void)stopWSAction {
    [[WebSocketManager sharedManager] stopServer];
    [self.wsWebloader removeWSWebView];
    self.wsWebloader = nil;
}

- (void)connectWSAction {
    [self.wsWebloader wsConnect];

}

- (void)sendWSByJSSendAction {
//    NSData *data = [@"aaaaa" dataUsingEncoding:NSUTF8StringEncoding];
//    [self.wsWebloader wsSendData:data];

//    NSString *message = @"Welcome WebSocket Zone!";
//    [self.wsWebloader wsSendString:message];

    NSBundle *bundle =  ([NSBundle bundleWithPath:[[NSBundle bundleForClass:[self.wsWebloader class]] pathForResource:@"LWWebLoader" ofType:@"bundle"]] ?: ([NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"WLWebLoader " ofType:@"bundle"]] ?: [NSBundle mainBundle]));
    NSURL *fileURL = [bundle URLForResource:@"influence" withExtension:@"pdf"];

    //发送文件
    [self.wsWebloader wsSendStreamStart];

    NSError *error;
    NSFileHandle * fileHandle = [NSFileHandle fileHandleForReadingFromURL:fileURL error:&error];
    if(error){
        NSLog(@"===error:%@",error.localizedDescription);
    }
    NSData * data = nil;
    while ((data = [fileHandle readDataOfLength:10240])) {
        if(data.length > 0){
            [self.wsWebloader wsSendStreaming:data];
        }else{
            break;
        }
    }

    [self.wsWebloader wsSendStreamEnd];

}

- (void)sendWSByNativeSendAction {
//    NSData *data = [@"aaaaa" dataUsingEncoding:NSUTF8StringEncoding];
//    [[WebSocketManager sharedManager] sendData:data];

//    NSString *message = @"世界你好! 你好! 你好! 你好! 你好!";
//    [[WebSocketManager sharedManager] sendMessage:message];

//    NSString *message = @"我是StringData, 你好! 你好! 你好! 你好! 你好!";
//    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
//    [[WebSocketManager sharedManager] sendData:data];

    NSBundle *bundle =  ([NSBundle bundleWithPath:[[NSBundle bundleForClass:[self.wsWebloader class]] pathForResource:@"LWWebLoader" ofType:@"bundle"]] ?: ([NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"WLWebLoader " ofType:@"bundle"]] ?: [NSBundle mainBundle]));
    NSURL *fileURL = [bundle URLForResource:@"influence" withExtension:@"pdf"];

    [[WebSocketManager sharedManager] sendDataWithFileURL:fileURL];

}

```


### WKWebView Turnner

```Objective-C
-(LWWebLoader *)webloader {
    _webloader = LWWebLoader.webloader;
    return _webloader;
}


- (void)writeToFileWithData:(NSData *)data {
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"aaaa.zip"];
    NSError *err;
    [(NSData *)data writeToFile:filePath options:NSDataWritingAtomic error:&err];
    if(err){
        NSLog(@"==========下载完成，但保存文件失败");
    }else{
        NSLog(@"==========下载完成，文件保存在:%@", filePath);
    }
}


- (void)btn0Action {

}

- (void)getBtnAction {
    NSString *urlString = @"http://mytest.com/test.json";
//    NSString *urlString = @"http://mytest.com/mitm.html";
//    NSString *urlString = @"http://mytest.com/DeepRPC.zip";
//    NSString *urlString = @"http://wodedata.com/MyResource/MyInputMethod/App/OtherVC_v14.json";

    WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString method:GetData methodArguments:nil userAgent:nil contentType:nil postData:nil uploadData:nil];
    __weak typeof(self) weakSelf = self;
    [self.webloader evaluateWithBody:evaluateBody parentView:self.view dataLoadCompletionHandler:^(WLHanderBody *body,NSError *error){
        if (error) {
            NSLog(@"======error:%@\n", error);
            return;
        }

        [weakSelf handleWithBody:body];
    }];
}

- (void)postBtnAction {
//    NSString *urlString = @"http://mytest.com/test.json";
    NSString *urlString = @"http://mytest.com/test.zip";

    NSString *contentType = @"application/json";
    WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString method:PostData methodArguments:nil userAgent:nil contentType:contentType postData:@{@"name":@"张三"} uploadData:nil];
    __weak typeof(self) weakSelf = self;
    [self.webloader evaluateWithBody:evaluateBody parentView:self.view dataLoadCompletionHandler:^(WLHanderBody *body, NSError *error) {
        if (error) {
            NSLog(@"======error:%@\n",error);
            return;
        }

        [weakSelf handleWithBody:body];

    }];
}


- (void)uploadBtnAction {
//    NSString *urlString = @"http://mytest.com/test.json";
    NSString *urlString = @"http://mytest.com:8000";

    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"aaaa.zip"];

    NSString *contentType = nil;
    NSData *uploadData = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *postData = @{@"filename":@"aaaa.zip",@"name":@"张三"};
    WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString method:UploadData methodArguments:nil userAgent:nil contentType:contentType postData:postData uploadData:uploadData];
    __weak typeof(self) weakSelf = self;
    [self.webloader evaluateWithBody:evaluateBody parentView:self.view dataLoadCompletionHandler:^( WLHanderBody *body, NSError *error) {
        if (error) {
            NSLog(@"======error:%@\n", error);
            return;
        }

        [weakSelf handleWithBody:body];
    }];
}

-(void)downloadFileBtnAction {

    NSString *urlString = @"http://mytest.com/test.zip";
    WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString method:DownloadFile methodArguments:nil userAgent:nil contentType:nil postData:nil uploadData:nil];
    __weak typeof(self) weakSelf = self;
    [self.webloader evaluateWithBody:evaluateBody parentView:self.view dataLoadCompletionHandler:^(WLHanderBody *body, NSError *error) {
        //handle file，result is NSData
        if (error) {
            NSLog(@"======error:%@\n", error);
            return;
        }

        [weakSelf handleWithBody:body];
    }];

}

- (void)downloadStreamBtnAction {

    NSString *urlString = @"http://oss.wodedata.com/Fonts/%E5%8D%8E%E6%96%87%E9%9A%B6%E4%B9%A6.ttf";
//    NSString *urlString = @"http://mytest.com/test.zip";
    WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString method:DownloadStream methodArguments:nil userAgent:nil contentType:nil postData:nil uploadData:nil];
    __weak typeof(self) weakSelf = self;
    [self.webloader evaluateWithBody:evaluateBody parentView:self.view dataLoadCompletionHandler:^(WLHanderBody *body, NSError *error) {
        //handle file，data is file path
        if (error) {
            NSLog(@"======error:%@\n", error);
            return;
        }

        [weakSelf handleWithBody:body];
    }];

}

-(void)getClipboardTextBtnAction {
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSLog(@"======tem dir:%@",NSTemporaryDirectory());

//    WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:nil method:NativeLog methodArguments:@"aaaaaaaaa" userAgent:nil contentType:nil postData:nil uploadData:nil];
//    [self.webloader evaluateWithBody:evaluateBody parentView:self.view dataLoadCompletionHandler:^(BOOL finish,id result, NSError *error) {
//        if ([result isKindOfClass:[NSString class]]) {
//            NSLog(@"==========log:%@", result);
//        }
//    }];

}

-(void)safariVCBtnAction{
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"http://wodedata.com"] entersReaderIfAvailable:YES];
    safariVC.delegate = self;
    [self presentViewController:safariVC animated:YES completion:nil];
}



- (void)handleWithBody:(WLHanderBody *)body {
    switch (body.bodyType) {
        case BodyType_Error: {
            NSLog(@"======error:%@\n", body.handlerResult);
            break;
        }
        case BodyType_Json: {
            NSLog(@"==========handlerBody json:%@", body.handlerResult);
            break;
        }
        case BodyType_PlainText: {
            NSLog(@"==========handlerBody text:%@", body.handlerResult);
            break;
        }
        case BodyType_Data: {
            [self writeToFileWithData:body.handlerResult];
            break;
        }
        case BodyType_StreamStart: {
            NSLog(@"==========stream start:%@", body.handlerResult);
            break;
        }
        case BodyType_Streaming: {
            NSLog(@"==========streaming :%.2f ...", [body.handlerResult doubleValue]);
            break;
        }
        case BodyType_StreamEnd: {
            NSLog(@"==========streamed file path:%@", body.handlerResult);
            break;
        }

        default: {
            break;
        }
    }
}

```

## Requirements

## Installation

LWWebLoader is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LWWebLoader'
```

## Author

luowei, luowei@wodedata.com

## License

LWWebLoader is available under the MIT license. See the LICENSE file for more info.
