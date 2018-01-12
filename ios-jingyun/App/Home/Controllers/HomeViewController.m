//
//  HomeViewController.m
//  ios-jingyun-test
//
//  Created by conwin on 2017/12/20.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import "HomeViewController.h"
#import "SDCycleScrollView.h"
#import "CWDataManager.h"
#import "CWThings4Interface.h"
#import "ThingsResponseDelegate.h"
#import "PrivilegeViewController.h"
#import "CWColorUtils.h"
#import "WebViewController.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "BigViewCell.h"
#import "MultiViewCell.h"
#import "LeftViewCell.h"
#import "RightViewCell.h"
#import "TextViewCell.h"

#define GET_SLIDE_INFO_URL @"/get_slideshow_info"
#define GET_SLIDE_VIEW_ID "getSlideInfoArray"
#define GET_NEWS_URL @"/get_news_info"
#define GET_NEWS_ID "getNewsArray"

#define HeaderSectionID @"headerSectionID"

#define CellIdentifierForImageBig @"CellIdentifierForImageBig"
#define CellIdentifierForImageLeft @"CellIdentifierForImageLeft"
#define CellIdentifierForImageRight @"CellIdentifierForImageRight"
#define CellIdentifierForImageMulti @"CellIdentifierForImageMulti"
#define CellIdentifierForText @"CellIdentifierForText"

@interface HomeViewController () <SDCycleScrollViewDelegate,ThingsResponseDelegate>

@end

@implementation HomeViewController{
    //轮播图
    SDCycleScrollView *slideView;
    //消息提醒文本
    UILabel* messageLabel;
    //表头
    UIView *headerView;
    
    //轮播图图片
    NSArray *slideImageArray;
    //轮播图数据数组
    NSMutableArray *slideInfoArray;
    //热门推荐数据
    NSMutableArray *newsArray;
    
    CGFloat screenHeight;
    CGFloat screenWidth;
    CGFloat childViewsY;
    
    MBProgressHUD *mbProgress;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    screenHeight = self.view.bounds.size.height;
    screenWidth = self.view.bounds.size.width;
    
    [[CWThings4Interface sharedInstance] setResponseDelegate:self];
    [self initTableView];
}

- (void) initTableView{
    //UITableViewStyleGrouped
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //分割线颜色
    self.tableView.separatorColor = [CWColorUtils colorWithHexString:@"#dbdbdb"];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    //大图
    [self.tableView registerClass:[BigViewCell class] forCellReuseIdentifier:CellIdentifierForImageBig];
    //左图
    [self.tableView registerClass:[LeftViewCell class] forCellReuseIdentifier:CellIdentifierForImageLeft];
    //右图
    [self.tableView registerClass:[RightViewCell class] forCellReuseIdentifier:CellIdentifierForImageRight];
    //多图
    [self.tableView registerClass:[MultiViewCell class] forCellReuseIdentifier:CellIdentifierForImageMulti];
    //多图
    [self.tableView registerClass:[TextViewCell class] forCellReuseIdentifier:CellIdentifierForText];
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, [self getHeaderHeight])];
    headerView.backgroundColor = [UIColor whiteColor];
    [self initSlideView];
    [self addMessageView];
    [self addTopView];
    [self addTipView];
    [self addMainView];
    [self addRecommendTip];
    self.tableView.tableHeaderView = headerView;
}

- (CGFloat) getHeaderHeight{
    CGFloat height = 0;
    height += screenWidth / 2;
    height += 40;
    height += screenWidth / 5;
    height += 30 + 4;
    height += screenWidth / 11 * 4 + 4;
    height += 40 + 8;
    
    NSLog(@" ---> headViewHeight: %f", height);
    return height + 0.5f;
}

