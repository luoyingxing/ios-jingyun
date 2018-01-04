//
//  AddAccountViewController.m
//  ios-jingyun-test
//
//  Created by conwin on 2017/12/12.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import "AddAccountViewController.h"
#import "CWColorUtils.h"
#import "UserInfoModel.h"
#import "UserInfoDAO.h"

@interface AddAccountViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *serverNameField;
@property (weak, nonatomic) IBOutlet UITextField *serverAddressField;
@property (weak, nonatomic) IBOutlet UITextField *portField;
@property (weak, nonatomic) IBOutlet UISwitch *bindSIMSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *domainLoginSwitch;
- (IBAction)domainLoginClick:(id)sender;
- (IBAction)loginClick:(id)sender;

@end

@implementation AddAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNaigaBar];
    

    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 0)];
    icon.image = [UIImage imageNamed:@"icon_account_user_name"];
    icon.contentMode =UIViewContentModeCenter;
    self.userNameField.leftView =icon;
    self.userNameField.leftViewMode = UITextFieldViewModeAlways;
 
    UIImageView *icon1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 0)];
    icon1.image = [UIImage imageNamed:@"icon_account_user_name"];
    icon1.contentMode =UIViewContentModeCenter;
    self.passwordField.leftView =icon1;
    self.passwordField.leftViewMode = UITextFieldViewModeAlways;
    [self.passwordField setSecureTextEntry:YES];
    
    UIImageView *icon2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 0)];
    icon2.image = [UIImage imageNamed:@"icon_account_user_name"];
    icon2.contentMode =UIViewContentModeCenter;
    self.serverNameField.leftView =icon2;
    self.serverNameField.leftViewMode = UITextFieldViewModeAlways;
    
    UIImageView *icon3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 0)];
    icon3.image = [UIImage imageNamed:@"icon_account_user_name"];
    icon3.contentMode =UIViewContentModeCenter;
    self.serverAddressField.leftView =icon3;
    self.serverAddressField.leftViewMode = UITextFieldViewModeAlways;
    
    UIImageView *icon4 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 0)];
    icon4.image = [UIImage imageNamed:@"icon_account_user_name"];
    icon4.contentMode =UIViewContentModeCenter;
    self.portField.leftView =icon4;
    self.portField.leftViewMode = UITextFieldViewModeAlways;
    
    [self settingFiled];
    
}

- (void)viewWillAppear:(BOOL)animated{
    // Called when the view is about to made visible. Default does nothing
    [super viewWillAppear:animated];
    
    //去除导航栏下方的横线
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
}

- (void) setNaigaBar{
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.navigationController.navigationBar setBarTintColor:[CWColorUtils getThemeColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],
                                                                      NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationItem.title = @"添加账号";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithImage:[UIImage imageNamed:@"icon_back_white"]
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(back:)];
    backButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backButton;

}

- (void) settingFiled{
    if (self.userInfoModel != nil) {
        NSLog(@" userName %@", self.userInfoModel.userName);
        
         self.navigationItem.title = @"编辑账号";
    
        self.userNameField.text = self.userInfoModel.userName;
        self.passwordField.text = self.userInfoModel.password;
        self.serverNameField.text = self.userInfoModel.serverName;
        self.serverAddressField.text = self.userInfoModel.serverAddress;
    
        if (self.userInfoModel.isBindSIM) {
            self.bindSIMSwitch.on = YES;
        }
    
        if (self.userInfoModel.isDomainLogin) {
            self.portField.hidden = YES;
            self.domainLoginSwitch.on = YES;
        }else{
            self.portField.text = self.userInfoModel.port;
        }
    }
}

- (void) back:(id)sender{
    //jump to add account controller
 
    [self dismissViewControllerAnimated:TRUE completion:^{
        NSLog(@"back to account ");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)domainLoginClick:(id)sender {
    UISwitch *domainLogin = (UISwitch *) sender;
    BOOL setting = domainLogin.isOn;
    [self.portField setHidden:setting];
    if (setting) {
        self.serverAddressField.placeholder = @"服务器域名";
    }else{
        self.serverAddressField.placeholder = @"服务器地址";
    }
}

- (IBAction)loginClick:(id)sender {
    NSString* userName = self.userNameField.text;
    NSString* password = self.passwordField.text;
    NSString* serverName = self.serverNameField.text;
    NSString* serverAddress = self.serverAddressField.text;
    NSString* port = self.portField.text;
    BOOL isDomainLogin = self.domainLoginSwitch.isOn;
    
    if ((userName.length ==0  ||password.length ==0 ||serverAddress.length ==0) || (!isDomainLogin && port.length ==0) ) {
        //请将信息填写完整
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请将信息填写完整！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
        return;
    }
    
    UserInfoModel* userInfo = [UserInfoModel new];
    userInfo.userName = userName;
    userInfo.password = password;
    userInfo.serverName = serverName;
    userInfo.serverAddress = serverAddress;
    userInfo.port = port;
    userInfo.isBindSIM = self.bindSIMSwitch.isOn;
    userInfo.isDomainLogin = self.domainLoginSwitch.isOn;
    
    [userInfo print];

    //获得DAO对象
    UserInfoDAO *dao = [UserInfoDAO sharedInstance];

    //插入数据
    [dao create:userInfo];
    
    //如果是编辑账户信息，则删除
    if (self.userInfoModel != nil) {
        [dao remove:self.userInfoModel];
    }
    
    [self goBack];
}

- (void) goBack{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"添加成功！" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self dismissViewControllerAnimated:TRUE completion:^{
        NSLog(@"add succeed! back to account ");
    }];
}


@end
