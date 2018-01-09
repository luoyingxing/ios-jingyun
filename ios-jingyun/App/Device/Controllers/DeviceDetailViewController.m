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
#import "DeviceMessageModel.h"
#import "DeviceMessageServerCell.h"

#define CellIdentifierZone @"CellIdentifierZone"

#define CellIdentifierLocal @"CellIdentifierLocal"
#define CellIdentifierServer @"CellIdentifierServer"

@interface DeviceDetailViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>{
    
    NSTimer *message_update_timer;
    
}

//保存数据列表
@property (nonatomic,strong) NSMutableArray* deviceArray;

@property (nonatomic, assign) NSInteger preMessageCount;


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
    [self addCollectionView];
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

- (void) addCollectionView{
    CGFloat topY = 20 + 44 + 2 + 6;
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    //设置每个单元格的尺寸
    layout.itemSize = CGSizeMake((screenWidth - 16 - 80 - 4) / 4, 22);
    //设置整个CollectionView的内边距
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);

    //设置单元格之间的间距
    layout.minimumInteritemSpacing = 0;

    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(8 + 80, topY, screenWidth - 8 - 8 - 80, 80 - 6) collectionViewLayout:layout];
    //设置可重用单元格标识与单元格类型
//    [collectionView registerNib:[ZoneViewCell class]  forCellWithReuseIdentifier:CellIdentifierZone];
    [collectionView registerNib:[UINib nibWithNibName:@"ZoneViewCell" bundle:nil] forCellWithReuseIdentifier:CellIdentifierZone];
    
    collectionView.backgroundColor = [CWColorUtils colorWithHexString:@"#ffffff" alpha:0.0f];
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
    
    //本地模式（自己）
    [tableView registerClass:[DeviceMessageLocalCell class] forCellReuseIdentifier:CellIdentifierLocal];
    //服务器返回模式（接受到的消息）
    [tableView registerClass:[DeviceMessageServerCell class] forCellReuseIdentifier:CellIdentifierServer];
    
    [self.view addSubview:tableView];
}

- (void)viewDidAppear:(BOOL)animated{
    if (message_update_timer == nil) {
        float palFrame = 1.0;
        message_update_timer = [NSTimer scheduledTimerWithTimeInterval:palFrame target:self selector:@selector(message_update_func) userInfo:nil repeats:YES];
    }
    
    
    _deviceStatusModel.unread_count = 0;
    [self loadDeviceData:NO];
    [self loadZoneData];
    
    
//    rcTable = self.tableView.frame;
//    [_chat_bar setSuperViewHeight:[UIScreen mainScreen].bounds.size.height];
    
//    _isUnDidLoadController = YES;
}

- (void) viewWillDisappear:(BOOL)animated{
    
    if (message_update_timer) {
        [message_update_timer invalidate];
        message_update_timer = nil;
    }
    
    _deviceStatusModel.unread_count = 0;
    [[CWDataManager sharedInstance] saveUnreadEvent4Things:_deviceStatusModel.tid value:0];
    
//    if (_isUnDidLoadController == YES) {
//        [[DHVideoDeviceHelper sharedInstance] DisconnectDevice];
//    }
//    else {
    
//    }
}

//加载防区等信息
- (void) loadZoneData{
    if (_deviceStatusModel) {
        if (_deviceStatusModel.caption != nil) {
            titleLabel.text = _deviceStatusModel.caption;
        }else{
            titleLabel.text = @"设备";
        }
        
        if(_deviceStatusModel.isDeviceOpen){
            statusLabel.text = @"撤防";
            statusImageView.image = [UIImage imageNamed:@"icon_device_alarm.png"];
        }else{
            statusLabel.text = @"布防";
            statusImageView.image = [UIImage imageNamed:@"icon_device_safety.png"];
        }
        
        if ([_deviceStatusModel.globalSatus isEqualToString:@"0"]) {
            subtitleLabel.text = @"设备状态：断开";
        }else if ([_deviceStatusModel.globalSatus isEqualToString:@"1"]) {
            subtitleLabel.text = @"设备状态：连接";
        }else {
           subtitleLabel.text = @"设备状态：未知";
        }
        
        
    }
    
    [collectionView reloadData];
}

