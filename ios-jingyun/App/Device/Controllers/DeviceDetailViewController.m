//
//  DeviceDetailViewController.m
//  ios-jingyun
//
//  Created by conwin on 2018/1/5.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceDetailViewController.h"
#import "CWColorUtils.h"
#import "CWDataManager.h"
#import "CWThings4Interface.h"
#import "DeviceStatusModel.h"
#import "DeviceMessageLocalCell.h"

#define CellIdentifierLocal @"CellIdentifierLocal"
#define CellIdentifierServer @"CellIdentifierServer"

@interface DeviceDetailViewController ()<UITableViewDelegate, UITableViewDataSource>

//保存数据列表
@property (nonatomic,strong) NSMutableArray* deviceArray;


@end

@implementation DeviceDetailViewController {
    UITableView *tableView;
    UIImageView* backImageView;
    UILabel* titleLabel;
    UILabel* subtitleLabel;
    UILabel* zoneLabel;
    
    CGFloat screenHeight;
    CGFloat screenWidth;
    CGFloat childViewsY;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    screenHeight = self.view.bounds.size.height;
    screenWidth = self.view.bounds.size.width;
    self.deviceArray = [[NSMutableArray alloc] init];

    [self addToolbarView];
    [self addTopView];
    [self initTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void) addToolbarView{
    CGFloat toolbarHeight = 20 + 44;
    
    UIView* toolbarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, toolbarHeight)];
    toolbarView.backgroundColor = [CWColorUtils getThemeColor];
    [self.view addSubview:toolbarView];
    
    backImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_back_white.png"]];
    backImageView.frame = CGRectMake(20, 20 + 8, 28, 28);
    backImageView.contentMode =  UIViewContentModeScaleAspectFit;
    backImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *backListener = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goback)];
    [backImageView addGestureRecognizer:backListener];
    backImageView.clipsToBounds  = YES;
    [self.view addSubview:backImageView];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 22, screenWidth - 100, 22)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    if (_deviceStatusModel) {
        if (_deviceStatusModel.caption != nil) {
            titleLabel.text = _deviceStatusModel.caption;
        }else{
            titleLabel.text = @"设备";
        }
    }
    titleLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:titleLabel];
    
    subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 42, screenWidth - 100, 20)];
    subtitleLabel.textColor = [UIColor whiteColor];
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    subtitleLabel.numberOfLines = 1;
    subtitleLabel.text = @"设备状态：连接";
    subtitleLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:subtitleLabel];
    
    zoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - 60, 20, 44, 44)];
    zoneLabel.textColor = [UIColor whiteColor];
    zoneLabel.textAlignment = NSTextAlignmentRight;
    zoneLabel.text = @"防区";
    zoneLabel.font = [UIFont systemFontOfSize:17];
    UITapGestureRecognizer *onclickListener = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zoneOnclickListener)];
    [zoneLabel addGestureRecognizer:onclickListener];
    zoneLabel.userInteractionEnabled = YES;
    [self.view addSubview:zoneLabel];
}

- (void) addTopView{
    CGFloat topHeight = 20 + 44 + 44 + 18;
    
//    UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, topHeight)];
//    bgView.backgroundColor = [CWColorUtils getThemeColor];
//    [self.view addSubview:bgView];
//
//    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_white_logo"]];
//    imageView.frame = CGRectMake(10, 27, 30, 30);
//    imageView.contentMode =  UIViewContentModeScaleAspectFit;
//    imageView.clipsToBounds  = YES;
//    [self.view addSubview:imageView];
//
//    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 22, screenWidth - 80, 20)];
//    titleLabel.textColor = [UIColor whiteColor];
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    titleLabel.text = @"设备";
//    titleLabel.font = [UIFont systemFontOfSize:16];
//    [self.view addSubview:titleLabel];
//
//    subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 42, screenWidth - 80, 20)];
//    subtitleLabel.textColor = [UIColor whiteColor];
//    subtitleLabel.textAlignment = NSTextAlignmentCenter;
//    subtitleLabel.numberOfLines = 1;
//    subtitleLabel.text = @"全部 | 0";
//    subtitleLabel.font = [UIFont systemFontOfSize:15];
//    [self.view addSubview:subtitleLabel];
    
//    filterLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - 64, 20, 50, 44)];
//    filterLabel.textColor = [UIColor whiteColor];
//    filterLabel.textAlignment = NSTextAlignmentRight;
//    filterLabel.text = @"过滤";
//    filterLabel.font = [UIFont systemFontOfSize:17];
//    UITapGestureRecognizer *onclickListener = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(filterOnclickListener)];
//    [filterLabel addGestureRecognizer:onclickListener];
//    filterLabel.userInteractionEnabled = YES;
//    [self.view addSubview:filterLabel];
    
    CGFloat fliterWidth = (screenWidth - 16) /4;
    
    
    
//    tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 108, screenWidth, 18)];
//    tipLabel.backgroundColor = [UIColor whiteColor];
//    tipLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
//    tipLabel.textColor = [UIColor grayColor];
//    tipLabel.textAlignment = NSTextAlignmentCenter;
//    tipLabel.text = @"全部0/撤防0";
//    [self.view addSubview:tipLabel];
}

- (void) initTableView{
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 126, screenWidth, screenHeight - 126) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    //分割线颜色
    tableView.separatorColor = [UIColor whiteColor];
    tableView.backgroundColor = [UIColor whiteColor];
    
    //纯文字选择项
    [tableView registerClass:[DeviceMessageLocalCell class] forCellReuseIdentifier:CellIdentifierLocal];
    //选择框样式
    //    [tableView registerClass:[DeviceImageCell class] forCellReuseIdentifier:CellIdentifierForImage];
    
    [self.view addSubview:tableView];
}

- (void) viewWillAppear:(BOOL)animated{
    [self loadDeviceData];
}

//- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
//    view.tintColor = [UIColor whiteColor];
//}

- (void) loadDeviceData{
    
    
    [tableView reloadData];
}

#pragma mark --UITableViewDataSource 协议方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return [self.deviceArray count];
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger index = [indexPath row];
    
//    if (currentFilterIndex == 2) {
        //image mode
        DeviceMessageLocalCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierLocal forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[DeviceMessageLocalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierLocal];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        return cell;
        
//    }else{
        //default mode
        
//        DeviceMessageLocalCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierForDefault forIndexPath:indexPath];
//        if (cell == nil) {
//            cell = [[DeviceDefaultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierForDefault];
//        }
//
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//
//
//
//        return cell;
//    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (currentFilterIndex == 2) {
        return [DeviceMessageLocalCell getCellHeight];
//    }else{
//        return [DeviceDefaultCell getCellHeight];
//    }
    
    return 100;
}

- (void) filterOnclickListener{
    NSLog(@"filterOnclickListener");
    
}


// like item click listener
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"click item %li", indexPath.row);
    
    
}

- (NSDictionary *) dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (void) goback{
    //back to device controller
    
    [self dismissViewControllerAnimated:TRUE completion:^{
        NSLog(@"back to device ");
    }];
}

- (void) zoneOnclickListener{
    NSLog(@"zoneOnclickListener");
}

@end
