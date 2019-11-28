//
//  WLViewController.m
//  LWWebLoader
//
//  Created by luowei on 11/04/2019.
//  Copyright (c) 2019 luowei. All rights reserved.
//

#import "WLViewController.h"
#import <LWWebLoader/LWWebLoader.h>
#import <SafariServices/SafariServices.h>
#import <LWWebSocket/WebSocketManager.h>

@interface WLViewController () <SFSafariViewControllerDelegate>

@property(nonatomic, strong) LWWebLoader *webloader;
@property(nonatomic, strong) LWWebLoader *wsWebloader;
@end

@implementation WLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UIButton *btn0 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn0.frame = CGRectMake(100, 100, 160, 40);
    [btn0 setTitle:@"打开新页" forState:UIControlStateNormal];
    [self.view addSubview:btn0];
    [btn0 addTarget:self action:@selector(btn0Action) forControlEvents:UIControlEventTouchUpInside];

    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn1.frame = CGRectMake(100, 140, 160, 40);
    [btn1 setTitle:@"getData" forState:UIControlStateNormal];
    [self.view addSubview:btn1];
    [btn1 addTarget:self action:@selector(getBtnAction) forControlEvents:UIControlEventTouchUpInside];

    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn2.frame = CGRectMake(100, 180, 160, 40);
    [btn2 setTitle:@"postData" forState:UIControlStateNormal];
    [self.view addSubview:btn2];
    [btn2 addTarget:self action:@selector(postBtnAction) forControlEvents:UIControlEventTouchUpInside];

    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn3.frame = CGRectMake(100, 220, 160, 40);
    [btn3 setTitle:@"uploadData" forState:UIControlStateNormal];
    [self.view addSubview:btn3];
    [btn3 addTarget:self action:@selector(uploadBtnAction) forControlEvents:UIControlEventTouchUpInside];

    UIButton *btn4 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn4.frame = CGRectMake(100, 260, 160, 40);
    [btn4 setTitle:@"downloadFile" forState:UIControlStateNormal];
    [self.view addSubview:btn4];
    [btn4 addTarget:self action:@selector(downloadFileBtnAction) forControlEvents:UIControlEventTouchUpInside];

    UIButton *btn5 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn5.frame = CGRectMake(100, 300, 160, 40);
    [btn5 setTitle:@"downloadStream" forState:UIControlStateNormal];
    [self.view addSubview:btn5];
    [btn5 addTarget:self action:@selector(downloadStreamBtnAction) forControlEvents:UIControlEventTouchUpInside];

    UIButton *btn6 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn6.frame = CGRectMake(100, 340, 160, 40);
    [btn6 setTitle:@"getClipboardText" forState:UIControlStateNormal];
    [self.view addSubview:btn6];
    [btn6 addTarget:self action:@selector(getClipboardTextBtnAction) forControlEvents:UIControlEventTouchUpInside];

    UIButton *btn7 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn7.frame = CGRectMake(100, 380, 160, 40);
    [btn7 setTitle:@"SFSafariViewController" forState:UIControlStateNormal];
    [self.view addSubview:btn7];
    [btn7 addTarget:self action:@selector(safariVCBtnAction) forControlEvents:UIControlEventTouchUpInside];

    UIButton *btn8 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn8.frame = CGRectMake(100, 420, 160, 30);
    [btn8 setTitle:@"start ws" forState:UIControlStateNormal];
    [self.view addSubview:btn8];
    [btn8 addTarget:self action:@selector(startWSAction) forControlEvents:UIControlEventTouchUpInside];

    UIButton *btn9 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn9.frame = CGRectMake(100, 450, 160, 30);
    [btn9 setTitle:@"stop ws" forState:UIControlStateNormal];
    [self.view addSubview:btn9];
    [btn9 addTarget:self action:@selector(stopWSAction) forControlEvents:UIControlEventTouchUpInside];

    UIButton *btn10 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn10.frame = CGRectMake(100, 480, 160, 30);
    [btn10 setTitle:@"connect ws" forState:UIControlStateNormal];
    [self.view addSubview:btn10];
    [btn10 addTarget:self action:@selector(connectWSAction) forControlEvents:UIControlEventTouchUpInside];


    UIButton *btn11 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn11.frame = CGRectMake(100, 510, 160, 30);
    [btn11 setTitle:@"send ws by js" forState:UIControlStateNormal];
    [self.view addSubview:btn11];
    [btn11 addTarget:self action:@selector(sendWSByJSSendAction) forControlEvents:UIControlEventTouchUpInside];


    UIButton *btn12 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn12.frame = CGRectMake(100, 540, 160, 30);
    [btn12 setTitle:@"send ws by native" forState:UIControlStateNormal];
    [self.view addSubview:btn12];
    [btn12 addTarget:self action:@selector(sendWSByNativeSendAction) forControlEvents:UIControlEventTouchUpInside];


}


#pragma mark - WebSocket Turnner

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
                //处理接收到的二进制数据
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



#pragma mark - WKWebView Turnner


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
        //处理文件，result为NSData
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
        //处理文件，data为文件路径
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

#pragma mark - SFSafariViewControllerDelegate

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller{
    NSLog(@"==[%s,%s] %i : %s  ",__DATE__,__TIME__,__LINE__,__FUNCTION__);
}


- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully{
    NSLog(@"==[%s,%s] %i : %s  ",__DATE__,__TIME__,__LINE__,__FUNCTION__);
}


- (void)safariViewController:(SFSafariViewController *)controller initialLoadDidRedirectToURL:(NSURL *)URL{
    NSLog(@"==[%s,%s] %i : %s  ",__DATE__,__TIME__,__LINE__,__FUNCTION__);
}


@end

