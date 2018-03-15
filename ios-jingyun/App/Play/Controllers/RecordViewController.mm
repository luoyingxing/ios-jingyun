//
//  RecordViewController.m
//  ios-jingyun
//
//  Created by luoyingxing on 2018/3/12.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import "RecordViewController.h"
#import "CWColorUtils.h"
#import "DHVideoDeviceHelper.h"
#import "CWRecordModel.h"
#import "RecordCell.h"
#import "RecordPlayViewController.h"

#define CellIdentifier @"CellIdentifier"

@interface RecordViewController ()<UITableViewDelegate, UITableViewDataSource>{
    CGFloat screenHeight;
    CGFloat screenWidth;

    CGFloat menuHeight;
    
    UILabel* todayLabel;
    UILabel* yesterdayLabel;
    UILabel* customLabel;
    
    NSThread *handle_thread;
    NSTimer *timer;
    
    NSString *start_date_and_time;
    NSString *end_date_and_time;
    
    UILabel *start_time_label_;
    UILabel *end_time_label_;
    NSInteger selected_time_mode_;
}

@property (strong, nonatomic) NSMutableArray* dataArray;

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   
    screenHeight = self.view.bounds.size.height;
    screenWidth = self.view.bounds.size.width;
    menuHeight = 46;
    
    self.dataArray = [[NSMutableArray alloc] init];
    
    [[DHVideoDeviceHelper sharedInstance] ConnectDevice:_tid withNodeTID:nil withPartID:@"2000"];
    
    [self initTime];
    
    [self initBaseBar];
    [self addTopMenus];
    [self addTableView];
}

- (void) initTime{
    selected_time_mode_ = 1;
    start_time_label_ = nil;
    end_time_label_ = nil;
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    
    start_date_and_time = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", [dateComponent year], [dateComponent month], [dateComponent day], 0, 0, 0];
    end_date_and_time = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", [dateComponent year], [dateComponent month], [dateComponent day], 23, 59, 59];
}

- (void) initBaseBar{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
//    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.navigationController.navigationBar setBarTintColor:[CWColorUtils getThemeColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],
                                                                      NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.title = @"视频录像";
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
    backButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    backButton.adjustsImageWhenHighlighted = NO;
    [backButton setImage:[UIImage imageNamed:@"icon_back_white.png"] forState:UIControlStateNormal];
    [backButton setTitle:@"录像" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
    backButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void) addTopMenus{
    CGFloat perWidth = (screenWidth - 12 - 12) / 3;
    CGFloat perHeight = menuHeight - 6 - 6;
    
    todayLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 6, perWidth, perHeight)];
    todayLabel.backgroundColor =  [CWColorUtils getThemeColor];
    todayLabel.textColor = [UIColor whiteColor];
    todayLabel.textAlignment = NSTextAlignmentCenter;
    todayLabel.text = @"今天";
    todayLabel.font = [UIFont systemFontOfSize:16];
    //    alarmLabel.layer.cornerRadius = 5;
    todayLabel.layer.borderColor = [CWColorUtils getThemeColor].CGColor;
    todayLabel.layer.borderWidth = 0.5;
    UITapGestureRecognizer *todayOnclickListener = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(todayOnclickListener)];
    [todayLabel addGestureRecognizer:todayOnclickListener];
    todayLabel.userInteractionEnabled = YES;
    //设置绘制的圆角
    todayLabel.layer.masksToBounds = YES;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:todayLabel.bounds  byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopLeft cornerRadii:CGSizeMake(5, 5)];//设置圆角大小，弧度为5
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = todayLabel.bounds;
    maskLayer.path = maskPath.CGPath;
    todayLabel.layer.mask = maskLayer;
    [self.view addSubview:todayLabel];
    
    yesterdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(12 + perWidth, 6, perWidth, perHeight)];
    yesterdayLabel.backgroundColor = [UIColor whiteColor];
    yesterdayLabel.textColor = [UIColor grayColor];
    yesterdayLabel.textAlignment = NSTextAlignmentCenter;
    yesterdayLabel.text = @"昨天";
    yesterdayLabel.font = [UIFont systemFontOfSize:16];
    //    alarmLabel.layer.cornerRadius = 5;
    yesterdayLabel.layer.borderColor = [CWColorUtils getThemeColor].CGColor;
    yesterdayLabel.layer.borderWidth = 0.5;
    UITapGestureRecognizer *yesterdayOnclickListener = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(yesterdayOnclickListener)];
    [yesterdayLabel addGestureRecognizer:yesterdayOnclickListener];
    yesterdayLabel.userInteractionEnabled = YES;
    [self.view addSubview:yesterdayLabel];
    
    customLabel = [[UILabel alloc] initWithFrame:CGRectMake(12 + perWidth + perWidth, 6, perWidth, perHeight)];
    customLabel.backgroundColor = [UIColor whiteColor];
    customLabel.textColor = [UIColor grayColor];
    customLabel.textAlignment = NSTextAlignmentCenter;
    customLabel.text = @"自定义";
    customLabel.font = [UIFont systemFontOfSize:16];
    //    otherLabel.layer.cornerRadius = 5;
    customLabel.layer.borderColor = [CWColorUtils getThemeColor].CGColor;
    customLabel.layer.borderWidth = 0.5;
    UITapGestureRecognizer *customOnclickListener = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(customOnclickListener)];
    [customLabel addGestureRecognizer:customOnclickListener];
    customLabel.userInteractionEnabled = YES;
    //设置绘制的圆角
    customLabel.layer.masksToBounds = YES;
    UIBezierPath *maskPath1 = [UIBezierPath bezierPathWithRoundedRect:todayLabel.bounds  byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)];//设置圆角大小，弧度为5
    CAShapeLayer *maskLayer1 = [[CAShapeLayer alloc] init];
    maskLayer1.frame = customLabel.bounds;
    maskLayer1.path = maskPath1.CGPath;
    customLabel.layer.mask = maskLayer1;
    [self.view addSubview:customLabel];
}

