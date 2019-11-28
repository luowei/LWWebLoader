//
// Created by luowei on 2019/11/4.
//

#import "LWWebLoader.h"
#import <ContactsUI/ContactsUI.h>

static NSString *const defaultUA = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.87 Safari/537.36";

@implementation WLEvaluateBody
-(NSURL *)url{
    if(!_url){
        _url = [NSURL URLWithString:@"http://localhost"];
    }
    return _url;
}
@end

@implementation WLMessageBody
- (id)initWithDictionary:(NSDictionary *_Nonnull)dict {
    self = [super init];
    if (self) {
        NSMutableDictionary *mDict = [dict mutableCopy];
        mDict[@"requestId"] = mDict[@"requestId"] ?: @"";
        mDict[@"type"] = mDict[@"type"] ?: @"";
        mDict[@"value"] = mDict[@"value"] ?: @"";
        mDict[@"done"] = mDict[@"done"] ?: @NO;
        mDict[@"total"] = mDict[@"total"] ?: @0;
        mDict[@"received"] = mDict[@"received"] ?: @0;
        mDict[@"chrunkOrder"] = mDict[@"chrunkOrder"] ?: @0;
        [self setValuesForKeysWithDictionary:mDict];
    }

    return self;
}
@end

@implementation WLHanderBody
+ (instancetype)bodyWithId:(NSString *_Nonnull)rid bodyType:(WLHanderBodyType)bodyType handlerResult:(id)handlerResult {
    WLHanderBody *body = [WLHanderBody new];
    body.requestId = rid;
    body.bodyType = bodyType;
    body.handlerResult = handlerResult;
    return body;
}

@end


@interface WLWebView () <WKNavigationDelegate>
@property(nonatomic, weak) WKWebViewConfiguration *webConfiguration;
@property(nonatomic, strong) WLEvaluateBody *evaluateBody;
@property(nonatomic, assign) BOOL didCommitNavigation;
@property(nonatomic, copy) void (^evaluateJSCompletionHandler)(id, NSError *);
@end

@implementation NSDictionary (LWWLSONString)