- (void) viewWillAppear:(BOOL)animated{
    //加载轮播图数据
    [[CWThings4Interface sharedInstance] request:"." URL:[GET_SLIDE_INFO_URL UTF8String] UrlLen:(int)[GET_SLIDE_INFO_URL length]  ReqID:GET_SLIDE_VIEW_ID];
    //加载新闻数据
    [[CWThings4Interface sharedInstance] request:"." URL:[GET_NEWS_URL UTF8String] UrlLen:(int)[GET_NEWS_URL length]  ReqID:GET_NEWS_ID];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor whiteColor];
}

//add slideView
- (void) initSlideView{
    CGFloat height = screenWidth / 2;
    childViewsY += height;
    
    slideView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, screenWidth, height) delegate:self placeholderImage:[UIImage imageNamed:@"img_empty_conwin"]];
    slideView.currentPageDotImage = [UIImage imageNamed:@"pageControlCurrentDot"];
    slideView.pageDotImage = [UIImage imageNamed:@"pageControlDot"];
    slideView.imageURLStringsGroup = slideImageArray;
    [headerView addSubview:slideView];
}

- (void) addMessageView{
    CGFloat labelY = childViewsY;
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_home_message_tip"]];
    imageView.frame = CGRectMake(10, labelY, 20, 40);
    imageView.contentMode =  UIViewContentModeCenter;
    //    [imageView setContentScaleFactor:[[UIScreen mainScreen] scale]];
    //    imageView.contentMode =  UIViewContentModeScaleAspectFill;
    //    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    imageView.clipsToBounds  = YES;
    [headerView addSubview:imageView];
    
    messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(34, labelY, screenWidth - 34, 40)];
    messageLabel.textColor = [CWColorUtils colorWithHexString:@"#333333"];
    messageLabel.numberOfLines = 1;
    messageLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    messageLabel.text = @"系统很安全，暂无消息哦～";
    UITapGestureRecognizer *messageOnclickListener = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(messageOnclickListener)];
    [messageLabel addGestureRecognizer:messageOnclickListener];
    messageLabel.userInteractionEnabled = YES; // 可以理解为设置label可被点击
    [headerView addSubview:messageLabel];
    
    childViewsY += 40;
}

