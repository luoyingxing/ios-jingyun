//
//  WebViewController.m
//  ios-jingyun
//
//  Created by conwin on 2017/12/25.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>
#import "CWColorUtils.h"
#import "MBProgressHUD.h"

@interface WebViewController () <WKNavigationDelegate>

@property(nonatomic, strong) WKWebView* webView;

@end

@interface WebViewController ()

@end

@implementation WebViewController{
    MBProgressHUD *mbProgress;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNaigaBar];
    
    /// 添加WKWebView
    self.webView = [[WKWebView alloc] initWithFrame: self.view.frame];
    [self.view addSubview: self.webView];
    self.webView.navigationDelegate = self;
    
    NSURL * url = [NSURL URLWithString: self.url];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    if (_contentTitle != nil && _contentTitle.length > 0) {
        self.title = _contentTitle;
    }else{
        self.title = @"详情";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated{
    [self showProgress];
}

- (void) setNaigaBar{
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    [self setNeedsStatusBarAppearanceUpdate];
    [self.navigationController.navigationBar setBarTintColor:[CWColorUtils getThemeColor]];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithImage:[UIImage imageNamed:@"icon_back_white"]
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(goBack:)];
    backButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backButton;
}

#pragma mark  --实现WKNavigationDelegate委托协议
//开始加载时调用
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"开始加载");
}
//当内容开始返回时调用
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"内容开始返回");
    [mbProgress hide:YES];
}

//加载完成之后调用
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"加载完成");
}

//加载失败时调用
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"加载失败 error :  %@", error.localizedDescription);
    [mbProgress hide:YES];
}

/*
 * MBProgressHUD *mbProgress;
 * [mbProgress hide:YES];
 */
- (void) showProgress {
    mbProgress = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    mbProgress.color = [CWColorUtils getThemeColor];
    mbProgress.labelText = @"加载中...";
}

- (void) goBack:(UIBarButtonItem*) button{
    [self dismissViewControllerAnimated:TRUE completion:^{
        NSLog(@"back to HOME");
    }];
}

@end
