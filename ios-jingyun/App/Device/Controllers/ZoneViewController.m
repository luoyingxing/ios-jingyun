//
//  ZoneViewController.m
//  ios-jingyun
//
//  Created by conwin on 2018/1/18.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import "ZoneViewController.h"
#import "CWColorUtils.h"
#import "DeviceZoneViewCell.h"
#import "CWThings4Interface.h"
#import "ZoneOnItemClickDelegate.h"
#import "DeviceZoneModel.h"
#import "CWThings4Interface.h"
#import "CWDataManager.h"
#import "MBProgressHUD.h"
#import "CWFileUtils.h"
#import "CWTextUtils.h"

#define CellIdentifier @"DeviceZoneViewCell"

@interface ZoneViewController ()<ZoneOnItemClickDelegate, UIAlertViewDelegate>{
    MBProgressHUD *mbProgress;
}

@property (nonatomic, strong) NSMutableArray *zoneArray;

@property (assign, nonatomic) BOOL *enablePass;

@end

@implementation ZoneViewController{
    
    NSTimer *zone_update_timer;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    
    [self initBaseBar];
    [self initTableView];
}

- (void) initBaseBar{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.navigationController.navigationBar setBarTintColor:[CWColorUtils getThemeColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],
                                                                      NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.title = @"防区操作";
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
    backButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    backButton.adjustsImageWhenHighlighted = NO;
    [backButton setImage:[UIImage imageNamed:@"icon_back_white.png"] forState:UIControlStateNormal];
    [backButton setTitle:@"防区" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
    backButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    if ([_deviceStatusModel.partID isEqualToString:@"1000"] || [_deviceStatusModel.partID isEqualToString:@"1001"]) {
        _enablePass = NO;
    }else{
        _enablePass = YES;
    }
    
    if (_enablePass){
        if (![_deviceStatusModel.deviceType isEqualToString:@"device"] || ![_deviceStatusModel.partID isEqualToString:@"2000"]) {
            UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新状态"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(refreshStatus:)];
            addItem.tintColor = [UIColor whiteColor];
            self.navigationItem.rightBarButtonItem = addItem;
        }
    }
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated{
    [self loadZonaData];
}

- (void) viewDidAppear:(BOOL)animated{
    if (zone_update_timer == nil) {
        float palFrame = 2.0;
        zone_update_timer = [NSTimer scheduledTimerWithTimeInterval:palFrame target:self selector:@selector(zone_update_func) userInfo:nil repeats:YES];
    }
}

- (void) viewWillDisappear:(BOOL)animated{
    if (zone_update_timer) {
        [zone_update_timer invalidate];
        zone_update_timer = nil;
    }
}

- (void) zone_update_func{
    [self loadZonaData];
}

- (void) loadZonaData{
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    
    if ([_deviceStatusModel.partID isEqualToString:@"2000"]) {
        int count = [[CWThings4Interface sharedInstance] get_var_nodes_with_tid:[_deviceStatusModel.tid UTF8String] path:"zones"];
        //后台数据的顺序是倒叙的，无奈重新排序
        for (int i = count - 1; i >= 0; i --) {
            DeviceZoneModel* zoneModel = [[DeviceZoneModel alloc] init];
            
            char* channel_name = [[CWThings4Interface sharedInstance] get_var_with_path_ex:[_deviceStatusModel.tid UTF8String] prepath:"zones" member:i backpath:NULL];
            
            if (channel_name && strcmp(channel_name, "default") == 0) {
                continue;
            }
            zoneModel.name = [NSString stringWithUTF8String:channel_name];
            
            char* zone_status = [[CWThings4Interface sharedInstance] get_var_with_path_ex:[_deviceStatusModel.tid UTF8String] prepath:"zones" member:i backpath:"stat"];
            
            zoneModel.status = [NSString stringWithUTF8String:zone_status];
            
            [arr addObject:zoneModel];
        }
    }else{
        int count = [[CWThings4Interface sharedInstance] get_var_nodes_with_tid:[_deviceStatusModel.tid UTF8String] path:"z"];
        //后台数据的顺序是倒叙的，无奈重新排序
        for (int i = count - 1; i >= 0; i --) {
            DeviceZoneModel* zoneModel = [[DeviceZoneModel alloc] init];
            
            char* channel_name = [[CWThings4Interface sharedInstance] get_var_with_path_ex:[_deviceStatusModel.tid UTF8String] prepath:"z" member:i backpath:NULL];
            if (channel_name && strcmp(channel_name, "default") == 0) {
                continue;
            }
            zoneModel.name = [NSString stringWithUTF8String:channel_name];
            
            //            NSLog(@"count = %d   channel_name: %s", count, channel_name);
            char* zone_status = [[CWThings4Interface sharedInstance] get_var_with_path_ex:[_deviceStatusModel.tid UTF8String] prepath:"z" member:i backpath:"s"];
            zoneModel.status = [NSString stringWithUTF8String:zone_status];
            
            [arr addObject:zoneModel];
        }
    }
    
    if (_zoneArray == nil) {
        _zoneArray = [[NSMutableArray alloc] init];
    }else{
        _zoneArray = arr;
    }
    
    [self.tableView reloadData];
}

- (void)initTableView{
    //不显示分割线
    self.tableView.separatorStyle = UITableViewCellEditingStyleNone;
    
    [self.tableView registerClass:[DeviceZoneViewCell class] forCellReuseIdentifier:CellIdentifier];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _zoneArray.count;
//    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = [indexPath row];
    DeviceZoneModel* model = [_zoneArray objectAtIndex:index];
    
    DeviceZoneViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[DeviceZoneViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    [cell setOnItemClickDelegate:self];
    cell.index = index;
    
    NSString* status = model.status;
    
    if ([status isEqualToString:@"normal"] || [status isEqualToString:@"nm"]) {
        cell.statusImage.image = [UIImage imageNamed:@"icon_item_zone_normal.png"];
        
        NSString* name = [NSString stringWithFormat:@"防区%@（%@）", model.name,@"正常"];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:name];
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:[CWColorUtils getThemeColor]
                        range:NSMakeRange(name.length - 4, 4)];
        cell.nameLabel.attributedText = attrStr;
        
    }else if ([status isEqualToString:@"bypass"]) {
        cell.statusImage.image = [UIImage imageNamed:@"icon_item_zone_orange.png"];
        
        NSString* name = [NSString stringWithFormat:@"防区%@（%@）", model.name,@"旁路"];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:name];
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:[CWColorUtils colorWithHexString:@"#ff9801"]
                        range:NSMakeRange(name.length - 4, 4)];
        cell.nameLabel.attributedText = attrStr;
    }else if ([status isEqualToString:@"alarm"]) {
        cell.statusImage.image = [UIImage imageNamed:@"icon_item_zone_red.png"];
        
        NSString* name = [NSString stringWithFormat:@"防区%@（%@）", model.name,@"报警"];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:name];
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:[CWColorUtils colorWithHexString:@"#ff5555"]
                        range:NSMakeRange(name.length - 4, 4)];
        cell.nameLabel.attributedText = attrStr;
    }else if ([status isEqualToString:@"nr"]) {
        cell.statusImage.image = [UIImage imageNamed:@"icon_item_zone_black.png"];
        
        NSString* name = [NSString stringWithFormat:@"防区%@（%@）", model.name,@"未准备"];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:name];
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:[CWColorUtils colorWithHexString:@"#333333"]
                        range:NSMakeRange(name.length - 5, 5)];
        cell.nameLabel.attributedText = attrStr;
    }else{
        cell.statusImage.image = [UIImage imageNamed:@"icon_item_zone_list_gray.png"];
        
        NSString* name = [NSString stringWithFormat:@"防区%@（%@）", model.name,@"未知"];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:name];
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:[CWColorUtils colorWithHexString:@"#727272"]
                        range:NSMakeRange(name.length - 4, 4)];
        cell.nameLabel.attributedText = attrStr;
    }
    
    
    if (_enablePass) {
        if ([status isEqualToString:@"bypass"]) {
            cell.passLabel.text = @"解除旁路";
            cell.passLabel.layer.borderColor = [CWColorUtils colorWithHexString:@"#FF9801"].CGColor;
        }else{
            cell.passLabel.text = @"旁路";
            cell.passLabel.layer.borderColor = [CWColorUtils getThemeColor].CGColor;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [DeviceZoneViewCell getCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"click item is %li", indexPath.row);
    
    
}

- (void) onItemClickListener:(NSInteger *)index{
    DeviceZoneModel* model = [_zoneArray objectAtIndex:index];
    
    if ([_deviceStatusModel.partID isEqualToString:@"1002"] || [_deviceStatusModel.partID isEqualToString:@"1100"] || [_deviceStatusModel.partID isEqualToString:@"2000"]) {
        if ([CWDataManager sharedInstance]->by_pass_right_ == NO) {
            [self showToast:@"没有旁路权限！"];
            return;
        }
    }
    
    NSString* zoneName = model.name;
    NSString* status = model.status;
    NSString* cmd;
    
    if ([status isEqualToString:@"bypass"]) {
        cmd = @"unbypass";
    }else{
        cmd = @"bypass";
    }
    
    NSString* cmdStr = [NSString stringWithFormat:@"%@,,cmd,%@,", _deviceStatusModel.tid, cmd];
    
    [self checkPushMessage:cmdStr content:zoneName];
}

- (void) checkPushMessage:cmd content:(NSString*) content{
    self.cmd = nil;
    self.content = nil;
    
    NSString* passwrod = [[CWFileUtils sharedInstance] readString:[NSString stringWithFormat:@"%@_password", _deviceStatusModel.tid]];
    
    if (passwrod == nil || passwrod.length == 0) {
        [self showAlertDialog:cmd content:content];
    }else{
        if ([[CWFileUtils sharedInstance] saveControlPassword]) {
            NSString* cont;
            if ([CWTextUtils isEmpty:content]) {
                cont = @"";
            } else {
                cont = [NSString stringWithFormat:@",%@", content];
            }
            
            NSString* msg = [NSString stringWithFormat:@"%@%@%@", cmd, passwrod, cont];
            [[CWThings4Interface sharedInstance] push_msg:[msg UTF8String] MsgLen:(int)msg.length MsgType:"im"];
        } else {
            [self showAlertDialog:cmd content:content];
        }
    }
}

//添加密码的对话框
- (void) showAlertDialog:cmd content:(NSString*) content{
    self.cmd = cmd;
    self.content = content;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入反控密码" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *passwordField = [alert textFieldAtIndex:0];
    passwordField.placeholder = @"请输入反控密码";
    [alert show];
}

#pragma mark alertView
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        UITextField *passwordField = [alertView textFieldAtIndex:0];
        NSLog(@"alertView: %@", passwordField.text);
        NSString* password = passwordField.text;
        if ([CWTextUtils isEmpty:password]) {
            [self showToast:@"密码不能为空!"];
        } else {
            if ([[CWFileUtils sharedInstance] saveControlPassword]) {
                [[CWFileUtils sharedInstance] saveString:[NSString stringWithFormat:@"%@_password", _deviceStatusModel.tid] value:password];
            }
            
            NSString* cont;
            if ([CWTextUtils isEmpty:self.content]) {
                cont = @"";
            } else {
                cont = [NSString stringWithFormat:@",%@", self.content];
            }
            
            NSString* msg = [NSString stringWithFormat:@"%@%@%@", self.cmd, password, cont];
            [[CWThings4Interface sharedInstance] push_msg:[msg UTF8String] MsgLen:(int)msg.length MsgType:"im"];
        }
    }

}

- (void) back:(id)sender{
    //back to add message detail controller
    [self dismissViewControllerAnimated:TRUE completion:^{
        NSLog(@"back to message ");
    }];
}

- (void) refreshStatus:(id)sender{
    //refreshStatus
    NSLog(@"refreshStatus");
    
    NSString* msg = [NSString stringWithFormat:@"%@,,cmd,query", _deviceStatusModel.tid];
    
    [[CWThings4Interface sharedInstance] push_msg:[msg UTF8String] MsgLen:(int)[msg length] MsgType:"im"];

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

@end