- (void) addTopView{
    CGFloat topY = childViewsY;
    CGFloat perWidth = (screenWidth - 40) / 3;
    CGFloat perHeight = screenWidth / 5;
    
    //-------- 111 ----------
    UIImage *policImage = [[UIImage alloc] init];
    policImage = [UIImage imageNamed:@"img_home_polic"];
    
    UIImageView *policView = [[UIImageView alloc] initWithFrame:CGRectMake(10, topY, perWidth, perHeight)];
    policView.image = policImage ;
    //添加边框
    CALayer * policLayer = [policView layer];
    policLayer.borderColor = [[CWColorUtils colorWithHexString:@"#dcdcdc"] CGColor];
    policLayer.borderWidth = 1.0f;
    UITapGestureRecognizer *policOnclickListener = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(policOnclickListener)];
    [policView addGestureRecognizer:policOnclickListener];
    policView.userInteractionEnabled = YES; // 可以理解为设置label可被点击
    
    UILabel *policLabel = [[UILabel alloc]init];
    policLabel.frame = CGRectMake(0, perHeight / 2 - 20 , perWidth, 30);
    policLabel.textAlignment = NSTextAlignmentCenter;
    policLabel.text = @"紧急求助";
    policLabel.font = [UIFont systemFontOfSize:17];
    
    UILabel *policSubLabel = [[UILabel alloc]init];
    policSubLabel.frame = CGRectMake(0, perHeight / 2 + 4, perWidth, 20);
    policSubLabel.textAlignment = NSTextAlignmentCenter;
    policSubLabel.text = @"点击快速报警";
    policSubLabel.textColor = [CWColorUtils colorWithHexString:@"#666666"];
    policSubLabel.font = [UIFont systemFontOfSize:13];
    
    [policView addSubview:policLabel];
    [policView addSubview:policSubLabel];
    [headerView addSubview:policView];
    
    //-------- 222 ----------
    UIImage *paymentImage = [[UIImage alloc] init];
    paymentImage = [UIImage imageNamed:@"img_home_payment"];
    
    UIImageView *paymentView = [[UIImageView alloc] initWithFrame:CGRectMake(perWidth + 20, topY, perWidth, perHeight)];
    paymentView.image = paymentImage ;
    //添加边框
    CALayer * paymentLayer = [paymentView layer];
    paymentLayer.borderColor = [[CWColorUtils colorWithHexString:@"#dcdcdc"] CGColor];
    paymentLayer.borderWidth = 1.0f;
    UITapGestureRecognizer *paymentOnclickListener = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(paymentOnclickListener)];
    [paymentView addGestureRecognizer:paymentOnclickListener];
    paymentView.userInteractionEnabled = YES; // 可以理解为设置label可被点击
    
    UILabel *paymentLabel = [[UILabel alloc]init];
    paymentLabel.frame = CGRectMake(0, perHeight / 2 - 20 , perWidth, 30);
    paymentLabel.textAlignment = NSTextAlignmentCenter;
    paymentLabel.text = @"缴费";
    paymentLabel.font = [UIFont systemFontOfSize:17];
    
    UILabel *paymentSubLabel = [[UILabel alloc]init];
    paymentSubLabel.frame = CGRectMake(0, perHeight / 2 + 4, perWidth, 20);
    paymentSubLabel.textAlignment = NSTextAlignmentCenter;
    paymentSubLabel.text = @"点击快捷缴费";
    paymentSubLabel.textColor = [CWColorUtils colorWithHexString:@"#666666"];
    paymentSubLabel.font = [UIFont systemFontOfSize:13];
    
    [paymentView addSubview:paymentLabel];
    [paymentView addSubview:paymentSubLabel];
    [headerView addSubview:paymentView];
    
    
    //-------- 333 ----------
    UIImage *privilegeImage = [[UIImage alloc] init];
    privilegeImage = [UIImage imageNamed:@"img_home_privilege"];
    
    UIImageView *privilegeView = [[UIImageView alloc] initWithFrame:CGRectMake(perWidth * 2 + 30, topY, perWidth, perHeight)];
    privilegeView.image = privilegeImage ;
    //添加边框
    CALayer * privilegeLayer = [privilegeView layer];
    privilegeLayer.borderColor = [[CWColorUtils colorWithHexString:@"#dcdcdc"] CGColor];
    privilegeLayer.borderWidth = 1.0f;
    UITapGestureRecognizer *privilegeOnclickListener = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(privilegeOnclickListener)];
    [privilegeView addGestureRecognizer:privilegeOnclickListener];
    privilegeView.userInteractionEnabled = YES; // 可以理解为设置label可被点击
    
    UILabel *privilegeLabel = [[UILabel alloc]init];
    privilegeLabel.frame = CGRectMake(0, perHeight / 2 - 20 , perWidth, 30);
    privilegeLabel.textAlignment = NSTextAlignmentCenter;
    privilegeLabel.text = @"热门优惠";
    privilegeLabel.font = [UIFont systemFontOfSize:17];
    
    UILabel *privilegeSubLabel = [[UILabel alloc]init];
    privilegeSubLabel.frame = CGRectMake(0, perHeight / 2 + 4, perWidth, 20);
    privilegeSubLabel.textAlignment = NSTextAlignmentCenter;
    privilegeSubLabel.text = @"查看优惠资讯";
    privilegeSubLabel.textColor = [CWColorUtils colorWithHexString:@"#666666"];
    privilegeSubLabel.font = [UIFont systemFontOfSize:13];
    
    [privilegeView addSubview:privilegeLabel];
    [privilegeView addSubview:privilegeSubLabel];
    [headerView addSubview:privilegeView];
    
    childViewsY += perHeight;
}