-(NSString*) lwwl_jsonStringWithPrettyPrint:(BOOL) prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0) error:&error];
    if (! jsonData) {
        WLLog(@"%s: error: %@", __func__, error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}
@end

@interface LWWebLoader ()
@property(nonatomic, weak) WLWebView *webview;
@property(nonatomic, weak) WSWebView *wsWebview;
@end

@implementation LWWebLoader {

}

+ (LWWebLoader *)webloader {
    return [[LWWebLoader alloc] init];;
}

+ (WLEvaluateBody *)bodyWithURLString:(NSString *)urlString
                               method:(LWWebLoadMethod)method
                      methodArguments:(NSString *)methodArguments
                            userAgent:(NSString *)userAgent
                          contentType:(NSString *)contentType
                             postData:(NSDictionary *)postData
                           uploadData:(NSData *)uploadData {

    NSURL *url = [NSURL URLWithString:urlString ?: @"http://localhost"];
    NSString *requestId = NSUUID.UUID.UUIDString;

    NSMutableDictionary *defaultHeaders = @{
            @"user-agent": defaultUA,
//            @"content-type": @"application/json",
    }.mutableCopy;

    defaultHeaders[@"user-agent"] = userAgent ?: defaultHeaders[@"user-agent"];
    if(contentType){
        defaultHeaders[@"content-type"] = contentType;
    }


    NSString *referrer = [NSString stringWithFormat:@"%@://%@", url.scheme, url.host];
    if(!(url.port.integerValue == 0 || url.port.integerValue == 80)){
        referrer = [referrer stringByAppendingFormat:@":%ld",(long)url.port.integerValue];
    }
    NSString *evalueteJSMethod = @"getData";
    NSDictionary *requestHeader = @{
            @"method": @"GET",
            @"headers": defaultHeaders,
            @"cache": @"no-cache",
            @"referrer": referrer,
    };

    switch (method){
        case PostData:{
            evalueteJSMethod = @"postData";
            NSString *bodyJson = postData ? [postData lwwl_jsonStringWithPrettyPrint:NO] : @"{}";
            requestHeader = @{
                    @"method": @"POST",
                    @"body": bodyJson,
                    @"headers": defaultHeaders,
                    @"cache": @"no-cache",
                    @"referrer": referrer
            };
            break;
        }
        case UploadData:{
            evalueteJSMethod = @"uploadData";
            requestHeader = @{
                    @"method": @"POST",
                    @"headers": defaultHeaders,
                    @"cache": @"no-cache",
                    @"referrer": referrer
            };
            break;
        }
        case DownloadFile:{
            evalueteJSMethod = @"downloadFile";
            defaultHeaders[@"requestId"] = requestId;
            requestHeader = @{
                    @"method": @"GET",
                    @"headers": defaultHeaders,
                    @"cache": @"no-cache",
                    @"referrer": referrer
            };
            break;
        }
        case DownloadStream:{
            evalueteJSMethod = @"downloadStream";
            defaultHeaders[@"requestId"] = requestId;
            requestHeader = @{
                    @"method": @"GET",
                    @"headers": defaultHeaders,
                    @"cache": @"no-cache",
                    @"referrer": referrer
            };
            break;
        }
        case NativeLog:{
            evalueteJSMethod = @"log";
            break;
        }
        case GetClipboardText:{
            evalueteJSMethod = @"getClipboardText";
            break;
        }
        case GetData:
        default:{
            break;
        }
    }

    WLLog(@"==========requestId:%@", requestId);

    WLEvaluateBody *evaluateBody = [WLEvaluateBody new];
    if (method == GetClipboardText) {
        evaluateBody.evalueteJSMethod = evalueteJSMethod;
        evaluateBody.requestId = requestId;
        evaluateBody.url = url;
        evaluateBody.jsCode = [NSString stringWithFormat:@"%@('%@')", evalueteJSMethod, requestId ?: @""];
        return evaluateBody;

    } else if (method == NativeLog) {
        evaluateBody.evalueteJSMethod = evalueteJSMethod;
        evaluateBody.requestId = requestId;
        evaluateBody.url = url;
        evaluateBody.methodArguments = methodArguments;
        evaluateBody.jsCode = [NSString stringWithFormat:@"%@('%@')", evalueteJSMethod, methodArguments ?: @""];
        return evaluateBody;
    }

    NSString *requestHeaderJson = [requestHeader lwwl_jsonStringWithPrettyPrint:NO];

    NSString *jsCode = [NSString stringWithFormat:@"%@('%@','%@',%@)",evalueteJSMethod,requestId,url.absoluteString,requestHeaderJson];
    if(method==UploadData){
        NSString *postDataJson = postData ? [postData lwwl_jsonStringWithPrettyPrint:NO] : @"{}";
        NSString *uploadDataB64String = uploadData ? [uploadData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed] : nil;
        jsCode = [NSString stringWithFormat:@"%@('%@','%@',%@,%@,'%@')",evalueteJSMethod,requestId,url.absoluteString,requestHeaderJson,postDataJson,uploadDataB64String];
    }


    evaluateBody.evalueteJSMethod = evalueteJSMethod;
    evaluateBody.url = url;
    evaluateBody.requestId = requestId;
    evaluateBody.jsCode = jsCode;


    return evaluateBody;
}



/*
- (void)evaluateWithBody:(WLEvaluateBody *)evaluateBody parentView:(UIView *)parentView jsExcuteCompletionHandler:(void (^)(id, NSError *error))jsExcuteCompletionHandler {

    BOOL isSameHost = [self.webview.URL.host isEqualToString:evaluateBody.url.host];
    if(!self.webview || !self.webview.didCommitNavigation || !isSameHost){
        __weak typeof(self) weakSelf = self;
        self.webview = [WLWebView buildWebViewWithEvaluateBody:evaluateBody parentView:parentView dataLoadCompletionHandler:^(BOOL finish,id result,NSError *error) {
            [weakSelf.webview removeFromSuperview];
            weakSelf.webview = nil;

        } jsCompletionHandler:^(id result,NSError *error){
            if(jsExcuteCompletionHandler){
                jsExcuteCompletionHandler(result,error);
            }
        }];

        [self loadPageWithBaseURL:evaluateBody.url];

    }else{
        [self.webview evaluateJavaScript:evaluateBody.jsCode completionHandler:^(id o, NSError *error) {
            if (jsExcuteCompletionHandler) {
                jsExcuteCompletionHandler(o, error);
            }
        }];
    }


}
*/


- (void)evaluateWithBody:(WLEvaluateBody *)evaluateBody parentView:(UIView *)parentView dataLoadCompletionHandler:(void (^)(WLHanderBody *_Nonnull,NSError *))dataLoadCompletionHandler {
    BOOL isSameHost = [self.webview.URL.host isEqualToString:evaluateBody.url.host] && self.webview.URL.port.integerValue == evaluateBody.url.port.integerValue;
    if(!self.webview || !self.webview.didCommitNavigation || !isSameHost){
        __weak typeof(self) weakSelf = self;
        self.webview = [WLWebView buildWebViewWithEvaluateBody:evaluateBody parentView:parentView dataLoadCompletionHandler:^(WLHanderBody *result,NSError *error){
            if(dataLoadCompletionHandler){
                dataLoadCompletionHandler(result,error);
            }
            [weakSelf.webview removeFromSuperview];
            weakSelf.webview = nil;

        } jsCompletionHandler:^(id o, NSError *error) {
            if (error) {
                WLLog(@"======error:%@\n", error);
            }else{
                WLLog(@"======evaluate js %@ ok \n", evaluateBody.evalueteJSMethod);
            }
        }];

        [self loadPageWithBaseURL:evaluateBody.url];

    }else{
        __weak typeof(self) weakSelf = self;
        [self.webview evaluateJavaScript:evaluateBody.jsCode completionHandler:^(id o, NSError *error) {
            if (weakSelf.webview.evaluateJSCompletionHandler) {
                weakSelf.webview.evaluateJSCompletionHandler(o, error);
            }
        }];
    }



}


- (void)loadPageWithBaseURL:(NSURL *_Nonnull)baseURL {

    NSBundle *bundle =  ([NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"LWWebLoader" ofType:@"bundle"]] ?: ([NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"WLWebLoader " ofType:@"bundle"]] ?: [NSBundle mainBundle]));
    NSURL *fileURL = [bundle URLForResource:@"loader" withExtension:@"html"];

    NSData *data = [NSData dataWithContentsOfURL:fileURL];
    if(!data){
        return;
    }
    NSString *faildText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(!faildText){
        return;
    }

    [self.webview loadHTMLString:faildText baseURL:baseURL];

