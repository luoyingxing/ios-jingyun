//
//  ResetPasswordViewController.m
//  ios-jingyun
//
//  Created by conwin on 2018/1/15.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "CWColorUtils.h"
#import "MBProgressHUD.h"
#import "ThingsResponseDelegate.h"
#import "CWThings4Interface.h"

#define Set_Password @"Set_Password"

@interface ResetPasswordViewController ()<ThingsResponseDelegate>

@end

@implementation ResetPasswordViewController{
    MBProgressHUD *mbProgress;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNaigaBar];
    [[CWThings4Interface sharedInstance] setResponseDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//点击空白处收起键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void) setNaigaBar{
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.navigationController.navigationBar setBarTintColor:[CWColorUtils getThemeColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],
                                                                      NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationItem.title = @"重置密码";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithImage:[UIImage imageNamed:@"icon_back_white.png"]
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(back:)];
    backButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backButton;
    
}

- (void) back:(id)sender{
    //jump to add personal controller
    [self dismissViewControllerAnimated:TRUE completion:^{
        NSLog(@"back to personal ");
    }];
}

- (IBAction)commitOnClick:(UIButton *)sender {
    NSString* oldPassword = self.oldTextField.text;
    NSString* newPassword = self.newsTextField.text;
    NSString* newAgainPassword = self.newsAgainTextField.text;
    
    if (oldPassword == nil || oldPassword.length == 0 || newPassword == nil || newPassword.length == 0 || newAgainPassword == nil || newAgainPassword.length == 0) {
        [self showToast:@"密码不能为空!"];
        return;
    }
    
    if (![newPassword isEqualToString:newAgainPassword]) {
        [self showToast:@"两次密码输入不一致!"];
        return;
    }
    
    if (newPassword.length < 1 ) {
        [self showToast:@"密码长度不应该小于1位!"];
        return;
    }
    
    NSLog(@"%@ %@ %@", oldPassword , newPassword , newAgainPassword);
    
    NSString* requset_data = [NSString stringWithFormat:@"/user/set-password?old=%@&new=%@", oldPassword, newPassword];
     [[CWThings4Interface sharedInstance] request:"." URL:[requset_data UTF8String] UrlLen:(int)[requset_data length]  ReqID:[Set_Password UTF8String]];
}

- (void) showToast:(NSString*) message{
    mbProgress = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:mbProgress];
    mbProgress.color = [CWColorUtils colorWithHexString:@"#00c7c7" alpha:0.8f];
    mbProgress.labelText = message;
    mbProgress.mode = MBProgressHUDModeText;
    
    //指定距离中心点的X轴和Y轴的偏移量，如果不指定则在屏幕中间显示
    mbProgress.yOffset = [UIScreen mainScreen].bounds.size.height / 4 ;
    //mbProgress.xOffset = 100.0f;
    
    [mbProgress showAnimated:YES whileExecutingBlock:^{
        sleep(2);
    } completionBlock:^{
        [mbProgress removeFromSuperview];
        mbProgress = nil;
    }];
}

-(void) onThingsResponse:(const char*)inReqID status:(int)inStatus header:(char*) inHeader body:(char*)inBody{
    NSLog(@"onThingsResponse ---->  %s", inBody);
    if (strcmp(inReqID, [Set_Password UTF8String]) == 0 && inStatus == 200) {
        [self showToast:@"密码修改成功！"];
        self.oldTextField.text = @"";
        self.newsTextField.text = @"";
        self.newsAgainTextField.text = @"";
    } else {
        [self showToast:@"密码修改失败！"];
    }
    
}

@end
