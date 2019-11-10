//
//  WLViewController.m
//  LWWebLoader
//
//  Created by luowei on 11/04/2019.
//  Copyright (c) 2019 luowei. All rights reserved.
//

#import "WLViewController.h"
#import <LWWebLoader/LWWebLoader.h>

@interface NSDictionary (LWWLSONString)
-(NSString*) lwwl_jsonStringWithPrettyPrint:(BOOL) prettyPrint;
@end
@implementation NSDictionary (LWWLSONString)

-(NSString*) lwwl_jsonStringWithPrettyPrint:(BOOL) prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0) error:&error];
    if (! jsonData) {
        NSLog(@"%s: error: %@", __func__, error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}
@end

@interface WLViewController ()

@end

@implementation WLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn1.frame = CGRectMake(100, 150, 160, 40);
    [btn1 setTitle:@"getRequest" forState:UIControlStateNormal];
    [self.view addSubview:btn1];
    [btn1 addTarget:self action:@selector(getBtnAction) forControlEvents:UIControlEventTouchUpInside];

    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn2.frame = CGRectMake(100, 200, 160, 40);
    [btn2 setTitle:@"postRequest" forState:UIControlStateNormal];
    [self.view addSubview:btn2];
    [btn2 addTarget:self action:@selector(postBtnAction) forControlEvents:UIControlEventTouchUpInside];

    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn3.frame = CGRectMake(100, 250, 160, 40);
    [btn3 setTitle:@"downloadRequest" forState:UIControlStateNormal];
    [self.view addSubview:btn3];
    [btn3 addTarget:self action:@selector(downloadBtnAction) forControlEvents:UIControlEventTouchUpInside];

}

- (void)getBtnAction {
    NSString *urlString = @"http://mytest.com/test.json";
//    NSString *urlString = @"http://wodedata.com/MyResource/MyInputMethod/App/OtherVC_v14.json";
    NSURL *url = [NSURL URLWithString:urlString];
    NSDictionary *requestHeader = @{
            @"method": @"GET",
            @"headers": @{
                    @"user-agent": @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.87 Safari/537.36",
                    @"content-type": @"application/json"
            },
            @"cache": @"no-cache",
            @"referrer": [NSString stringWithFormat:@"%@://%@",url.scheme,url.host]
    };
    NSString *requestHeaderJson = [requestHeader lwwl_jsonStringWithPrettyPrint:NO];

    NSString *jsCode = [NSString stringWithFormat:@"getData('%@','%@',%@)",NSUUID.UUID.UUIDString, urlString, requestHeaderJson];
    [LWWebLoader evaluateJavaScript:jsCode url:url completionHandler:^(id o, NSError *error) {
        if (error) {
            NSLog(@"======error:%@\n%@", error.localizedFailureReason, error.localizedDescription);
        }
        if ([o isKindOfClass:[NSString class]]) {
            NSLog(@"==========getData:%@", o);
        }
    }];
}

- (void)postBtnAction {
    NSString *urlString = @"http://mytest.com/test.json";
    NSURL *url = [NSURL URLWithString:urlString];
    NSDictionary *requestHeader = @{
            @"method": @"POST",
            @"body": @"{\"answer\": 42}",
            @"cache": @"no-cache",
            @"headers": @{
                    @"user-agent": @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.87 Safari/537.36",
                    @"content-type": @"application/json"
            },
            @"referrer": [NSString stringWithFormat:@"%@://%@",url.scheme,url.host]
    };
    NSString *requestHeaderJson = [requestHeader lwwl_jsonStringWithPrettyPrint:NO];

    NSString *jsCode = [NSString stringWithFormat:@"postData('%@','%@',%@)",NSUUID.UUID.UUIDString,urlString,requestHeaderJson];
    [LWWebLoader evaluateJavaScript:jsCode url:url completionHandler:^(id o, NSError *error) {
        if (error) {
            NSLog(@"======error:%@\n%@", error.localizedFailureReason, error.localizedDescription);
        }
        if ([o isKindOfClass:[NSString class]]) {
            NSLog(@"==========postData:%@", o);
        }
    }];
}

- (void)downloadBtnAction {
/*
    NSString *urlString = @"http://oss.wodedata.com/Fonts/%E5%8D%8E%E6%96%87%E9%9A%B6%E4%B9%A6.ttf";
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *requestId = NSUUID.UUID.UUIDString;
    NSDictionary *requestHeader = @{
            @"method": @"GET",
            @"headers": @{
                    @"user-agent": @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.87 Safari/537.36",
                    @"content-type": @"application/json",
                    @"requestId":requestId,
            },
            @"cache": @"no-cache",
            @"referrer": [NSString stringWithFormat:@"%@://%@",url.scheme,url.host]
    };
    NSString *requestHeaderJson = [requestHeader lwwl_jsonStringWithPrettyPrint:NO];

    NSString *jsCode = [NSString stringWithFormat:@"downloadRequest('%@','%@',%@)",requestId,urlString,requestHeaderJson];
    [LWWebLoader evaluateJavaScript:jsCode url:url completionHandler:^(id o, NSError *error) {
        if (error) {
            NSLog(@"======error:%@\n%@", error.localizedFailureReason, error.localizedDescription);
        }
        if ([o isKindOfClass:[NSString class]]) {
            NSLog(@"==========downloadRequest:%@", o);
        }
    }];
*/



    NSString *urlString = @"http://mytest.com/test.zip";
    NSURL *url = [NSURL URLWithString:urlString];
//    NSString *jsCode = [NSString stringWithFormat:@"downloadFile2()"];
//    NSString *jsCode = [NSString stringWithFormat:@"window.downloadFile()"];
    NSString *jsCode = [NSString stringWithFormat:@"SaveToDisk()"];

    [LWWebLoader evaluateJavaScript:jsCode url:url completionHandler:^(id o, NSError *error) {
        if (error) {
            NSLog(@"======error:%@\n%@", error.localizedFailureReason, error.localizedDescription);
        }
        if ([o isKindOfClass:[NSString class]]) {
            NSLog(@"==========downloadRequest:%@", o);
        }
    }];


}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [LWWebLoader evaluateJavaScript:@"log('aaaaaa')" completionHandler:^(id o, NSError *error) {
        if([o isKindOfClass:[NSString class]]){
            NSLog(@"==========log:%@",o);
        }
    }];


    NSString *urlString = @"http://mytest.com/test.json";
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *requestId = NSUUID.UUID.UUIDString;
    NSDictionary *requestHeader = @{
            @"method": @"GET",
            @"headers": @{
                    @"user-agent": @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.87 Safari/537.36",
                    @"content-type": @"application/json",
                    @"requestId":requestId,
            },
            @"cache": @"no-cache",
            @"referrer": [NSString stringWithFormat:@"%@://%@",url.scheme,url.host]
    };
    NSString *requestHeaderJson = [requestHeader lwwl_jsonStringWithPrettyPrint:NO];

    NSString *jsCode = [NSString stringWithFormat:@"getRequest('%@','%@')",requestId,urlString,requestHeaderJson];
    [LWWebLoader evaluateJavaScript:jsCode completionHandler:^(id o, NSError *error) {
        if (error) {
            NSLog(@"======error:%@\n%@", error.localizedFailureReason, error.localizedDescription);
        }
        if ([o isKindOfClass:[NSString class]]) {
            NSLog(@"==========getRequest:%@", o);
        }
    }];


}


@end