//    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mytest.com/loader.html"]]];

/*
    NSString *defaultHTML = @"";

    [self.webview loadHTMLString:defaultHTML baseURL:[NSURL URLWithString:@"http://mytest.com"]];
*/
}

- (void)wsLoadPageWithBaseURL:(NSURL *_Nonnull)baseURL {

    NSBundle *bundle =  ([NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"LWWebLoader" ofType:@"bundle"]] ?: ([NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"WLWebLoader " ofType:@"bundle"]] ?: [NSBundle mainBundle]));
    NSURL *fileURL = [bundle URLForResource:@"websocket" withExtension:@"html"];

    NSData *data = [NSData dataWithContentsOfURL:fileURL];
    if(!data){
        return;
    }
    NSString *faildText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(!faildText){
        return;
    }

    [self.wsWebview loadHTMLString:faildText baseURL:baseURL];
}


-(void)startWSWebViewWithParentView:(UIView *)parentView receiveWSDataHandler:(void (^)(WLHanderBody *_Nonnull data,NSError *error))receiveWSDataHandler {
    if(!self.wsWebview){
        self.wsWebview = [WSWebView buildWebViewWithParentView:parentView receiveWSDataHandler:receiveWSDataHandler];
    }
    [self wsLoadPageWithBaseURL:[NSURL URLWithString:@"http://localhost"]];
}

-(void)removeWSWebView {
    [self.wsWebview removeFromSuperview];
    self.wsWebview = nil;
}

-(void)wsConnect {
    [self.wsWebview evaluateJavaScript:@"socket.connect();" completionHandler:^(id o, NSError *error) {
        if(error){
            WLLog(@"%s: error: %@", __func__, error.localizedDescription);
            return;
        }
    }];
}

