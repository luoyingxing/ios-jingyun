//
//  PersonalViewController.m
//  ios-jingyun-test
//
//  Created by conwin on 2017/12/20.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PersonalViewController.h"
#import "CWColorUtils.h"
#import "CWDataManager.h"
#import "CWThings4Interface.h"
#import "SettingTextViewCell.h"
#import "AccountViewController.h"
#import "SettingCheckedViewCell.h"
#import "SettingItem.h"
#import "CWFileUtils.h"
#import "VideoTypeViewController.h"

#define CellIdentifierForSettingText @"CellIdentifierForSettingText"
#define CellIdentifierForSettingChecked @"CellIdentifierForSettingChecked"

@interface PersonalViewController ()

//保存数据列表
@property (nonatomic,strong) NSMutableArray* settingListData;

@end

@implementation PersonalViewController{
    //表头
    UIView *headerView;
    
    UILabel* accountLabel;
    UILabel* userLabel;
    UILabel* logoutLabel;
    
    CGFloat screenHeight;
    CGFloat screenWidth;
    CGFloat childViewsY;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    screenHeight = self.view.bounds.size.height;
    screenWidth = self.view.bounds.size.width;
    
    [self initTableView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initTableView{
    //UITableViewStyleGrouped
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //分割线颜色
    self.tableView.separatorColor = [CWColorUtils colorWithHexString:@"#dbdbdb"];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    //纯文字选择项
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SettingTextViewCell class]) bundle:nil] forCellReuseIdentifier:CellIdentifierForSettingText];
    //选择框样式
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SettingCheckedViewCell class]) bundle:nil] forCellReuseIdentifier:CellIdentifierForSettingChecked];
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, [self getHeaderHeight])];
    headerView.backgroundColor = [UIColor whiteColor];
    [self addTopView];
    self.tableView.tableHeaderView = headerView;
}

- (void) addTopView{
    CGFloat topHeight = screenHeight / 4;
    CGFloat imageY =  topHeight / 2;
    
    UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, topHeight)];
    bgView.backgroundColor = [CWColorUtils getThemeColor];
    [headerView addSubview:bgView];
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_loading_logo"]];
    imageView.frame = CGRectMake(30, imageY - 25, 50, 50);
    imageView.contentMode =  UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds  = YES;
    [headerView addSubview:imageView];
    
    accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, imageY - 15, screenWidth - 100, 30)];
    accountLabel.textColor = [UIColor whiteColor];
    accountLabel.numberOfLines = 1;
    accountLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
    [headerView addSubview:accountLabel];
    
    userLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, topHeight - 40, screenWidth - 40, 30)];
    userLabel.textColor = [UIColor whiteColor];
//    userLabel.textAlignment = NSTextAlignmentLeft | NSTextAlignmentCenter;
    userLabel.numberOfLines = 1;
    userLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    [headerView addSubview:userLabel];
    
    logoutLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 16, screenWidth - 24, 30)];
    logoutLabel.textColor = [UIColor whiteColor];
    logoutLabel.textAlignment = NSTextAlignmentRight;
    logoutLabel.numberOfLines = 1;
    logoutLabel.text = @"注销登陆";
    logoutLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
    UITapGestureRecognizer *onclickListener = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(logoutOnclickListener)];
    [logoutLabel addGestureRecognizer:onclickListener];
    logoutLabel.userInteractionEnabled = YES;
    [headerView addSubview:logoutLabel];
}

- (CGFloat) getHeaderHeight{
    return screenHeight / 4 + 0.5f;
}

- (void) viewWillAppear:(BOOL)animated{
    accountLabel.text = [[NSString alloc] initWithFormat:@"%@", [CWDataManager sharedInstance]->self_name];
    char *tid = [[CWThings4Interface sharedInstance] get_var_with_path:"" path:"" sessions:NO];
    userLabel.text = [[NSString alloc] initWithFormat:@"TID：%s", tid ? tid : ""];
    
    self.settingListData = [[SettingItem sharedInstance] get_setting_list];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor whiteColor];
}

#pragma mark --UITableViewDataSource 协议方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.settingListData count];
//    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger index = [indexPath row];
    SettingItem  *item = self.settingListData[index];
    NSString* title = item.title;
    BOOL isCheckedMode = item.isCheckedMode;
    
    if (isCheckedMode) {
        //checked mode
        SettingCheckedViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierForSettingChecked forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[SettingCheckedViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierForSettingChecked];
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.titleLabel.text = title;
        
        [cell.checkSwitch setOn:item.isChecked animated:TRUE];
        [cell.checkSwitch setTag:item.itemId];
        [cell.checkSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        
        return cell;
    }else{
        //text style
        SettingTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierForSettingText forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[SettingTextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierForSettingText];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.titleLabel.text = title;

        return cell;
    }

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}


// like item click listener
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"click item is %li", indexPath.row);
    NSInteger index = indexPath.row;
    
    if (index == 0) {
        VideoTypeViewController* videoController = [[VideoTypeViewController alloc] init];
        UINavigationController* navigationController = [[UINavigationController alloc]
                                                            initWithRootViewController:videoController];
        [self presentViewController:navigationController animated:TRUE completion:nil];
    }
    
}

-(void)switchAction:(id)sender{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    NSInteger itemId = switchButton.tag;
    
    NSLog(@"itemId:%lu  %d",itemId , isButtonOn);
    
    if (itemId == 3002) {
        //设置通道类型
        NSLog(@"设置通道类型 %lu  %d",itemId , isButtonOn);
        [[CWFileUtils sharedInstance] showChannelName:isButtonOn];
        
    }else if(itemId == 3003){
        //密码锁屏
        NSLog(@"密码锁屏 %lu  %d",itemId , isButtonOn);
        [[CWFileUtils sharedInstance] useLockScreen:isButtonOn];
        
    }else if(itemId == 3004){
        //保存反控密码
        NSLog(@"保存反控密码 %lu  %d",itemId , isButtonOn);
        [[CWFileUtils sharedInstance] saveControlPassword:isButtonOn];
    }
}

- (void) logoutOnclickListener{
    NSLog(@"注销登陆");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注销" message:@"确定注销当前用户吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"item click  %lu", buttonIndex);
    if (buttonIndex == 1) {
        //logout
        NSLog(@"item click logout");

        [[CWDataManager sharedInstance] reportNotHandleEvent:NO];
        [[CWThings4Interface sharedInstance] disconnect];
        [CWDataManager sharedInstance]->user_login_ok = NO;

        [self.tabBarController dismissViewControllerAnimated:NO completion:^{
            NSLog(@"dismissViewControllerAnimated");
        }];
    }
}


@end
