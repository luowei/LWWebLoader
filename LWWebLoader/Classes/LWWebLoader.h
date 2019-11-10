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

@interface LWWebLoader : NSObject
+ (void)evaluateJavaScript:(NSString *)jsCode completionHandler:(void (^)(id, NSError *error))completionHandler;
+ (void)evaluateJavaScript:(NSString *)jsCode url:(NSURL *)url completionHandler:(void (^)(id, NSError *error))completionHandler;
@end


@interface WLWebView : WKWebView
+(instancetype)buildWebView;

- (void)evaluateJS:(NSString *)jsCode completionHandler:(void (^)(id, NSError *))completionHandler;
@end