/*
 * 加载消息数据
 */
- (void) loadDeviceData:(BOOL)more{
    char cmd[128] = {0};
    if ([self.dataArray count]) {
        DeviceMessageModel *chat_model = [self.dataArray objectAtIndex:0];
        if (chat_model && more) {
            if ([[CWDataManager sharedInstance] isOldSystemVersion]) {
                sprintf(cmd, "/get_msg_of?tid=%s&mode=before&mid=%ld&cnt=%d", [_deviceStatusModel.tid UTF8String], (long)chat_model.mid, 15);
            }else {
                sprintf(cmd, "/message/last?of=%s&limit=%d&dir=before&mid=%ld", [_deviceStatusModel.tid UTF8String], 30, (long)chat_model.mid);
            }
        }
    }
    else {
        NSMutableArray *messageArray = [[CWDataManager sharedInstance] getChatMessageArray4Tid:_deviceStatusModel.tid];
        if (messageArray == nil || [messageArray count] == 0) {
            if ([[CWDataManager sharedInstance] isOldSystemVersion]) {
                sprintf(cmd, "/get_msg_of?tid=%s&mode=%s&cnt=%ld", [_deviceStatusModel.tid UTF8String], "last", (long)30);
            }else {
                sprintf(cmd, "/message/last?of=%s&limit=%d", [_deviceStatusModel.tid UTF8String], 30);
            }
        }else {
            self.dataArray = messageArray;
        }
    }
    
    if (strlen(cmd) > 0) {
        [[CWThings4Interface sharedInstance] request:"." URL:cmd UrlLen:(int)strlen(cmd) ReqID:"messageLast"];
    }
    else {
        [tableView reloadData];
//        [_myRefreshView endRefreshing];
        
        if ([self.dataArray count] > 5) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([self.dataArray count] - 1) inSection:0];
            if (indexPath != nil) {
                [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
            _preMessageCount = [self.dataArray count];
        }
    }
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 7;
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
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger index = [indexPath row];
    
    DeviceMessageModel* messageModel = [self.dataArray objectAtIndex:index];
    
    if (messageModel.messageType == MessageTypeForLOCAL) {
        //自己发出的消息
        DeviceMessageLocalCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierLocal forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[DeviceMessageLocalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierLocal];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.contentLabel.text = messageModel.text;
    
        return cell;
        
    }else{
        //接收的消息
        DeviceMessageServerCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierServer forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[DeviceMessageServerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierServer];
        }

        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        cell.contentLabel.text = messageModel.text;

        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger index = [indexPath row];
    DeviceMessageModel* messageModel = [self.dataArray objectAtIndex:index];
    
    if (messageModel.messageType == MessageTypeForLOCAL) {
        return [DeviceMessageLocalCell getCellHeight];
    }else{
        return [DeviceMessageServerCell getCellHeight];
    }
    
    return 30;
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

- (NSMutableArray *) dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

- (void) message_update_func{
    if ([CWDataManager sharedInstance]->chat_message_update == YES) {
        //load message data
        self.dataArray = [[CWDataManager sharedInstance] getChatMessageArray4Tid:_deviceStatusModel.tid];
        [tableView reloadData];
//        [_myRefreshView endRefreshing];
        
        NSInteger messageCountInteger = [self.dataArray count] - _preMessageCount;
        if (messageCountInteger) {
//            [_message_bar ShowMessageCount:messageCountInteger];
        }
        
        [CWDataManager sharedInstance]->chat_message_update = NO;
        /*if ([self.dataArray count] > 5) {
         NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([self.dataArray count] - 1) inSection:0];
         [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
         }*/
    }
    
//    [_chatStatusView updateStatus];
}

@end