-(void)wsSendData:(NSData *)data {
    NSString *b64 = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed] ?: @"";
    NSString *jsCode = [NSString stringWithFormat:@"socket.sendData('%@');",b64];
    [self.wsWebview evaluateJavaScript:jsCode completionHandler:^(id o, NSError *error) {
        if(error){
            WLLog(@"%s: error: %@", __func__, error.localizedDescription);
            return;
        }
    }];
}

-(void)wsSendString:(NSString *)string {
    NSString *jsCode = [NSString stringWithFormat:@"socket.sendString('%@');",string];
    [self.wsWebview evaluateJavaScript:jsCode completionHandler:^(id o, NSError *error) {
        if(error){
            WLLog(@"%s: error: %@", __func__, error.localizedDescription);
            return;
        }
    }];
}

-(void)wsSendStreamStart {
    NSString *jsCode = [NSString stringWithFormat:@"socket.sendStreamStart();"];
    [self.wsWebview evaluateJavaScript:jsCode completionHandler:^(id o, NSError *error) {
        if(error){
            WLLog(@"%s: error: %@", __func__, error.localizedDescription);
            return;
        }
    }];
}

-(void)wsSendStreaming:(NSData *)data {
    NSString *b64 = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed] ?: @"";
    NSString *jsCode = [NSString stringWithFormat:@"socket.sendStreaming('%@');",b64];
    [self.wsWebview evaluateJavaScript:jsCode completionHandler:^(id o, NSError *error) {
        if(error){
            WLLog(@"%s: error: %@", __func__, error.localizedDescription);
            return;
        }
    }];
}

-(void)wsSendStreamEnd {
    NSString *jsCode = [NSString stringWithFormat:@"socket.sendStreamEnd();"];
    [self.wsWebview evaluateJavaScript:jsCode completionHandler:^(id o, NSError *error) {
        if(error){
            WLLog(@"%s: error: %@", __func__, error.localizedDescription);
            return;
        }
    }];
}

- (void)dealloc {
    WLLog(@"======== dealloc LWWebLoader");
}


@end







#pragma mark - ScriptMessageHandler

@interface LWWLWKScriptMessageHandler : NSObject <WKScriptMessageHandler>
//@property(nonatomic, strong) NSMutableData *dataToDownload;
@property(nonatomic, strong) NSOutputStream *dataStream;
@property(nonatomic, copy) void (^dataLoadCompletionHandler)(WLHanderBody *_Nonnull, NSError *);

@property(nonatomic, copy) NSString *streamFilePath;

@property(nonatomic, strong) NSError *streamError;

+ (LWWLWKScriptMessageHandler *)messageHandleWithEvaluateBody:(WLEvaluateBody *_Nonnull)evaluateBody dataLoadCompletionHandler:(void (^)(WLHanderBody *_Nonnull, NSError *))dataLoadCompletionHandler;

- (void)streamFilePathWithFileName:(NSString *)fileName;
@end
@implementation LWWLWKScriptMessageHandler

- (void)dealloc {
    if(self.dataStream){
        [self.dataStream close];
        self.dataStream = nil;
    }
    WLLog(@"===========dealloc LWWLWKScriptMessageHandler ");
}

+ (LWWLWKScriptMessageHandler *)messageHandleWithEvaluateBody:(WLEvaluateBody *_Nonnull)evaluateBody dataLoadCompletionHandler:(void (^)(WLHanderBody *_Nonnull, NSError *))dataLoadCompletionHandler {
    LWWLWKScriptMessageHandler *messageHandler = [LWWLWKScriptMessageHandler new];
    messageHandler.dataLoadCompletionHandler = dataLoadCompletionHandler;
    [messageHandler streamFilePathWithFileName:evaluateBody.requestId];
    return messageHandler;
}

- (void)streamFilePathWithFileName:(NSString *)fileName {
    _streamFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
}

-(NSString *)streamFilePath {
    if(!_streamFilePath){
        _streamFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:NSUUID.UUID.UUIDString];
    }
    return _streamFilePath;
}

