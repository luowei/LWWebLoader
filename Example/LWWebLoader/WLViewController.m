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
#import <SafariServices/SafariServices.h>

@interface WLViewController () <SFSafariViewControllerDelegate>

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
    [btn3 addTarget:self action:@selector(uploadBtnAction) forControlEvents:UIControlEventTouchUpInside];

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

    UIButton *btn6 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn6.frame = CGRectMake(100, 400, 160, 40);
    [btn6 setTitle:@"getClipboardText" forState:UIControlStateNormal];
    [self.view addSubview:btn6];
    [btn6 addTarget:self action:@selector(getClipboardTextBtnAction) forControlEvents:UIControlEventTouchUpInside];

    UIButton *btn7 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn7.frame = CGRectMake(100, 450, 160, 40);
    [btn7 setTitle:@"SFSafariViewController" forState:UIControlStateNormal];
    [self.view addSubview:btn7];
    [btn7 addTarget:self action:@selector(safariVCBtnAction) forControlEvents:UIControlEventTouchUpInside];

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

    WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString method:GetData methodArguments:nil userAgent:nil contentType:nil postData:nil uploadData:nil];
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

    NSString *contentType = @"application/json";
    WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString method:PostData methodArguments:nil userAgent:nil contentType:contentType postData:@{@"name":@"张三"} uploadData:nil];
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

- (void)uploadBtnAction {
//    NSString *urlString = @"http://mytest.com/test.json";
    NSString *urlString = @"http://mytest.com:8000";

    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"influence.pdf"];

    NSString *contentType = nil;
    NSData *uploadData = [NSData dataWithContentsOfFile:filePath];
    WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString method:UploadData methodArguments:nil userAgent:nil contentType:contentType postData:@{@"name":@"张三"} uploadData:uploadData];
    [self.webloader evaluateWithBody:evaluateBody parentView:self.view dataLoadCompletionHandler:^(BOOL b, id result, NSError *error) {
        if (error) {
            NSLog(@"======error:%@\n%@", error.localizedFailureReason, error.localizedDescription);
            return;
        }
        if ([result isKindOfClass:[NSString class]]) {
            NSLog(@"==========uploadData return text:%@", result);
        }else if([result isKindOfClass:[NSDictionary class]]){
            NSLog(@"==========uploadData return dict:%@", result);
        }else if([result isKindOfClass:[NSData class]]){
            [self writeToFileWithData:result];
        }
    }];
}

-(void)downloadFileBtnAction {

    NSString *urlString = @"http://mytest.com/test.zip";
    WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString method:DownloadFile methodArguments:nil userAgent:nil contentType:nil postData:nil uploadData:nil];
    [self.webloader evaluateWithBody:evaluateBody parentView:self.view dataLoadCompletionHandler:^(BOOL finish,id result, NSError *error) {
        //处理文件，result为NSData
        if (error) {
            NSLog(@"======error:%@\n%@", error.localizedFailureReason, error.localizedDescription);
            return;
        }
        if ([result isKindOfClass:[NSString class]]) {
            NSLog(@"==========uploadData return text:%@", result);
        }else if([result isKindOfClass:[NSDictionary class]]){
            NSLog(@"==========uploadData return dict:%@", result);
        }else if([result isKindOfClass:[NSData class]]){
            [self writeToFileWithData:result];
        }
    }];

}

- (void)downloadStreamBtnAction {

    NSString *urlString = @"http://oss.wodedata.com/Fonts/%E5%8D%8E%E6%96%87%E9%9A%B6%E4%B9%A6.ttf";
//    NSString *urlString = @"http://mytest.com/test.zip";
    WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString method:DownloadStream methodArguments:nil userAgent:nil contentType:nil postData:nil uploadData:nil];
    [self.webloader evaluateWithBody:evaluateBody parentView:self.view dataLoadCompletionHandler:^(BOOL finish,id result, NSError *error) {
        //处理文件，data为文件路径
        if (error) {
            NSLog(@"======error:%@\n%@", error.localizedFailureReason, error.localizedDescription);
            return;
        }
        if ([result isKindOfClass:[NSString class]]) {
            NSLog(@"==========文件的文件保存的路径为:%@", result);
        }
    }];

}

-(void)getClipboardTextBtnAction {
    WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:nil method:GetClipboardText methodArguments:nil userAgent:nil contentType:nil postData:nil uploadData:nil];
    [self.webloader evaluateWithBody:evaluateBody parentView:self.view dataLoadCompletionHandler:^(BOOL finish,id result, NSError *error) {
        //处理文件，data为文件路径
        if (error) {
            NSLog(@"======error:%@\n%@", error.localizedFailureReason, error.localizedDescription);
            return;
        }
        if ([result isKindOfClass:[NSString class]]) {
            NSLog(@"==========从粘贴板获得:%@", result);
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:nil method:NativeLog methodArguments:@"aaaaaaaaa" userAgent:nil contentType:nil postData:nil uploadData:nil];
    [LWWebLoader.webloader evaluateWithBody:evaluateBody parentView:self.view dataLoadCompletionHandler:^(BOOL finish,id result, NSError *error) {
        if ([result isKindOfClass:[NSString class]]) {
            NSLog(@"==========log:%@", result);
        }
    }];

}

-(void)safariVCBtnAction{
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"http://wodedata.com.com"] entersReaderIfAvailable:YES];
    safariVC.delegate = self;
    [self presentViewController:safariVC animated:YES completion:nil];
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