- (void) addTipView{
    //上下间距
    childViewsY += 4;
    CGFloat tipY = childViewsY;
    
    UILabel* tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, tipY, screenWidth - 10, 30)];
    tipLabel.textColor = [CWColorUtils colorWithHexString:@"#666666"];
    tipLabel.numberOfLines = 1;
    tipLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    tipLabel.text = @"快捷服务";
    [headerView addSubview:tipLabel];
    
    childViewsY += 30;
}

- (void) addMainView{
    CGFloat topY = childViewsY;
    CGFloat perWidth = (screenWidth - 30) / 2;
    CGFloat perHeight = screenWidth /11 * 2;
    
    //-------- 报警 ----------
    UIImage *alarmImage = [[UIImage alloc] init];
    alarmImage = [UIImage imageNamed:@"img_home_alarm"];
    
    UIImageView *alarmView = [[UIImageView alloc] initWithFrame:CGRectMake(10, topY, perWidth, perHeight)];
    alarmView.image = alarmImage ;
    UITapGestureRecognizer *alarmOnclickListener = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(alarmOnclickListener)];
    [alarmView addGestureRecognizer:alarmOnclickListener];
    alarmView.userInteractionEnabled = YES; // 可以理解为设置label可被点击
    
    UILabel *alarmLabel = [[UILabel alloc]init];
    alarmLabel.frame = CGRectMake(perWidth / 4, perHeight / 2 - 20 , perWidth / 4 * 3, 30);
    alarmLabel.text = @"报警";
    alarmLabel.textColor = [CWColorUtils colorWithHexString:@"#ffffffff"];
    alarmLabel.font = [UIFont systemFontOfSize:17];
    
    UILabel *alarmSubLabel = [[UILabel alloc]init];
    alarmSubLabel.frame = CGRectMake(perWidth / 4, perHeight / 2 , perWidth / 4 * 3, 26);
    alarmSubLabel.text = @"Alarm";
    alarmSubLabel.textColor = [CWColorUtils colorWithHexString:@"#ffffffff"];
    alarmSubLabel.font = [UIFont systemFontOfSize:14];
    
    [alarmView addSubview:alarmLabel];
    [alarmView addSubview:alarmSubLabel];
    [headerView addSubview:alarmView];
    
    //-------- 视频 ----------
    UIImage *videoImage = [[UIImage alloc] init];
    videoImage = [UIImage imageNamed:@"img_home_video"];
    
    UIImageView *videoView = [[UIImageView alloc] initWithFrame:CGRectMake(perWidth + 20, topY, perWidth, perHeight)];
    videoView.image = videoImage ;
    UITapGestureRecognizer *videoOnclickListener = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(videoOnclickListener)];
    [videoView addGestureRecognizer:videoOnclickListener];
    videoView.userInteractionEnabled = YES; // 可以理解为设置label可被点击
    
    UILabel *videoLabel = [[UILabel alloc]init];
    videoLabel.frame = CGRectMake(perWidth / 4, perHeight / 2 - 20 , perWidth / 4 * 3, 30);
    videoLabel.text = @"视频";
    videoLabel.textColor = [CWColorUtils colorWithHexString:@"#ffffffff"];
    videoLabel.font = [UIFont systemFontOfSize:17];
    
    UILabel *videoSubLabel = [[UILabel alloc]init];
    videoSubLabel.frame = CGRectMake(perWidth / 4, perHeight / 2 , perWidth / 4 * 3, 26);
    videoSubLabel.text = @"Video";
    videoSubLabel.textColor = [CWColorUtils colorWithHexString:@"#ffffffff"];
    videoSubLabel.font = [UIFont systemFontOfSize:14];
    
    [videoView addSubview:videoLabel];
    [videoView addSubview:videoSubLabel];
    [headerView addSubview:videoView];
    
    //-------- 智能家居 ----------
    UIImage *smartImage = [[UIImage alloc] init];
    smartImage = [UIImage imageNamed:@"img_home_smart"];
    
    UIImageView *smartView = [[UIImageView alloc] initWithFrame:CGRectMake(10, topY + perHeight + 4, perWidth, perHeight)];
    smartView.image = smartImage ;
    UITapGestureRecognizer *smartOnclickListener = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(smartOnclickListener)];
    [smartView addGestureRecognizer:smartOnclickListener];
    smartView.userInteractionEnabled = YES; // 可以理解为设置label可被点击
    
    UILabel *smartLabel = [[UILabel alloc]init];
    smartLabel.frame = CGRectMake(perWidth / 4, perHeight / 2 - 20 , perWidth / 4 * 3, 30);
    smartLabel.text = @"智能家居";
    smartLabel.textColor = [CWColorUtils colorWithHexString:@"#ffffffff"];
    smartLabel.font = [UIFont systemFontOfSize:17];
    
    UILabel *smartSubLabel = [[UILabel alloc]init];
    smartSubLabel.frame = CGRectMake(perWidth / 4, perHeight / 2 , perWidth / 4 * 3, 26);
    smartSubLabel.text = @"Smart Home";
    smartSubLabel.textColor = [CWColorUtils colorWithHexString:@"#ffffffff"];
    smartSubLabel.font = [UIFont systemFontOfSize:14];
    
    [smartView addSubview:smartLabel];
    [smartView addSubview:smartSubLabel];
    [headerView addSubview:smartView];
    
    //-------- 其他 ----------
    UIImage *otherImage = [[UIImage alloc] init];
    otherImage = [UIImage imageNamed:@"img_home_other"];
    
    UIImageView *otherView = [[UIImageView alloc] initWithFrame:CGRectMake(perWidth + 20, topY + perHeight + 4, perWidth, perHeight)];
    otherView.image = otherImage ;
    UITapGestureRecognizer *otherOnclickListener = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(otherOnclickListener)];
    [otherView addGestureRecognizer:otherOnclickListener];
    otherView.userInteractionEnabled = YES; // 可以理解为设置label可被点击
    
    UILabel *otherLabel = [[UILabel alloc]init];
    otherLabel.frame = CGRectMake(perWidth / 4, perHeight / 2 - 20 , perWidth / 4 * 3, 30);
    otherLabel.text = @"其他";
    otherLabel.textColor = [CWColorUtils colorWithHexString:@"#ffffffff"];
    otherLabel.font = [UIFont systemFontOfSize:17];
    
    UILabel *otherSubLabel = [[UILabel alloc]init];
    otherSubLabel.frame = CGRectMake(perWidth / 4, perHeight / 2 , perWidth / 4 * 3, 26);
    otherSubLabel.text = @"Others";
    otherSubLabel.textColor = [CWColorUtils colorWithHexString:@"#ffffffff"];
    otherSubLabel.font = [UIFont systemFontOfSize:14];
    
    [otherView addSubview:otherLabel];
    [otherView addSubview:otherSubLabel];
    [headerView addSubview:otherView];
    
    
    childViewsY += perHeight;
    childViewsY += perHeight + 4;
}