-(NSOutputStream *)dataStream {
    if(!_dataStream){
        _dataStream = [[NSOutputStream alloc] initToFileAtPath:self.streamFilePath append:YES];
    }
    return _dataStream;
}

/*
-(NSMutableData *)dataToDownload{
    if(!_dataToDownload){
        _dataToDownload = [[NSMutableData alloc] init];
    }
    return _dataToDownload;
}
*/

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if([message.name isEqualToString:@"bridge"]){

        if(!message.body){
            if(self.dataLoadCompletionHandler){
                WLHanderBody *body = [WLHanderBody bodyWithId:@"-1" bodyType:BodyType_Error handlerResult:nil];
                self.dataLoadCompletionHandler(body, [NSError errorWithDomain:@"数据为空" code:0 userInfo:nil]);
            }
            return;

        }else if(![message.body isKindOfClass:[NSDictionary class]]){
            if(self.dataLoadCompletionHandler){
                WLHanderBody *body = [WLHanderBody bodyWithId:@"-1" bodyType:BodyType_Error handlerResult:nil];
                self.dataLoadCompletionHandler(body,[NSError errorWithDomain:@"数据格式错误" code:0 userInfo:nil]);
            }
            return;
        }

        WLMessageBody *body = [[WLMessageBody alloc] initWithDictionary:message.body];
        if([body.type isEqualToString:@"json"]) {
            if(self.dataLoadCompletionHandler){
                WLHanderBody *bod = [WLHanderBody bodyWithId:body.requestId bodyType:BodyType_Json handlerResult:body.value];
                self.dataLoadCompletionHandler(bod,nil);
            }

        }else if([body.type isEqualToString:@"plaintext"]) {
            if(self.dataLoadCompletionHandler){
                WLHanderBody *bod = [WLHanderBody bodyWithId:body.requestId bodyType:BodyType_PlainText handlerResult:body.value];
                self.dataLoadCompletionHandler(bod,nil);
            }

        }else if([body.type isEqualToString:@"b64text"]) {
            NSData *data = [[NSData alloc] initWithBase64EncodedString:body.value options:0];
            if(self.dataLoadCompletionHandler){
                WLHanderBody *bod = [WLHanderBody bodyWithId:body.requestId bodyType:BodyType_Data handlerResult:data];
                self.dataLoadCompletionHandler(bod,nil);
            }

        }else if([body.type isEqualToString:@"b64streamstart"]) {
            WLLog(@"=====b64 streaming start !");
            [self.dataStream open];
            if(self.dataLoadCompletionHandler){
                WLHanderBody *bod = [WLHanderBody bodyWithId:body.requestId bodyType:BodyType_StreamStart handlerResult:body.value];
                self.dataLoadCompletionHandler(bod,nil);
            }

        }else if([body.type isEqualToString:@"b64streaming"]) {
            double progress = body.received.doubleValue/body.total.doubleValue;
            WLLog(@"=====b64 streaming %.2f...", progress);
            NSData *data = [[NSData alloc] initWithBase64EncodedString:body.value options:0];
            NSUInteger dataLength = [data length];
            NSInteger writeLen = [self.dataStream write:[data bytes] maxLength:dataLength];
            if(dataLength > writeLen){
                self.streamFilePath = nil;
                self.streamError = [self.dataStream streamError];
                [self.dataStream close];
                self.dataStream = nil;
                return;
            }

            if(self.dataLoadCompletionHandler){
                WLHanderBody *bod = [WLHanderBody bodyWithId:body.requestId bodyType:BodyType_Streaming handlerResult:@(progress)];
                self.dataLoadCompletionHandler(bod,nil);
            }

        }else if([body.type isEqualToString:@"b64streamend"]) {
            WLLog(@"=====b64 streaming finish !");
            if(self.dataStream && self.dataStream.streamStatus != NSStreamStatusClosed){
                [self.dataStream close];
                self.dataStream = nil;
            }
            if(self.dataLoadCompletionHandler){
                WLHanderBody *bod = [WLHanderBody bodyWithId:body.requestId bodyType:BodyType_StreamEnd handlerResult:self.streamFilePath];
                self.dataLoadCompletionHandler(bod,self.streamError);
            }

        }else if([body.type isEqualToString:@"error"]){
            if(self.dataLoadCompletionHandler){
                WLHanderBody *bod = [WLHanderBody bodyWithId:body.requestId bodyType:BodyType_Error handlerResult:body.value];
                self.dataLoadCompletionHandler(bod,nil);
            }
        }

    }else if([message.name isEqualToString:@"nativelog"]){
        WLLog(@"=====nativelog:%@",message.body);
    }

}


