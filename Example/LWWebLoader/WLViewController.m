//
//  WLViewController.m
//  LWWebLoader
//
//  Created by luowei on 11/04/2019.
//  Copyright (c) 2019 luowei. All rights reserved.
//

#import "WLViewController.h"
#import "LWWebLoader.h"
#import <LWWebLoader/LWWebLoader.h>

@interface WLViewController ()

@property(nonatomic, strong) LWWebLoader *webloader;
@end

@implementation WLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn1.frame = CGRectMake(100, 150, 160, 40);
    [btn1 setTitle:@"getData" forState:UIControlStateNormal];
    [self.view addSubview:btn1];
    [btn1 addTarget:self action:@selector(getBtnAction) forControlEvents:UIControlEventTouchUpInside];

    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn2.frame = CGRectMake(100, 200, 160, 40);
    [btn2 setTitle:@"postData" forState:UIControlStateNormal];
    [self.view addSubview:btn2];
    [btn2 addTarget:self action:@selector(postBtnAction) forControlEvents:UIControlEventTouchUpInside];

    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn3.frame = CGRectMake(100, 250, 160, 40);
    [btn3 setTitle:@"uploadData" forState:UIControlStateNormal];
    [self.view addSubview:btn3];
    [btn3 addTarget:self action:@selector(postBtnAction) forControlEvents:UIControlEventTouchUpInside];

    UIButton *btn4 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn4.frame = CGRectMake(100, 300, 160, 40);
    [btn4 setTitle:@"downloadFile" forState:UIControlStateNormal];
    [self.view addSubview:btn4];
    [btn4 addTarget:self action:@selector(downloadFileBtnAction) forControlEvents:UIControlEventTouchUpInside];

    UIButton *btn5 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn5.frame = CGRectMake(100, 350, 160, 40);
    [btn5 setTitle:@"downloadStream" forState:UIControlStateNormal];
    [self.view addSubview:btn5];
    [btn5 addTarget:self action:@selector(downloadStreamBtnAction) forControlEvents:UIControlEventTouchUpInside];

}

-(LWWebLoader *)webloader {
    if(!_webloader){
        _webloader = LWWebLoader.webloader;
    }
    return _webloader;
}

- (void)writeToFileWithData:(NSData *)data {
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"influence.pdf"];
    NSError *err;
    [(NSData *)data writeToFile:filePath options:NSDataWritingAtomic error:&err];
    if(err){
        NSLog(@"==========下载完成，但保存文件失败");
    }else{
        NSLog(@"==========下载完成，文件保存在:%@", filePath);
    }
}


- (void)getBtnAction {
//    NSString *urlString = @"http://mytest.com/test.json";
//    NSString *urlString = @"http://mytest.com/mitm.html";
//    NSString *urlString = @"http://mytest.com/DeepRPC.zip";
    NSString *urlString = @"http://mytest.com/influence.pdf";
//    NSString *urlString = @"http://wodedata.com/MyResource/MyInputMethod/App/OtherVC_v14.json";

    WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString method:GetData userAgent:nil contentType:nil postData:nil uploadData:nil];
    [self.webloader evaluateWithBody:evaluateBody parentView:self.view dataLoadCompletionHandler:^(BOOL finish,id result,NSError *error){
        if (error) {
            NSLog(@"======error:%@\n%@", error.localizedFailureReason, error.localizedDescription);
            return;
        }
        if ([result isKindOfClass:[NSString class]]) {
            NSLog(@"==========getData return text:%@", result);
        }else if([result isKindOfClass:[NSDictionary class]]){
            NSLog(@"==========getData return dict:%@", result);
        }else if([result isKindOfClass:[NSData class]]){
            [self writeToFileWithData:result];
        }
    }];
}

- (void)postBtnAction {
//    NSString *urlString = @"http://mytest.com/test.json";
    NSString *urlString = @"http://mytest.com/influence.pdf";

    NSDictionary *contentType = @{ @"Content-Type": @"application/json", };
    WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString method:PostData userAgent:nil contentType:contentType postData:@{@"name":@"张三"} uploadData:nil];
    [self.webloader evaluateWithBody:evaluateBody parentView:self.view dataLoadCompletionHandler:^(BOOL b, id result, NSError *error) {
        if (error) {
            NSLog(@"======error:%@\n%@", error.localizedFailureReason, error.localizedDescription);
            return;
        }
        if ([result isKindOfClass:[NSString class]]) {
            NSLog(@"==========postData return text:%@", result);
        }else if([result isKindOfClass:[NSDictionary class]]){
            NSLog(@"==========postData return dict:%@", result);
        }else if([result isKindOfClass:[NSData class]]){
            [self writeToFileWithData:result];
        }
    }];
}

-(void)downloadFileBtnAction {

    NSString *urlString = @"http://mytest.com/test.zip";
    WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString method:DownloadFile userAgent:nil contentType:nil postData:nil uploadData:nil];
    [self.webloader evaluateWithBody:evaluateBody parentView:self.view dataLoadCompletionHandler:^(BOOL finish,id data, NSError *error) {
        //todo: 处理文件，data为NSData
    }];

}

- (void)downloadStreamBtnAction {

    NSString *urlString = @"http://oss.wodedata.com/Fonts/%E5%8D%8E%E6%96%87%E9%9A%B6%E4%B9%A6.ttf";
//    NSString *urlString = @"http://mytest.com/test.zip";
    WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString method:DownloadStream userAgent:nil contentType:nil postData:nil uploadData:nil];
    [self.webloader evaluateWithBody:evaluateBody parentView:self.view dataLoadCompletionHandler:^(BOOL finish,id data, NSError *error) {
        //todo: 处理文件，data为文件路径
    }];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

/*
    WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:nil method:NativeLog userAgent:nil contentType:nil postData:nil uploadData:nil];
    [LWWebLoader.webloader evaluateWithBody:evaluateBody parentView:self.view jsExcuteCompletionHandler:^(id o, NSError *error) {
        if ([o isKindOfClass:[NSString class]]) {
            NSLog(@"==========log:%@", o);
        }
    }];
*/

}


@end

