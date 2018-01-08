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
#import "ZoneViewCell.h"

#define CellIdentifierZone @"CellIdentifierZone"

#define CellIdentifierLocal @"CellIdentifierLocal"
#define CellIdentifierServer @"CellIdentifierServer"

@interface DeviceDetailViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>

//保存数据列表
@property (nonatomic,strong) NSMutableArray* deviceArray;


@end

@implementation DeviceDetailViewController {
    UITableView *tableView;
    UIImageView* backImageView;
    UILabel* titleLabel;
    UILabel* subtitleLabel;
    UILabel* zoneLabel;
    
    UIImageView* statusImageView;
    UILabel* statusLabel;
    UICollectionView* collectionView;
    
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
    [self addGridView];
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
    childViewsY += toolbarHeight;
    
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
    CGFloat topHeight = 80 + 2;
    CGFloat topY = 20 + 44 + 2;
    childViewsY += topHeight;
    
    UIImageView* statusBgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_device_detail_status.png"]];
    statusBgImageView.frame = CGRectMake(8, topY, 80 , 80);
    statusBgImageView.contentMode =  UIViewContentModeScaleToFill;
    statusBgImageView.clipsToBounds  = YES;
    [self.view addSubview:statusBgImageView];
    
    UIImageView* zoneBgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_device_detail_zone.png"]];
    zoneBgImageView.frame = CGRectMake(8 + 80, topY, screenWidth - 8 - 8 - 80, 80);
    zoneBgImageView.contentMode =  UIViewContentModeScaleToFill;
    zoneBgImageView.clipsToBounds  = YES;
    [self.view addSubview:zoneBgImageView];
    
    statusImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_device_safety.png"]];
    statusImageView.frame = CGRectMake(8 + 20, topY + 10, 40 , 40);
    statusImageView.contentMode =  UIViewContentModeScaleToFill;
    statusImageView.clipsToBounds  = YES;
    [self.view addSubview:statusImageView];
    
    statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, topY + 50, 80 , 30)];
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.text = @"布防";
    statusLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:statusLabel];
  
}

- (void) addGridView{
    CGFloat topY = 20 + 44 + 2;
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    //设置每个单元格的尺寸
    layout.itemSize = CGSizeMake((screenWidth - 16 - 80 - 4) / 4, 26);
    //设置整个CollectionView的内边距
    layout.sectionInset = UIEdgeInsetsMake(0, 2, 0, 2);
    
    //设置单元格之间的间距
    layout.minimumInteritemSpacing = 0;

    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(8 + 80, topY, screenWidth - 8 - 8 - 80, 80) collectionViewLayout:layout];
    //设置可重用单元格标识与单元格类型
//    [collectionView registerNib:[ZoneViewCell class]  forCellWithReuseIdentifier:CellIdentifierZone];
    [collectionView registerNib:[UINib nibWithNibName:@"ZoneViewCell" bundle:nil] forCellWithReuseIdentifier:CellIdentifierZone];
    
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    
    [self.view addSubview:collectionView];
}

- (void) initTableView{
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, childViewsY, screenWidth, screenHeight - childViewsY) style:UITableViewStylePlain];
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

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 17;
}

#pragma mark - UICollectionViewDelegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZoneViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifierZone forIndexPath:indexPath];
    
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"select indexPath.row : %lu", indexPath.row);
    
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
