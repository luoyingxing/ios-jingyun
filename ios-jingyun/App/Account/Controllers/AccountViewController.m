//
//  AccountViewController.m
//  ios-jingyun-test
//
//  Created by conwin on 2017/12/11.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import "AccountViewController.h"
#import "CWColorUtils.h"
#import "UserInfoModel.h"
#import "AccountViewCell.h"
#import "AddAccountViewController.h"
#import "UserInfoDAO.h"
#import "CWThings4Interface.h"
#include "CWDataManager.h"
#import "MainTabBarController.h"
//#import "curl.h"
#import "MBProgressHUD.h"

#define CellIdentifier @"CellIdentifier"

@interface AccountViewController ()<NSURLSessionDataDelegate>{
//    CURL *_curl;
    NSInteger _get_server_info_index;
}

@property (nonatomic, strong) NSArray *userInfoArray;

@end

@implementation AccountViewController{
    MBProgressHUD *mbProgress;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNavigationBar];
    [self setTableView];
    [[CWDataManager sharedInstance] initData];
    connect_count_ = 0;
    _get_server_info_index = 1;
    
}

- (void) viewWillAppear:(BOOL)animated{
    [self intUserInfoData];
    [self.tableView reloadData];
}

//setting bar property
- (void) setNavigationBar{
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.navigationController.navigationBar setBarTintColor:[CWColorUtils getThemeColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],
                                                                     NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationItem.title = @"登陆";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithTitle:@"添加账户"
                                                                style:UIBarButtonItemStyleDone
                                                                target:self
                                                                action:@selector(addAccount:)];
    addItem.tintColor = [CWColorUtils colorWithHexString:@"#ffffffff"];
    self.navigationItem.rightBarButtonItem = addItem;
}

- (void) addAccount:(id)sender{
    //jump to add account controller
    AddAccountViewController* addController = [[AddAccountViewController alloc] init];
    UINavigationController* navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:addController];
    [self presentViewController:navigationController animated:TRUE completion:nil];
}

- (void) intUserInfoData{
    UserInfoDAO *dao = [UserInfoDAO sharedInstance];
    NSMutableArray * array = [dao findAll];
    self.userInfoArray = array;
    NSLog(@"array.count --->  %lu",array.count);
}

- (void) setTableView{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    //不显示分割线
    self.tableView.separatorStyle = UITableViewCellEditingStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //设置可重用单元格标识与单元格类型
//    [self.tableView registerClass:[AccountCell class]  forCellReuseIdentifier:CellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([AccountViewCell class]) bundle:nil] forCellReuseIdentifier:CellIdentifier];
}

#pragma mark --UITableViewDataSource 协议方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.userInfoArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AccountViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[AccountViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSUInteger index = [indexPath row];
    
    UserInfoModel *info = [self.userInfoArray objectAtIndex:index];
    
    NSString *title = [NSString stringWithFormat:@"%@", info.userName];
    NSString *serverInfo;
    NSString *tip;

    if (info.isDomainLogin) {
        tip = [NSString stringWithFormat:@"%@", @"域名登陆用户"];
        if (info.serverName != nil && ![info.serverName isEqualToString:@""] ) {
            serverInfo = [NSString stringWithFormat:@"服务器名称：%@  域名：%@", info.serverName, info.serverAddress];
        }else{
            serverInfo = [NSString stringWithFormat:@"域名：%@", info.serverAddress];
        }
    }else{
        serverInfo = [NSString stringWithFormat:@"服务器地址：%@  端口：%@", info.serverAddress, info.port];
    }
    
    if (info.isBindSIM) {
        if (tip == nil) {
            tip = [NSString stringWithFormat:@"%@", @"绑定了SIM卡"];
        }else{
            tip = [tip stringByAppendingString:@"  绑定了SIM卡"];
        }
    }
    
    
