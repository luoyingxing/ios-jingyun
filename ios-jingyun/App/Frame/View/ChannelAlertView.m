//
//  ChannelAlertView.m
//  ios-jingyun
//
//  Created by conwin on 2018/2/26.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import "ChannelAlertView.h"

#define Line_Height 45

#define CellIdentifier @"CellIdentifier"

@interface ChannelAlertView()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,retain) UIView *alertView;

@property (nonatomic,retain) UITableView *tableView;

@property (nonatomic,assign) CGFloat screenWidth;

@property (nonatomic,assign) CGFloat alertViewWidth;

@property (nonatomic,assign) CGFloat alertViewHeight;

@property (nonatomic,assign) NSMutableArray* channelArray;

@end

@implementation ChannelAlertView

- (instancetype) initWithDefaultStyle:(NSMutableArray*) array{
    if (self == [super init]) {
        self.channelArray = array;
        
        self.frame = [UIScreen mainScreen].bounds;
        self.screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        self.alertViewWidth = 280;
        self.alertViewHeight = array.count * Line_Height;
        
        self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.6];
        
        self.alertView = [[UIView alloc] init];
        self.alertView.backgroundColor = [UIColor whiteColor];
        self.alertView.layer.cornerRadius = 2.0;
        
        self.alertView.frame = CGRectMake(0, 0, self.alertViewWidth, self.alertViewHeight);
        self.alertView.layer.position = self.center;
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.alertViewWidth, self.alertViewHeight) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorColor = [UIColor whiteColor];
        [self.alertView addSubview:self.tableView];
        
        
        [self addSubview:self.alertView];
        
        //update
        [self.tableView reloadData];
    }
    
    return self;
}

#pragma mark -
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.channelArray.count;
}

#pragma mark -
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    NSString* name = [self.channelArray objectAtIndex:row];
    
    name = [name stringByReplacingOccurrencesOfString:@"*.ch" withString:@"通道"];
    name = [name stringByReplacingOccurrencesOfString:@".ch" withString:@"通道"];
    
    cell.textLabel.text = name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"click item %li", indexPath.row);
    
    if (self.resultIndex) {
        self.resultIndex([_channelArray objectAtIndex:indexPath.row], indexPath.row);
    }
    
    [self removeFromSuperview];
}

#pragma mark - 弹出 -
- (void) show{
    UIWindow *rootWindow = [UIApplication sharedApplication].keyWindow;
    [rootWindow addSubview:self];
    [self creatShowAnimation];
}

- (void)creatShowAnimation{
    self.alertView.layer.position = self.center;
    self.alertView.transform = CGAffineTransformMakeScale(0.90, 0.90);
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
        self.alertView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
    }];
}

-(UILabel *)GetAdaptiveLable:(CGRect)rect AndText:(NSString *)contentStr andIsTitle:(BOOL)isTitle{
    UILabel *contentLbl = [[UILabel alloc] initWithFrame:rect];
    contentLbl.numberOfLines = 0;
    contentLbl.text = contentStr;
    contentLbl.textAlignment = NSTextAlignmentCenter;
    if (isTitle) {
        contentLbl.font = [UIFont boldSystemFontOfSize:16.0];
    }else{
        contentLbl.font = [UIFont systemFontOfSize:14.0];
    }
    
    NSMutableAttributedString *mAttrStr = [[NSMutableAttributedString alloc] initWithString:contentStr];
    NSMutableParagraphStyle *mParaStyle = [[NSMutableParagraphStyle alloc] init];
    mParaStyle.lineBreakMode = NSLineBreakByCharWrapping;
    [mParaStyle setLineSpacing:3.0];
    [mAttrStr addAttribute:NSParagraphStyleAttributeName value:mParaStyle range:NSMakeRange(0,[contentStr length])];
    [contentLbl setAttributedText:mAttrStr];
    [contentLbl sizeToFit];
    
    return contentLbl;
}

/**
 * 点击外部消失
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.alertView];
    if (touchPoint.x < 0 || touchPoint.x > self.alertViewWidth || touchPoint.y < 0 || touchPoint.y > self.alertViewHeight) {
        [self removeFromSuperview];
    }
}

@end