- (void) addRecommendTip{
    childViewsY += 8;
    CGFloat labelY = childViewsY;
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_home_recommend"]];
    imageView.frame = CGRectMake(10, labelY, 30, 30);
    imageView.clipsToBounds  = YES;
    [headerView addSubview:imageView];
    
    UILabel* tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, labelY, screenWidth - 50, 30)];
    tipLabel.textColor = [CWColorUtils colorWithHexString:@"#212121"];
    tipLabel.numberOfLines = 1;
    tipLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    tipLabel.text = @"热门推荐";
    [headerView addSubview:tipLabel];
    
    childViewsY += 40;
}

-(void) onThingsResponse:(const char*)inReqID status:(int)inStatus header:(char*) inHeader body:(char*)inBody{
    NSLog(@"onThingsResponse ---->  %s", inBody);
    //轮播图数据
    if (strcmp(inReqID, GET_SLIDE_VIEW_ID) == 0 && inStatus == 200) {
        NSString* body = [NSString stringWithUTF8String:inBody];
        NSData* jsonData = [body dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error;
        NSDictionary* root = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if (!root || error) {
            NSLog(@"HomeViewController ---> 轮播图数据结构有误，解析失败");
            return;
        }
        
        NSDictionary *slideData = [root objectForKey:@"slideshow_dataset"];
        slideInfoArray  = [NSMutableArray arrayWithCapacity:slideData.count];
        NSMutableArray* imageArray  = [NSMutableArray arrayWithCapacity:slideData.count];
        
        for (NSString *key in slideData) {
            NSLog(@"key: %@ value: %@", key, slideData[key]);
            [slideInfoArray addObject:slideData[key]];
            [imageArray addObject:[slideData[key] objectForKey:@"image"]];
        }
        
        slideImageArray = [imageArray copy];
        slideView.imageURLStringsGroup = slideImageArray;
        
    }else if(strcmp(inReqID, GET_NEWS_ID) == 0 && inStatus == 200){
        //new data
        NSString* body = [NSString stringWithUTF8String:inBody];
        NSData* jsonData = [body dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error;
        NSDictionary* root = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if (!root || error) {
            NSLog(@"HomeViewController ---> 新闻数据结构有误，解析失败");
            return;
        }
        
        NSDictionary *newsData = [root objectForKey:@"news_dataset"];
        newsArray  = [NSMutableArray arrayWithCapacity:newsData.count];
        
        for (NSString *key in newsData) {
            NSLog(@"key: %@ value: %@", key, newsData[key]);
            [newsArray addObject:newsData[key]];
        }
        
        [self.tableView reloadData];
    }
    
}

#pragma mark - SDCycleScrollViewDelegate
//轮播图点击事件
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    NSLog(@"---点击了第%ld张图片", (long)index);
    
    NSDictionary* slideInfo = [slideInfoArray objectAtIndex:index];
    NSString* linkUrl = slideInfo[@"url"];
    
    if (linkUrl != nil && linkUrl.length > 0) {
        WebViewController *webController = [[WebViewController alloc] init];
        webController.url = slideInfo[@"url"];
        UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:webController];
        [self presentViewController:navigationController animated:TRUE completion:nil];
    }

}