//    [cell.userNameLabel setLineBreakMode:NSLineBreakByWordWrapping];
//    cell.userNameLabel.numberOfLines = 0;//上面两行设置多行显示
    cell.userNameLabel.text = title;
    cell.serverInfoLabel.text = serverInfo;
    if (tip != nil) {
        cell.tipLabel.text = tip;
    }else{
        cell.tipLabel.text = @"";
    }
    
    [cell.loginButton setTag:index];
    [cell.loginButton addTarget:self action:@selector(loginClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.editButton setTag:index];
    [cell.editButton addTarget:self action:@selector(editClick:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 145;
}

// like item click listener
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"click item is %li", indexPath.row);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"确定删除该账户信息吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    alert.tag = indexPath.row;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"item click  %lu  tag: %lu", buttonIndex, alertView.tag);

    if (buttonIndex == 1) {
        //delete userinfo
        NSUInteger index = alertView.tag;
        UserInfoModel *info = [self.userInfoArray objectAtIndex:index];
        
        //获得DAO对象
        UserInfoDAO *dao = [UserInfoDAO sharedInstance];
        [dao remove:info];
        
        NSMutableArray * array = [dao findAll];
        self.userInfoArray = array;
        [self.tableView reloadData];
    }
}


- (void) loginClick:(UIButton *) button{
    [self showProgress];
    
    NSUInteger index = button.tag;
    UserInfoModel *info = [self.userInfoArray objectAtIndex:index];
    NSLog(@"login %@", info.userName);
    
    BOOL domianLogin = info.isDomainLogin;
    
    float palFrame = 0.5;
    if (domianLogin) {
        loop_timer = [NSTimer scheduledTimerWithTimeInterval:palFrame target:self selector:@selector(message_loop) userInfo:nil repeats:YES];
        [self callCurl];
    } else {
        loop_timer = [NSTimer scheduledTimerWithTimeInterval:palFrame target:self selector:@selector(message_loop) userInfo:nil repeats:YES];
        userInfo = info;
        [self userLogin];
    }
}

- (void) callCurl{
//    _curl = curl_easy_init();
//    NSString *server_url = [[NSString alloc] initWithFormat:@"https://api.jingyun.cn/opid2host?opid=%@", userInfo.serverAddress];
//    curl_easy_setopt(_curl, CURLOPT_URL, [server_url UTF8String]);
//    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"IOS" ofType:@"pfx"];
//    curl_easy_setopt(_curl, CURLOPT_SSL_VERIFYPEER, 0L);
//    curl_easy_setopt(_curl, CURLOPT_SSLCERT, [certPath UTF8String]);
//    curl_easy_setopt(_curl, CURLOPT_SSLCERTPASSWD, "123456");
//    curl_easy_setopt(_curl, CURLOPT_WRITEFUNCTION, responseCallback);
//    curl_easy_setopt(_curl, CURLOPT_WRITEDATA, self);
//    CURLcode errorCode = curl_easy_perform(_curl);
//    if (errorCode == CURLE_OK) {
//
//        //CURLcode http_code = curl_easy_getinfo(_curl, CURLINFO_RESPONSE_CODE);
//        if (_get_server_info_index == 2) {
//
//        }else {
//            UIAlertView * alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UserLoginIndicator_AlertTitle",@"") message:NSLocalizedString(@"UserLoginIndicator_AlertSSHErr",@"") delegate:self cancelButtonTitle:NSLocalizedString(@"UserLoginIndicator_AlertOK",@"") otherButtonTitles:nil, nil];
//            [alertview show];
//
//            if (loop_timer)
//                [loop_timer invalidate];
//
////            if (_photoLoadingView) {
////                [_photoLoadingView stopAnimating];
////            }
//        }
//    }
//    else {
//        _get_server_info_index = 3;
//    }
}

 size_t responseCallback(char *ptr, size_t size, size_t nmemb, void *userdata){
    NSLog(@"----> responseCallback");
    AccountViewController *controller = (__bridge AccountViewController *)userdata;
    const size_t sizeInBytes = size*nmemb;
    if (sizeInBytes > 0 && ptr) {
        NSData *data = [[NSData alloc] initWithBytes:ptr length:sizeInBytes];
        NSDictionary *tempDictQueryDiamond = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString *server_host = [tempDictQueryDiamond objectForKey:@"host"];
        controller->userInfo.port = [tempDictQueryDiamond objectForKey:@"port"];
        controller->userInfo.serverAddress = server_host;
        controller->_get_server_info_index = 2;
    }
    return sizeInBytes;
}

//跳转编辑
- (void) editClick:(UIButton *) button{
    NSUInteger index = button.tag;
    UserInfoModel *info = [self.userInfoArray objectAtIndex:index];
    NSLog(@"edit %@", info.userName);
    
    AddAccountViewController* addController = [[AddAccountViewController alloc] init];
    addController.userInfoModel = info;
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:addController];
    [self presentViewController:navigationController animated:TRUE completion:nil];
}

