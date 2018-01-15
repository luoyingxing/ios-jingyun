//
//  FilterAlertView.m
//  ios-jingyun
//
//  Created by conwin on 2018/1/12.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import "AlarmReportAlertView.h"
#import "CWColorUtils.h"

#define Space 10

@interface AlarmReportAlertView()

@property (nonatomic,retain) UIView *alertView;

@property (nonatomic,retain) UIView *topView;

@property (nonatomic,retain) UIImageView *policeImageView;

@property (nonatomic,retain) UIButton *alarmButton;

@property (nonatomic,retain) UIButton *detailButton;

@property (nonatomic,retain) UIView *lineView;

@property (nonatomic,retain) UIView *verLineView;

@property (nonatomic,assign) CGFloat screenWidth;

@property (nonatomic,assign) CGFloat alertViewWidth;

@property (nonatomic,assign) CGFloat alertViewHeight;

@end

@implementation AlarmReportAlertView

- (instancetype) initWithDefaultStyle{
    if (self == [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        self.screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        self.alertViewWidth = 280;
        self.alertViewHeight = 180;
        
        self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.6];
        
        self.alertView = [[UIView alloc] init];
        self.alertView.backgroundColor = [UIColor whiteColor];
        self.alertView.layer.cornerRadius = 2.0;

        self.alertView.frame = CGRectMake(0, 0, self.alertViewWidth, self.alertViewHeight);
        self.alertView.layer.position = self.center;
        
        self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.alertViewWidth, 34)];
        self.topView.backgroundColor = [CWColorUtils getThemeColor];
        [self.alertView addSubview:self.topView];
        
        //img_home_alarm_dialog
            
        self.policeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.alertViewWidth / 2 - 30, 10 , 60, 120)];
        UIImage* policeImage = [UIImage imageNamed:@"img_home_alarm_dialog.png"];
        self.policeImageView.image = policeImage;
        self.policeImageView.contentMode =  UIViewContentModeScaleToFill;
        [self.alertView addSubview:self.policeImageView];
        
        self.lineView = [[UIView alloc] init];
        self.lineView.frame = CGRectMake(0, self.alertViewHeight - 40, self.alertViewWidth, 1);
        self.lineView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.6];
        [self.alertView addSubview:self.lineView];
        
        //两个按钮
        self.alarmButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.alarmButton.frame = CGRectMake(0, CGRectGetMaxY(self.lineView.frame), (self.alertViewWidth) / 2, 40);
        [self.alarmButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.2]] forState:UIControlStateNormal];
        [self.alarmButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.2]] forState:UIControlStateSelected];
        [self.alarmButton setTitle:@"紧急求助" forState:UIControlStateNormal];
        [self.alarmButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        self.alarmButton.tag = 0;
        [self.alarmButton addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.alarmButton.bounds byRoundingCorners:UIRectCornerBottomLeft cornerRadii:CGSizeMake(5.0, 5.0)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.alarmButton.bounds;
        maskLayer.path = maskPath.CGPath;
        self.alarmButton.layer.mask = maskLayer;
        [self.alertView addSubview:self.alarmButton];

        self.verLineView = [[UIView alloc] init];
        self.verLineView.frame = CGRectMake(CGRectGetMaxX(self.alarmButton.frame), CGRectGetMaxY(self.lineView.frame), 1, 40);
        self.verLineView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.6];
        [self.alertView addSubview:self.verLineView];
        
            
        self.detailButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.detailButton.frame = CGRectMake(CGRectGetMaxX(self.verLineView.frame), CGRectGetMaxY(self.lineView.frame), (self.alertViewWidth) / 2, 40);
        [self.detailButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.2]] forState:UIControlStateNormal];
        [self.detailButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.2]] forState:UIControlStateSelected];
        [self.detailButton setTitle:@"上报详情" forState:UIControlStateNormal];
        [self.detailButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.detailButton.tag = 1;
        [self.detailButton addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
        UIBezierPath *detailPath = [UIBezierPath bezierPathWithRoundedRect:self.detailButton.bounds byRoundingCorners:UIRectCornerBottomRight cornerRadii:CGSizeMake(5.0, 5.0)];
        CAShapeLayer *detailLayer = [[CAShapeLayer alloc] init];
        detailLayer.frame = self.detailButton.bounds;
        detailLayer.path = detailPath.CGPath;
        self.detailButton.layer.mask = detailLayer;
        [self.alertView addSubview:self.detailButton];

        [self addSubview:self.alertView];
    }
    
    return self;
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

#pragma mark - 回调
- (void)buttonEvent:(UIButton *)sender{
    if (self.resultIndex) {
        self.resultIndex(sender.tag);
    }
    [self removeFromSuperview];
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

-(UIImage *)imageWithColor:(UIColor *)color{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    // 计算搜索框范围
    CGPoint touchPoint = [touch locationInView:self.alertView];
    
    NSLog(@"x = %f, y = %f", touchPoint.x, touchPoint.y);
    if (touchPoint.x < 0 || touchPoint.x > self.alertViewWidth || touchPoint.y < 0 || touchPoint.y > self.alertViewHeight) {
        [self removeFromSuperview];
    }
}

@end
