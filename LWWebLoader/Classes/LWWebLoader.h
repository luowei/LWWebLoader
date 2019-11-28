//
// Created by luowei on 2019/11/4.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@class WLWebView;

#ifdef DEBUG
#define WLLog(fmt, ...) NSLog((@"%s [Line %d]\n" fmt @"\n\n\n"), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define WLLog(...)
#endif

typedef NS_OPTIONS(NSUInteger, LWWebLoadMethod) {
    GetData = 0,
    PostData = 1,
    UploadData = 2,
    DownloadFile = 3,
    DownloadStream = 4,
    GetClipboardText = 5,
    NativeLog = 6,
};

@interface WLEvaluateBody : NSObject
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, copy) NSString *requestId;
@property (nonatomic, copy) NSString *evalueteJSMethod;
@property (nonatomic, copy) NSString *methodArguments;
@property (nonatomic, copy) NSString *jsCode;

//@property (nonatomic, strong) NSDictionary *headers;
//@property (nonatomic, strong) NSDictionary *postData;
//@property (nonatomic, strong) NSData *uploadData;

@end

@interface WLMessageBody : NSObject
@property (nonatomic, copy) NSString *requestId;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) NSNumber *done;
@property (nonatomic, strong) NSNumber *chrunkOrder;
@property (nonatomic, strong) NSNumber *total;
@property (nonatomic, strong) NSNumber *received;
@property (nonatomic, copy) NSString *value;
- (id)initWithDictionary:(NSDictionary *_Nonnull)dict;
@end


typedef NS_OPTIONS(NSUInteger, WLHanderBodyType) {
    BodyType_Error = 0,
    BodyType_Json = 1,
    BodyType_PlainText = 2,
    BodyType_Data = 3,
    BodyType_StreamStart = 4,
    BodyType_Streaming = 5,
    BodyType_StreamEnd = 6,
    BodyType_WSOpened = 7,
    BodyType_WSClosed = 8,
};


@interface WLHanderBody : NSObject
@property (nonatomic, copy) NSString *requestId;
@property (nonatomic, assign) WLHanderBodyType bodyType;
@property (nonatomic, strong) id handlerResult;
+ (instancetype)bodyWithId:(NSString *_Nonnull)rid bodyType:(WLHanderBodyType)bodyType handlerResult:(id)handlerResult;
@end


@interface NSDictionary (LWWLSONString)
-(NSString*) lwwl_jsonStringWithPrettyPrint:(BOOL) prettyPrint;
@end

@interface LWWebLoader : NSObject
+ (LWWebLoader *)webloader;

+ (WLEvaluateBody *)bodyWithURLString:(NSString *)urlString
                               method:(LWWebLoadMethod)method
                      methodArguments:(NSString *)methodArguments
                            userAgent:(NSString *)userAgent
                          contentType:(NSString *)contentType
                             postData:(NSDictionary *)postData
                           uploadData:(NSData *)uploadData;
//- (void)evaluateWithBody:(WLEvaluateBody *)evaluateBody parentView:(UIView *)parentView jsExcuteCompletionHandler:(void (^)(id, NSError *error))jsExcuteCompletionHandler;
- (void)evaluateWithBody:(WLEvaluateBody *)evaluateBody parentView:(UIView *)parentView dataLoadCompletionHandler:(void (^)(WLHanderBody *_Nonnull,NSError *))dataLoadCompletionHandler;

-(void)startWSWebViewWithParentView:(UIView *)parentView receiveWSDataHandler:(void (^)(WLHanderBody *_Nonnull data,NSError *error))receiveWSDataHandler;

-(void)removeWSWebView;

-(void)wsConnect;
-(void)wsSendData:(NSData *)data;
-(void)wsSendString:(NSString *)string;
-(void)wsSendStreamStart;
-(void)wsSendStreaming:(NSData *)data;
-(void)wsSendStreamEnd;

@end


@interface WLWebView : WKWebView

+ (instancetype)buildWebViewWithEvaluateBody:(WLEvaluateBody *_Nonnull)evaluateBody
                                  parentView:(UIView *_Nonnull)parentView
                   dataLoadCompletionHandler:(void (^)(WLHanderBody *_Nonnull, NSError *))dataLoadCompletionHandler
                         jsCompletionHandler:(void (^)(id, NSError *))jsCompletionHandler;

@end


@interface WSWebView : WKWebView <WKNavigationDelegate>

+ (instancetype)buildWebViewWithParentView:(UIView *)parentView receiveWSDataHandler:(void (^)(WLHanderBody *_Nonnull data,NSError *error))receiveWSDataHandler;

@end