- (void) addTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, menuHeight + 10, screenWidth, screenHeight - menuHeight - 44 - 20 - 10) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //分割线颜色
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    //纯文字选择项
//    [self.tableView registerClass:[DeviceDefaultCell class] forCellReuseIdentifier:CellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([RecordCell class]) bundle:nil] forCellReuseIdentifier:CellIdentifier];
    
    [self.view addSubview:self.tableView];
}

#pragma mark --UITableViewDataSource 协议方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger index = [indexPath row];
    CWRecordModel *model = [self.dataArray objectAtIndex:index];
    
    RecordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[RecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *record_name;
    NSString *record_date;
    NSString *record_time;
    
    const NET_TIME&  startTime = model.net_recordfile_info.starttime;
    const NET_TIME&  endTime = model.net_recordfile_info.endtime;
    record_name = [[NSString alloc] initWithFormat:@"%d-%d-%d %d:%d:%d - %d-%d-%d %d:%d:%d", startTime.dwYear, startTime.dwMonth, startTime.dwDay, startTime.dwHour, startTime.dwMinute, startTime.dwSecond, endTime.dwYear, endTime.dwMonth, endTime.dwDay, endTime.dwHour, endTime.dwMinute, endTime.dwSecond];
    
    NSString *record_size = [[NSString alloc] initWithFormat:@"%@: %d K", NSLocalizedString(@"RecordController_RecordFileSize", @""), model.net_recordfile_info.size ];
    
    record_date = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d", startTime.dwYear, startTime.dwMonth, startTime.dwDay];
    record_time = [[NSString alloc] initWithFormat:@"%02d:00", startTime.dwHour];
    
    cell.timeLable.text = record_time;
    
    if (model.show_date == NO){
        if (model.show_time == NO){
            cell.timeLable.hidden = YES;
        }else{
            cell.timeLable.hidden = NO;
        }
    }else if (model.show_time == NO){
        cell.timeLable.hidden = YES;
    }else{
        cell.timeLable.hidden = NO;
    }
    
    cell.titleLable.text = record_name;
    cell.sizeLable.text = record_size;
    

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"click %lu", indexPath.row);
    
    if ([[DHVideoDeviceHelper sharedInstance] isFindRecordStreamFinished] == NO) {
        return ;
    }
    
    if (self.dataArray == nil || [self.dataArray count] == 0) {
        return;
    }
    
    RecordPlayViewController *recordPlayCV = [[RecordPlayViewController new] init];
    [recordPlayCV setDeviceChannelIndex:indexPath.row];
    [recordPlayCV setTid:self.tid];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:recordPlayCV];
    [self presentViewController:navigationController animated:TRUE completion:nil];
}