@end







#pragma mark - WLWebView

@implementation WLWebView

- (nullable WKNavigation *)loadRequest:(NSURLRequest *)request {
    WLLog(@"===========loadRequest");
    NSMutableDictionary<NSString *, NSString *> *headerFields = [request.allHTTPHeaderFields mutableCopy];
    headerFields[@"referrer"] = @"http://app.wodedata.com";

    NSMutableURLRequest *mRequest = [NSMutableURLRequest new];
    [mRequest setAllHTTPHeaderFields:headerFields];

    return [super loadRequest:request];
}


+ (instancetype)buildWebViewWithEvaluateBody:(WLEvaluateBody *_Nonnull)evaluateBody
                                  parentView:(UIView *_Nonnull)parentView
                   dataLoadCompletionHandler:(void (^)(WLHanderBody *_Nonnull, NSError *))dataLoadCompletionHandler
                         jsCompletionHandler:(void (^)(id, NSError *))jsCompletionHandler {

    WKWebViewConfiguration *webConfiguration = [[WKWebViewConfiguration alloc] init];
    webConfiguration.userContentController = [WKUserContentController new];
    webConfiguration.processPool = [[WKProcessPool alloc] init];
    webConfiguration.applicationNameForUserAgent = [NSString stringWithFormat:@""];

    NSString *injectionJS = @"function log(msg) {window.webkit.messageHandlers.nativelog.postMessage(msg);}";
    WKUserScript *compileFiltersUserScript = [[WKUserScript alloc] initWithSource:injectionJS injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    [webConfiguration.userContentController addUserScript:compileFiltersUserScript];

    LWWLWKScriptMessageHandler *messageHandler = [LWWLWKScriptMessageHandler messageHandleWithEvaluateBody:evaluateBody dataLoadCompletionHandler:dataLoadCompletionHandler];
    [webConfiguration.userContentController addScriptMessageHandler:messageHandler name:@"bridge"];
    [webConfiguration.userContentController addScriptMessageHandler:messageHandler name:@"clipboard"];
    [webConfiguration.userContentController addScriptMessageHandler:messageHandler name:@"nativelog"];

    WLWebView *webView = [[WLWebView alloc] initWithFrame:CGRectMake(0, 0, 1, 1) configuration:webConfiguration];
    [parentView addSubview:webView];
    webView.navigationDelegate = webView;
    webView.evaluateBody = evaluateBody;
    webView.evaluateJSCompletionHandler = jsCompletionHandler;
    return webView;
}

- (void)dealloc {
    WLLog(@"===========dealloc WLWebView ");
    if(@available(iOS 11.0,*)){
        [self.configuration.userContentController removeAllContentRuleLists];
    }
    [self.configuration.userContentController removeAllUserScripts];
    [self.configuration.userContentController removeScriptMessageHandlerForName:@"bridge"];
    [self.configuration.userContentController removeScriptMessageHandlerForName:@"clipboard"];
    [self.configuration.userContentController removeScriptMessageHandlerForName:@"nativelog"];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    WLLog(@"===========webview didStartProvisionalNavigation : %@",webView.URL.absoluteString);
}

/*
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);

}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

//参考：iOS WKWebView基本使用总结:https://lishibo-ios.github.io/2018/06/11/WKWebView/
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    WLLog(@"===========webView didStartProvisionalNavigation");
}
*/
// 当内容开始返回时调用 内容开始到达主帧时被调用（即将完成）
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    WLLog(@"===========webview didCommitNavigation : %@",webView.URL.absoluteString);

}


// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    WLLog(@"===========webview didFinishNavigation : %@",webView.URL.absoluteString);

    __weak typeof(self) weakSelf = self;
    [self evaluateJavaScript:self.evaluateBody.jsCode completionHandler:^(id o, NSError *error) {
        weakSelf.didCommitNavigation = YES;
        if (weakSelf.evaluateJSCompletionHandler) {
            weakSelf.evaluateJSCompletionHandler(o, error);
        }
    }];

    [self showWebCachePath];
}

- (void)showWebCachePath {
    /* 取得Library文件夹的位置*/
    NSString *libraryDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask, YES)[0];
    /* 取得bundle id，用作文件拼接用*/
    NSString *bundleId = [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
    /* * 拼接缓存地址，具体目录为App/Library/Caches/你的APPBundleID/fsCachedData */
    NSString *webKitFolderInCachesfs = [NSString stringWithFormat:@"%@/Caches/%@/WebKit",libraryDir,bundleId];
    WLLog(@"==========webkit folder: %@",webKitFolderInCachesfs);
}

@end



@interface WSWKScriptMessageHandler : NSObject <WKScriptMessageHandler>
@property(nonatomic, copy) void (^receiveWSDataHandler)(WLHanderBody *_Nonnull, NSError *);
@property(nonatomic, strong) NSOutputStream *dataStream;
@property(nonatomic, copy) NSString *streamFilePath;
@property(nonatomic, strong) NSError *streamError;
@end

@implementation WSWKScriptMessageHandler
+(instancetype)buildMessageHandleWithReceiveWSDataHandler:(void (^)(WLHanderBody *_Nonnull data,NSError *error))receiveWSDataHandler {
    WSWKScriptMessageHandler *messageHandler = [WSWKScriptMessageHandler new];
    messageHandler.receiveWSDataHandler = receiveWSDataHandler;
    return messageHandler;
}

- (void)dealloc {
    WLLog(@"===========dealloc WSWKScriptMessageHandler ");
}

-(NSString *)streamFilePath {
    if(!_streamFilePath){
        _streamFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:NSUUID.UUID.UUIDString];
    }
    return _streamFilePath;
}