//登陆
- (void) userLogin{
    [[CWThings4Interface sharedInstance] set_login_delegate:self];
    [[CWThings4Interface sharedInstance] user_login:userInfo.userName pass:userInfo.password];
    
    if (userInfo.serverAddress == nil) {
        UIAlertView * alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UserLoginIndicator_AlertTitle", @"") message:NSLocalizedString(@"UserLoginIndicator_AlertServerErr", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"UserLoginIndicator_AlertOK", @"") otherButtonTitles:nil, nil];
        [alertview show];
        [self performSegueWithIdentifier:@"show_server_controller" sender:self];
        return;
    }
    
    NSString *server_url = [[NSString alloc] initWithFormat:@"host=%@;port=%@", userInfo.serverAddress, userInfo.port];
    [[CWThings4Interface sharedInstance] connect_to:[server_url UTF8String]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//开启消息循环获取things结点信息
- (void)message_loop{
    
    if (userInfo.isDomainLogin && _get_server_info_index != 2) {
        if (_get_server_info_index == 3) {
            _get_server_info_index = 1;
            [self callCurl];
        }
        return ;
    }
    
    int socket_state = [[CWThings4Interface sharedInstance] get_state];
    NSLog(@"-------- socket_state: %d", socket_state);
    switch (socket_state) {
        case -8:{
            if (loop_timer){
                [loop_timer invalidate];
            }
        
//            if (_photoLoadingView) {
//                [_photoLoadingView stopAnimating];
//            }
            
            UIAlertView * alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UserLoginIndicator_AlertTitle",@"") message:NSLocalizedString(@"UserLoginIndicator_AlertLoginErr",@"") delegate:self cancelButtonTitle:NSLocalizedString(@"UserLoginIndicator_AlertOK",@"") otherButtonTitles:nil, nil];
            [alertview show];
            [mbProgress hide:YES];
            break;
        }
        case 1:
        case 2:
        case 3:
        case 4:{
            connect_count_++;
            if (connect_count_ > 20) {
                connect_count_ = 0;
                
                if (loop_timer)
                    [loop_timer invalidate];
                
//                if (_photoLoadingView) {
//                    [_photoLoadingView stopAnimating];
//                }
                
                [[CWThings4Interface sharedInstance] disconnect];
                self.title = NSLocalizedString(@"UserLoginIndicator_NavConnectErrTitle", @"");
                
                UIAlertView * alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UserLoginIndicator_AlertTitle",@"") message:NSLocalizedString(@"UserLoginIndicator_AlertConnectErr",@"") delegate:self cancelButtonTitle:NSLocalizedString(@"UserLoginIndicator_AlertOK",@"") otherButtonTitles:nil, nil];
                [alertview show];
                [mbProgress hide:YES];
                [CWDataManager sharedInstance]->user_login_ok = NO;
            }
        }
            break;
        case 5:{
            self.title = NSLocalizedString(@"UserLoginIndicator_NavConnectTitle", @"");
        }
            break;
        case 6:{
            if ([[CWDataManager sharedInstance] isInitDataFinished]) {
                if (loop_timer){
                    [loop_timer invalidate];
                }
                
//                if (_photoLoadingView) {
//                    [_photoLoadingView stopAnimating];
//                }
                login_ok = YES;
                
                self.title = NSLocalizedString(@"UserLoginIndicator_NavLoginTitle", @"");
                [CWDataManager sharedInstance]->user_login_ok = YES;
                [[CWDataManager sharedInstance] setCurrentUserPassword:userInfo.password];
                
//                NSString *caption  = [[CWDataManager sharedInstance] selectedMenuCaption];
                
                BOOL isCloseLot = [[NSUserDefaults standardUserDefaults] boolForKey:@"isCloseLocation"];
                [[CWDataManager sharedInstance] setIsCloseLocation:isCloseLot];
                
                //jump to home page
                NSLog(@" -----> jump to home page");
                [self jumpToMainController];
           
            }
            //add user info to local sto
            
            break;
        }
        case 7:{
        }
            break;
        default:
            break;
    }
}

//跳转到首页
- (void) jumpToMainController{
    [mbProgress hide:YES];
    
    MainTabBarController* mainVC = [[MainTabBarController alloc] init];
    [self  presentViewController:mainVC  animated:YES completion:nil];
    
}

/*
 * MBProgressHUD *mbProgress;
 * [mbProgress hide:YES];
 */
- (void) showProgress {
    mbProgress = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    mbProgress.color = [CWColorUtils getThemeColor];
    mbProgress.labelText = @"登陆中...";
}

@end