#pragma mark --UITableViewDataSource 协议方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [newsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger index = [indexPath row];
    NSDictionary* news = [newsArray objectAtIndex:index];
    NSString* type = [news objectForKey:@"type"];
    
    if ([type isEqualToString:@"1"]) {
         //big image
        BigViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierForImageBig forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[BigViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierForImageBig];
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        NSString *title = news[@"title"];
        cell.titleLabel.text = title;
        
        NSString *source = [NSString stringWithFormat:@"%@  %@", news[@"source"], news[@"time"]];
        cell.sourceLabel.text = source;
        
        NSURL *imageUrl = news[@"image1"];
        [cell.imageOne sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"img_empty_conwin"]];
        
        return cell;
 
    }else if ([type isEqualToString:@"2"]) {
        //left image
        LeftViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierForImageLeft forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[LeftViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierForImageLeft];
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *title = news[@"title"];
        cell.titleLabel.text = title;
        
        NSString *source = [NSString stringWithFormat:@"%@\n%@", news[@"time"], news[@"source"]];
        cell.sourceLabel.text = source;
        
        NSURL *imageUrl = news[@"image1"];
        [cell.imageOne sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"img_empty_conwin"]];
        
        return cell;
        
    }else if ([type isEqualToString:@"3"]) {
        //left image
        RightViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierForImageRight forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[RightViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierForImageRight];
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *title = news[@"title"];
        cell.titleLabel.text = title;
        
        NSString *source = [NSString stringWithFormat:@"%@\n%@", news[@"time"], news[@"source"]];
        cell.sourceLabel.text = source;
        
        NSURL *imageUrl = news[@"image1"];
        [cell.imageOne sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"img_empty_conwin"]];
        
        return cell;
        
    }else if([type isEqualToString:@"4"]){
        MultiViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierForImageMulti forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[MultiViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierForImageMulti];
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *title = news[@"title"];
        cell.titleLabel.text = title;
        
        NSString *source = [NSString stringWithFormat:@"%@  %@", news[@"source"], news[@"time"]];
        cell.sourceLabel.text = source;
        
        NSURL *imageUrlOne = news[@"image1"];
        if (imageUrlOne != nil) {
            [cell.imageOne sd_setImageWithURL:imageUrlOne placeholderImage:[UIImage imageNamed:@"img_empty_conwin"]];
        }
        
        NSURL *imageUrlTwo = news[@"image2"];
        if (imageUrlTwo != nil) {
            [cell.imageTwo sd_setImageWithURL:imageUrlTwo placeholderImage:[UIImage imageNamed:@"img_empty_conwin"]];
        }
        
        NSURL *imageUrlThree = news[@"image3"];
        if (imageUrlThree != nil) {
            [cell.imageThree sd_setImageWithURL:imageUrlThree placeholderImage:[UIImage imageNamed:@"img_empty_conwin"]];
        }
        
        return cell;
        
    }else{
        //text and other
        TextViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierForText forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[TextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierForText];
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *title = news[@"title"];
        cell.titleLabel.text = title;
        
        NSString *content = [NSString stringWithFormat:@"%@", news[@"content"]];
        cell.contentLabel.text = content;
        
        NSString *source = [NSString stringWithFormat:@"%@  %@", news[@"source"], news[@"time"]];
        cell.sourceLabel.text = source;
        
        return cell;
    }
    
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger index = [indexPath row];
    NSDictionary* news = [newsArray objectAtIndex:index];
    NSString* type = [news objectForKey:@"type"];
    
    if ([type isEqualToString:@"1"]) {
        return [BigViewCell getCellHeight];
    }else if([type isEqualToString:@"2"]){
        return [LeftViewCell getCellHeight];
    }else if([type isEqualToString:@"3"]){
        return [RightViewCell getCellHeight];
    }else if([type isEqualToString:@"4"]){
        return [MultiViewCell getCellHeight];
    }else{
        return [TextViewCell getCellHeight];
    }
    return 180;
}