-(NSOutputStream *)dataStream {
    if(!_dataStream){
        _dataStream = [[NSOutputStream alloc] initToFileAtPath:self.streamFilePath append:YES];
    }
    return _dataStream;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if([message.name isEqualToString:@"bridge"]){

        if(!message.body){
            if(self.receiveWSDataHandler){
                WLHanderBody *body = [WLHanderBody bodyWithId:@"-1" bodyType:BodyType_Error handlerResult:nil];
                self.receiveWSDataHandler(body, [NSError errorWithDomain:@"数据为空" code:0 userInfo:nil]);
            }
            return;

        }else if(![message.body isKindOfClass:[NSDictionary class]]){
            if(self.receiveWSDataHandler){
                WLHanderBody *body = [WLHanderBody bodyWithId:@"-1" bodyType:BodyType_Error handlerResult:nil];
                self.receiveWSDataHandler(body,[NSError errorWithDomain:@"数据格式错误" code:0 userInfo:nil]);
            }
            return;
        }

        WLMessageBody *body = [[WLMessageBody alloc] initWithDictionary:message.body];
        if([body.type isEqualToString:@"json"]) {
            if(self.receiveWSDataHandler){
                WLHanderBody *bod = [WLHanderBody bodyWithId:body.requestId bodyType:BodyType_Json handlerResult:body.value];
                self.receiveWSDataHandler(bod,nil);
            }

        }else if([body.type isEqualToString:@"plaintext"]) {
            if(self.receiveWSDataHandler){
                WLHanderBody *bod = [WLHanderBody bodyWithId:body.requestId bodyType:BodyType_PlainText handlerResult:body.value];
                self.receiveWSDataHandler(bod,nil);
            }

        }else if([body.type isEqualToString:@"b64text"]) {
            NSData *data = [[NSData alloc] initWithBase64EncodedString:body.value options:0];
            if(self.receiveWSDataHandler){
                WLHanderBody *bod = [WLHanderBody bodyWithId:body.requestId bodyType:BodyType_Data handlerResult:data];
                self.receiveWSDataHandler(bod,nil);
            }

        }else if([body.type isEqualToString:@"b64streamstart"]) {
            WLLog(@"=====b64 streaming start !");
            [self.dataStream open];
            if(self.receiveWSDataHandler){
                WLHanderBody *bod = [WLHanderBody bodyWithId:body.requestId bodyType:BodyType_StreamStart handlerResult:body.value];
                self.receiveWSDataHandler(bod,nil);
            }

        }else if([body.type isEqualToString:@"b64streaming"]) {
            WLLog(@"=====b64 streaming ...");
            NSData *data = [[NSData alloc] initWithBase64EncodedString:body.value options:0];
            NSUInteger dataLength = [data length];
            NSInteger writeLen = [self.dataStream write:[data bytes] maxLength:dataLength];
            if(dataLength > writeLen){
                self.streamFilePath = nil;
                self.streamError = [self.dataStream streamError];
                [self.dataStream close];
                self.dataStream = nil;
                return;
            }

            if(self.receiveWSDataHandler){
                WLHanderBody *bod = [WLHanderBody bodyWithId:body.requestId bodyType:BodyType_Streaming handlerResult:nil];
                self.receiveWSDataHandler(bod,nil);
            }

        }else if([body.type isEqualToString:@"b64streamend"]) {
            WLLog(@"=====b64 streaming finish !");
            if(self.dataStream && self.dataStream.streamStatus != NSStreamStatusClosed){
                [self.dataStream close];
                self.dataStream = nil;
            }
            if(self.receiveWSDataHandler){
                WLHanderBody *bod = [WLHanderBody bodyWithId:body.requestId bodyType:BodyType_StreamEnd handlerResult:self.streamFilePath];
                self.receiveWSDataHandler(bod,self.streamError);
            }

        }else if([body.type isEqualToString:@"error"]){
            if(self.receiveWSDataHandler){
                WLHanderBody *bod = [WLHanderBody bodyWithId:body.requestId bodyType:BodyType_Error handlerResult:body.value];
                self.receiveWSDataHandler(bod,nil);
            }
        }else if([body.type isEqualToString:@"ws_opened"]){
            if(self.receiveWSDataHandler){
                WLHanderBody *bod = [WLHanderBody bodyWithId:body.requestId bodyType:BodyType_WSOpened handlerResult:nil];
                self.receiveWSDataHandler(bod,nil);
            }
        }else if([body.type isEqualToString:@"ws_closed"]){
            if(self.receiveWSDataHandler){
                WLHanderBody *bod = [WLHanderBody bodyWithId:body.requestId bodyType:BodyType_WSClosed handlerResult:nil];
                self.receiveWSDataHandler(bod,nil);
            }
        }

    }else if([message.name isEqualToString:@"nativelog"]){
        WLLog(@"=====nativelog:%@",message.body);
    }
}
@end

@implementation WSWebView
+ (instancetype)buildWebViewWithParentView:(UIView *)parentView receiveWSDataHandler:(void (^)(WLHanderBody *_Nonnull data,NSError *error))receiveWSDataHandler {
    WKWebViewConfiguration *webConfiguration = [[WKWebViewConfiguration alloc] init];
    webConfiguration.userContentController = [WKUserContentController new];
    webConfiguration.processPool = [[WKProcessPool alloc] init];
    webConfiguration.applicationNameForUserAgent = [NSString stringWithFormat:@""];


    WSWKScriptMessageHandler *messageHandler = [WSWKScriptMessageHandler buildMessageHandleWithReceiveWSDataHandler:receiveWSDataHandler];
    [webConfiguration.userContentController addScriptMessageHandler:messageHandler name:@"bridge"];
    [webConfiguration.userContentController addScriptMessageHandler:messageHandler name:@"nativelog"];

    WSWebView *webView = [[WSWebView alloc] initWithFrame:CGRectMake(0, 0, 1, 1) configuration:webConfiguration];
    [parentView addSubview:webView];
    webView.navigationDelegate = webView;
    return webView;
}
- (void)dealloc {
    WLLog(@"===========dealloc WSWebView ");
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    WLLog(@"===========ws webview didFinishNavigation : %@",webView.URL.absoluteString);
}
@end