- (void) viewDidAppear:(BOOL)animated{
    NSLog(@"viewDidAppear _deviceChannel = %lu", _deviceChannel);
    float palFrame = 0.5;
    timer = [NSTimer scheduledTimerWithTimeInterval:palFrame target:self selector:@selector(message_update) userInfo:nil repeats:YES];
        
    [[DHVideoDeviceHelper sharedInstance] FindVideoRecord:_deviceChannel withStartTime:start_date_and_time withEndTime:end_date_and_time];
}

- (void)message_update{
    if ([[DHVideoDeviceHelper sharedInstance] getVideoSearch] == YES) {
        [self.dataArray removeAllObjects];
        for (CWRecordModel *recordModel in [DHVideoDeviceHelper sharedInstance]->video_record_files_array) {
            [self.dataArray addObject:recordModel];
        }
        
        [self.tableView reloadData];
        
        [timer invalidate];
        timer = nil;
    }
}

- (void) back:(id)sender{
    //back to add message detail controller
    [self dismissViewControllerAnimated:TRUE completion:^{
        NSLog(@"back to message details ");
    }];
}

- (void) todayOnclickListener{
    NSLog(@"today");
    todayLabel.backgroundColor = [CWColorUtils getThemeColor];
    todayLabel.textColor = [UIColor whiteColor];
    yesterdayLabel.backgroundColor = [UIColor whiteColor];
    yesterdayLabel.textColor = [UIColor grayColor];
    customLabel.backgroundColor = [UIColor whiteColor];
    customLabel.textColor = [UIColor grayColor];
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    
    start_date_and_time = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", [dateComponent year], [dateComponent month], [dateComponent day], 0, 0, 0];
    end_date_and_time = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", [dateComponent year], [dateComponent month], [dateComponent day], 23, 59, 59];
    
    float palFrame = 0.5;
    timer = [NSTimer scheduledTimerWithTimeInterval:palFrame target:self selector:@selector(message_update) userInfo:nil repeats:YES];
    
    [[DHVideoDeviceHelper sharedInstance] FindVideoRecord:_deviceChannel withStartTime:start_date_and_time withEndTime:end_date_and_time];
}

- (void) yesterdayOnclickListener{
     NSLog(@"yesterday");
    yesterdayLabel.backgroundColor = [CWColorUtils getThemeColor];
    yesterdayLabel.textColor = [UIColor whiteColor];
    todayLabel.backgroundColor = [UIColor whiteColor];
    todayLabel.textColor = [UIColor grayColor];
    customLabel.backgroundColor = [UIColor whiteColor];
    customLabel.textColor = [UIColor grayColor];
    
    NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow:-(24*60*60)];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:yesterday];
    
    start_date_and_time = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", [dateComponent year], [dateComponent month], [dateComponent day], 0, 0, 0];
    end_date_and_time = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", [dateComponent year], [dateComponent month], [dateComponent day], 23, 59, 59];
    
    float palFrame = 0.5;
    timer = [NSTimer scheduledTimerWithTimeInterval:palFrame target:self selector:@selector(message_update) userInfo:nil repeats:YES];
    
    [[DHVideoDeviceHelper sharedInstance] FindVideoRecord:_deviceChannel withStartTime:start_date_and_time withEndTime:end_date_and_time];
}

- (void) customOnclickListener{
    NSLog(@"custom");
    customLabel.backgroundColor = [CWColorUtils getThemeColor];
    customLabel.textColor = [UIColor whiteColor];
    todayLabel.backgroundColor = [UIColor whiteColor];
    todayLabel.textColor = [UIColor grayColor];
    yesterdayLabel.backgroundColor = [UIColor whiteColor];
    yesterdayLabel.textColor = [UIColor grayColor];
    [self showDataPicker];
}

