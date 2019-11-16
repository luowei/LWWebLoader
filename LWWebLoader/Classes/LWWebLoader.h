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
    NativeLog = 5,
};

@interface WLEvaluateBody : NSObject
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, copy) NSString *requestId;
@property (nonatomic, copy) NSString *evalueteJSMethod;
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

@interface NSDictionary (LWWLSONString)
-(NSString*) lwwl_jsonStringWithPrettyPrint:(BOOL) prettyPrint;
@end

@interface LWWebLoader : NSObject
+ (LWWebLoader *)webloader;

+ (WLEvaluateBody *)bodyWithURLString:(NSString *)urlString
                               method:(LWWebLoadMethod)method
                            userAgent:(NSString *)userAgent
                          contentType:(NSString *)contentType
                             postData:(NSDictionary *)postData
                           uploadData:(NSData *)uploadData;
- (void)evaluateWithBody:(WLEvaluateBody *)evaluateBody parentView:(UIView *)parentView jsExcuteCompletionHandler:(void (^)(id, NSError *error))jsExcuteCompletionHandler;
- (void)evaluateWithBody:(WLEvaluateBody *)evaluateBody parentView:(UIView *)parentView dataLoadCompletionHandler:(void (^)(BOOL,id,NSError *))dataLoadCompletionHandler;

@end


@interface WLWebView : WKWebView

+ (instancetype)buildWebViewWithEvaluateBody:(WLEvaluateBody *_Nonnull)evaluateBody
                                  parentView:(UIView *_Nonnull)parentView
                   dataLoadCompletionHandler:(void (^)(BOOL, id, NSError *))dataLoadCompletionHandler
                         jsCompletionHandler:(void (^)(id, NSError *))jsCompletionHandler;

@end