// like item click listener
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"click item is %li", indexPath.row);
    
    NSUInteger index = [indexPath row];
    NSDictionary* news = [newsArray objectAtIndex:index];
    
    WebViewController *webController = [[WebViewController alloc] init];
    webController.url = news[@"url"];
    webController.contentTitle = news[@"title"];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:webController];
    [self presentViewController:navigationController animated:TRUE completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) messageOnclickListener{
    NSLog(@"消息");
}

- (void) policOnclickListener{
    NSLog(@"紧急求助");
}

- (void) paymentOnclickListener{
    NSLog(@"缴费");
    [self showToast];
}

- (void) privilegeOnclickListener{
    NSLog(@"热门优惠");
    PrivilegeViewController *controller = [[PrivilegeViewController alloc] init];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navigationController animated:TRUE completion:nil];
}

- (void) alarmOnclickListener{
    NSLog(@"报警");
    [self.tabBarController setSelectedIndex:1];
}

- (void) videoOnclickListener{
    NSLog(@"视频");
    [self.tabBarController setSelectedIndex:1];
}

- (void) smartOnclickListener{
    NSLog(@"智能家居");
    [self showToast];
}

- (void) otherOnclickListener{
    NSLog(@"其他");
    [self showToast];
}

/*
 * MBProgressHUD *mbProgress;
 * [mbProgress hide:YES];
 */
- (void) showToast {
    mbProgress = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:mbProgress];
    mbProgress.color = [CWColorUtils colorWithHexString:@"#00c7c7" alpha:0.8f];
    mbProgress.labelText = @"该功能即将推出，敬请期待！";
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