- (void) showDataPicker{
    CGFloat dialogWidth = screenWidth - 10 - 10;
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    datePicker.frame = CGRectMake(0, 0, dialogWidth, 160);
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIAlertController *alert = nil;
    if (INTERFACE_IS_IPAD){
        alert = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleAlert];
    }else {
        alert = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    }
    
    [alert.view addSubview:datePicker];
    
    UIView * pre_view = [[UIView alloc] init];
    pre_view.frame = CGRectMake(0, 160, dialogWidth, 50);
    [pre_view setBackgroundColor:[CWColorUtils colorWithHexString:@"#dcdcdc"]];
    
    UIButton *start_btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    start_btn.frame = CGRectMake(20, 160, 90, 50);
    [start_btn setTitle:@"开始时间" forState:UIControlStateNormal];
    [start_btn addTarget:self action:@selector(startDateTimeSelected:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *start_Label = [[UILabel alloc] init];
    start_Label.frame = CGRectMake(110, 160, dialogWidth - 110, 50);
    start_Label.textColor = [CWColorUtils colorWithHexString:@"#707070"];
    [start_Label setText:@"请选择开始时间"];
    start_time_label_ = start_Label;
    
    [alert.view addSubview:pre_view];
    [alert.view addSubview:start_btn];
    [alert.view addSubview:start_Label];
    
    UIView * back_view = [[UIView alloc] init];
    back_view.frame = CGRectMake(0, 160 + 50, dialogWidth, 50);
    [back_view setBackgroundColor:[CWColorUtils colorWithHexString:@"#dcdcdc"]];
    [alert.view addSubview:back_view];
    
    UIButton *end_btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    end_btn.frame = CGRectMake(20, 160 + 50, 90, 50);
    [end_btn setTitle:@"结束时间" forState:UIControlStateNormal];
    [end_btn addTarget:self action:@selector(endDateTimeSelected:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *end_Label = [[UILabel alloc] init];
    end_Label.frame = CGRectMake(110, 160 + 50, dialogWidth - 110, 50);
    end_Label.textColor = [CWColorUtils colorWithHexString:@"#707070"];
    [end_Label setText:@"请选择结束时间"];
    end_time_label_ = end_Label;
    
    [alert.view addSubview:end_btn];
    [alert.view addSubview:end_Label];
    
    UIAlertAction *commit_btn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"start date time : %@, end date time : %@", start_time_label_.text, end_time_label_.text);
        start_date_and_time = start_time_label_.text;
        end_date_and_time = end_time_label_.text;
        
        float palFrame = 0.5;
        timer = [NSTimer scheduledTimerWithTimeInterval:palFrame target:self selector:@selector(message_update) userInfo:nil repeats:YES];
        
        [[DHVideoDeviceHelper sharedInstance] FindVideoRecord:_deviceChannel withStartTime:start_date_and_time withEndTime:end_date_and_time];
    }];
    
    UIAlertAction *cancel_btn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"cancel to picker time");
    }];
    
    [alert addAction:commit_btn];
    [alert addAction:cancel_btn];
    
    [self presentViewController:alert animated:YES completion:^{ }];
}

- (void)datePickerValueChanged:(id)sender{
    UIDatePicker *datePicker = (UIDatePicker*)sender;
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    //实例化一个NSDateFormatter对象
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//设定时间格式
    NSString *dateString = [dateFormat stringFromDate:datePicker.date];
    //求出当天的时间字符串
    NSLog(@"Selected date and time : %@",dateString);
    
    
    if (start_time_label_ && selected_time_mode_ == 1) {
        [start_time_label_ setText:dateString];
    } else if (end_time_label_ && selected_time_mode_ == 2) {
        [end_time_label_ setText:dateString];
    }
}

- (void)startDateTimeSelected:(id)sender{
    [start_time_label_ setTextColor:[UIColor redColor]];
    [end_time_label_ setTextColor:[CWColorUtils colorWithHexString:@"#707070"]];
    selected_time_mode_ = 1;
}

- (void)endDateTimeSelected:(id)sender{
    [start_time_label_ setTextColor:[CWColorUtils colorWithHexString:@"#707070"]];
    [end_time_label_ setTextColor:[UIColor redColor]];
    selected_time_mode_ = 2;
}

@end
