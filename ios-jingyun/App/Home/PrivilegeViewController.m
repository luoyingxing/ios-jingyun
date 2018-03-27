//
//  PrivilegeViewController.m
//  ios-jingyun
//
//  Created by conwin on 2017/12/26.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import "PrivilegeViewController.h"
#import "CWColorUtils.h"
#import "ThingsResponseDelegate.h"
#import "CWThings4Interface.h"
#import "WebViewController.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "BigViewCell.h"
#import "MultiViewCell.h"
#import "LeftViewCell.h"
#import "RightViewCell.h"
#import "TextViewCell.h"

#define GET_NEWS_URL @"/get_news_info"
#define GET_NEWS_ID "getNewsArray"

#define CellIdentifierForImageBig @"CellIdentifierForImageBig"
#define CellIdentifierForImageLeft @"CellIdentifierForImageLeft"
#define CellIdentifierForImageRight @"CellIdentifierForImageRight"
#define CellIdentifierForImageMulti @"CellIdentifierForImageMulti"
#define CellIdentifierForText @"CellIdentifierForText"

@interface PrivilegeViewController () <ThingsResponseDelegate>

@end

@implementation PrivilegeViewController{
    MBProgressHUD *mbProgress;
    
    //热门推荐数据
    NSMutableArray *newsArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[CWThings4Interface sharedInstance] setResponseDelegate:self];
    
    [self setNavigationBar];
    [self initTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//setting bar property
- (void) setNavigationBar{
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    [self setNeedsStatusBarAppearanceUpdate];
     self.navigationItem.title = @"热门优惠";
    [self.navigationController.navigationBar setBarTintColor:[CWColorUtils getThemeColor]];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithImage:[UIImage imageNamed:@"icon_back_white"]
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(goBack:)];
    backButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void) initTableView{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
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
    
}

- (void) goBack:(UIBarButtonItem*) button{
    [self dismissViewControllerAnimated:TRUE completion:^{
        NSLog(@"back to HOME");
    }];
}

- (void) viewWillAppear:(BOOL)animated{
    [self showProgress];
    //加载新闻数据
    [[CWThings4Interface sharedInstance] request:"." URL:[GET_NEWS_URL UTF8String] UrlLen:(int)[GET_NEWS_URL length]  ReqID:GET_NEWS_ID];
}

-(void) onThingsResponse:(const char*)inReqID status:(int)inStatus header:(char*) inHeader body:(char*)inBody{
    NSLog(@"onThingsResponse ---->  %s", inBody);
    //轮播图数据
    if(strcmp(inReqID, GET_NEWS_ID) == 0 && inStatus == 200){
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
        
        [mbProgress hide:YES];
        [self.tableView reloadData];
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
        
        NSString* image1 = news[@"image1"];
        if (image1 != nil && ![image1 isEqualToString:@""]) {
            NSURL *imageUrlOne = [[NSURL alloc] initWithString:image1];
            [cell.imageOne sd_setImageWithURL:imageUrlOne placeholderImage:[UIImage imageNamed:@"img_empty_conwin"]];
        }
        
        NSString* image2 = news[@"image2"];
        if (image2 != nil && ![image2 isEqualToString:@""]) {
            NSURL *imageUrlTwo = [[NSURL alloc] initWithString:image2];
            [cell.imageTwo sd_setImageWithURL:imageUrlTwo placeholderImage:[UIImage imageNamed:@"img_empty_conwin"]];
        }
        
        NSString* image3 = news[@"image3"];
        if (image3 != nil && ![image3 isEqualToString:@""]) {
            NSURL *imageUrlThree = [[NSURL alloc] initWithString:image3];
            if (imageUrlThree != nil) {
                [cell.imageThree sd_setImageWithURL:imageUrlThree placeholderImage:[UIImage imageNamed:@"img_empty_conwin"]];
            }
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
    [navigationController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:navigationController animated:TRUE completion:nil];
}

/*
 * MBProgressHUD *mbProgress;
 * [mbProgress hide:YES];
 */
- (void) showProgress {
    mbProgress = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    mbProgress.color = [CWColorUtils getThemeColor];
    mbProgress.labelText = @"加载中...";
}

@end
