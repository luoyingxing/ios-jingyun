//
//  ColumnToolBar.m
//  ColumnToolBar
//
//  Created by yeung on 5/10/16.
//  Copyright © 2016 yeung. All rights reserved.
//

#import "ColumnToolBar.h"
#import "UIView+SDAutoLayout.h"

@interface ColumnToolBar ()

@property (nonatomic, strong) ColumnToolBarSetting *setting;
@property (nonatomic, strong) NSMutableArray *buttonArr;
@property (nonatomic, strong) NSMutableArray *bottomLineArr;
@property (nonatomic, weak) UIButton *selectedButton;
//@property (nonatomic, weak) UIView *lineView;

@end

@implementation ColumnToolBar

- (NSMutableArray *)buttonArr
{
    if (!_buttonArr) {
        _buttonArr = [NSMutableArray array];
    }
    return _buttonArr;
}

- (NSMutableArray *)bottomLineArr
{
    if (!_bottomLineArr) {
        _bottomLineArr = [NSMutableArray array];
    }
    return _bottomLineArr;
}


+ (instancetype)columnToolBarWithSetting:(ColumnToolBarSetting *)setting
{
    return [[self alloc] initWithSetting:setting];
}

- (instancetype)initWithSetting:(ColumnToolBarSetting *)setting
{
    self = [super init];
    if (self) {
        _setting = setting;
        // 设置背景颜色
        self.backgroundColor = [UIColor clearColor];
        
        // 创建按钮
        NSUInteger titlesCount = setting.titlesArr.count;
        NSMutableArray *_tool_view_array = [NSMutableArray new];
        //CGFloat titlesWidth = setting.frame.size.width / titlesCount;
        //CGFloat titlesHeight = setting.frame.size.height;
        for (int i = 0; i < titlesCount; ++i) {
            UIView *view = [UIView new];
            view.backgroundColor = [UIColor clearColor];
            [self addSubview:view];
 
            // type 修改为 UIButtonTypeCustom 则没有高亮时的变化
            {
                UIButton *titlesButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [self.buttonArr addObject:titlesButton];
                
                // 普通状态
                NSDictionary *attDict = @{
                                          NSFontAttributeName : [UIFont systemFontOfSize:setting.textFontSize],
                                          NSForegroundColorAttributeName : setting.textColor,
                                          };
                NSAttributedString *attStr =
                [[NSAttributedString alloc] initWithString:setting.titlesArr[i] attributes:attDict];
                
                // 选中状态
                NSDictionary *selectedAttDict = @{
                                                  NSFontAttributeName : [UIFont systemFontOfSize:setting.textFontSize],
                                                  NSForegroundColorAttributeName : setting.selectedTextColor,
                                                  };
                NSAttributedString *selectedAttStr =
                [[NSAttributedString alloc] initWithString:setting.selectedTitlesArr[i] attributes:selectedAttDict];
                
                [titlesButton setAttributedTitle:attStr forState:UIControlStateNormal];
                [titlesButton setAttributedTitle:selectedAttStr forState:UIControlStateSelected];
    
                //titlesButton.titleLabel.backgroundColor = [UIColor lightGrayColor];
                titlesButton.titleLabel.textAlignment = NSTextAlignmentCenter;
                
                //image
                if (setting.imagesArr && [setting.imagesArr count]) {
                    
                    [titlesButton setImage:[UIImage imageNamed:setting.imagesArr[i]] forState:UIControlStateNormal];
                
                    if (setting.selectedImagesArr && [setting.imagesArr count]) {
                        [titlesButton setImage:[UIImage imageNamed:setting.selectedImagesArr[i]] forState:UIControlStateSelected];
                    }
                    
                    titlesButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
                }
                
                //[titlesButton setBackgroundColor:[UIColor yellowColor]];
                if (setting.buttonDisable == NO) {
                    [titlesButton addTarget:self
                                     action:@selector(titlesBtnClick:)
                           forControlEvents:UIControlEventTouchUpInside];
                }
                
                [view addSubview:titlesButton];
                
                
                titlesButton.sd_layout
                .leftSpaceToView(view, 2)
                .rightSpaceToView(view, 2)
                .bottomSpaceToView(view, 2)
                .topSpaceToView(view, 2);
                
                
                if (setting.imagesArr||setting.selectedImagesArr) {
                    // 设置button的图片的约束
                    titlesButton.imageView.sd_layout
                    .widthRatioToView(titlesButton, 0.8)
                    .topSpaceToView(titlesButton, 2)
                    .centerXEqualToView(titlesButton)
                    .heightRatioToView(titlesButton, 0.6);
                    
                    // 设置button的label的约束
                    titlesButton.titleLabel.sd_layout
                    .topSpaceToView(titlesButton.imageView, 2)
                    .leftEqualToView(titlesButton.imageView)
                    .rightEqualToView(titlesButton.imageView)
                    .bottomSpaceToView(titlesButton, 2);
                }
                //else {
                if (setting.middleHidden == NO)
                    if (i < (titlesCount - 1)) {
                        UIView *rightLine = [[UIView alloc] init];
                        rightLine.backgroundColor = [UIColor colorWithRed:184/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f];
                        [view addSubview:rightLine];
                        
                        rightLine.sd_layout
                        .rightSpaceToView(view, 1)
                        .topSpaceToView(view, 10)
                        .bottomSpaceToView(view, 10)
                        .widthIs(1);
                    }
                    
                    if (setting.lineHidden == NO) {
                        UIView *bottomLine = [[UIView alloc] init];
                        bottomLine.backgroundColor = setting.lineColor;
                        [view addSubview:bottomLine];
                        bottomLine.hidden = YES;
                        
                        bottomLine.sd_layout
                        .leftSpaceToView(view, 8)
                        .rightSpaceToView(view, 8)
                        .bottomSpaceToView(view, 0)
                        .heightIs(2);
                        
                        [self.bottomLineArr addObject:bottomLine];
                    }
                //}
                
                
                
                
                if (i == 0) {
                    [self titlesBtnClick:titlesButton];
                }
            }
            
            //view.sd_layout.autoHeightRatio(0.9);
            view.sd_layout.heightRatioToView(self, 0.99);
            [_tool_view_array addObject:view];
            
        }
        
        [self setupAutoWidthFlowItems:[_tool_view_array copy] withPerRowItemsCount:[_tool_view_array count] verticalMargin:0 horizontalMargin:1];
    }
    
    if (setting.topHidden == NO) {
        UIImageView *topLine = [[UIImageView alloc] init];
        //[topLine setBackgroundColor:[UIColor redColor]];
        topLine.backgroundColor = [UIColor colorWithRed:184/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f];
        [self addSubview:topLine];
        
        topLine.sd_layout
        .leftSpaceToView(self, 0)
        .rightSpaceToView(self, 0)
        .topSpaceToView(self, 0)
        .heightIs(1);
    }
    return self;
}

- (void)selectButtonAtIndex:(NSUInteger)index withClick:(BOOL)isClicked
{
    if (index < self.buttonArr.count) {
        if (isClicked) {
            [self titlesBtnClick:self.buttonArr[index]];
        }
        else {
            BOOL btnStatus = [self.buttonArr[index] isSelected];
            [self.buttonArr[index] setSelected:!btnStatus];
        }
    }
}

- (void) appendTitleAtIndex:(NSUInteger)index withTitle:(NSString*)caption
{
    NSDictionary *attDict = @{
                              NSFontAttributeName : [UIFont systemFontOfSize:_setting.textFontSize],
                              NSForegroundColorAttributeName : _setting.textColor,
                              };
    NSDictionary *selectedAttDict = @{
                                      NSFontAttributeName : [UIFont systemFontOfSize:_setting.textFontSize],
                                      NSForegroundColorAttributeName : _setting.selectedTextColor,
                                      };
    
    NSString *strCaption = _setting.titlesArr[index];
    for (int i = 0; i < [self.buttonArr count]; i++) {
        UIButton *button = self.buttonArr[i];
        if (button) {
            if (i == index) {
                strCaption = [strCaption stringByAppendingString:caption];
                NSAttributedString *currentStr =
                [[NSAttributedString alloc] initWithString:strCaption attributes:selectedAttDict];
                [button setAttributedTitle:currentStr forState:UIControlStateNormal];
            }
            else {
                NSAttributedString *currentStr =
                [[NSAttributedString alloc] initWithString:_setting.titlesArr[i] attributes:attDict];
                [button setAttributedTitle:currentStr forState:UIControlStateNormal];
            }
        }
    }
}

- (void) setTitleAtIndex:(NSUInteger)index withTitle:(NSString*)caption
{
    NSDictionary *attDict = @{
                              NSFontAttributeName : [UIFont systemFontOfSize:_setting.textFontSize],
                              NSForegroundColorAttributeName : _setting.textColor,
                              };
    NSDictionary *selectedAttDict = @{
                                      NSFontAttributeName : [UIFont systemFontOfSize:_setting.textFontSize],
                                      NSForegroundColorAttributeName : _setting.selectedTextColor,
                                      };
    UIButton *button = self.buttonArr[index];
    NSAttributedString *currentStr =
    [[NSAttributedString alloc] initWithString:caption attributes:selectedAttDict];
    if (button.isSelected) {
        [button setAttributedTitle:currentStr forState:UIControlStateSelected];
    }
    else {
        [button setAttributedTitle:currentStr forState:UIControlStateNormal];
    }
    
}

- (void)titlesBtnClick:(UIButton *)button
{
    {
        // 已点击按钮
        NSAttributedString *currentStr = [self.selectedButton attributedTitleForState:UIControlStateNormal];
        NSAttributedString *toChangeStr = [self.selectedButton attributedTitleForState:UIControlStateSelected];
        
        [self.selectedButton setAttributedTitle:toChangeStr forState:UIControlStateNormal];
        [self.selectedButton setAttributedTitle:currentStr forState:UIControlStateSelected];
    }
    
    {
        // 点击按钮
        NSAttributedString *currentStr = [button attributedTitleForState:UIControlStateNormal];
        NSAttributedString *toChangeStr = [button attributedTitleForState:UIControlStateSelected];
        
        [button setAttributedTitle:toChangeStr forState:UIControlStateNormal];
        [button setAttributedTitle:currentStr forState:UIControlStateSelected];
    }

    
    // 保存当前点击按钮
    self.selectedButton = button;
    
    // 执行代理
    NSUInteger index = 0;
    for (int i = 0; i < self.buttonArr.count; ++i) {
        UIView *bottomLine = nil;
        if (_setting.lineHidden == NO) {
            if (_bottomLineArr && [_bottomLineArr count] == [self.buttonArr count]) {
                bottomLine = (UIView*) [_bottomLineArr objectAtIndex:i];
            }
        }
        
        if ([button isEqual:self.buttonArr[i]]) {
            index = i;
            if (bottomLine) {
                bottomLine.hidden = NO;
            }
        }
        else {
            if (bottomLine) {
                bottomLine.hidden = YES;
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(columnToolBar:didSelectButton:atIndex:)]) {
        [self.delegate columnToolBar:self didSelectButton:button atIndex:index];
    }
}

@end

@implementation ColumnToolBarSetting

// 懒加载默认样式
- (NSArray *)selectedTitlesArr
{
    if (!_selectedTitlesArr) {
        _selectedTitlesArr = self.titlesArr;
    }
    return _selectedTitlesArr;
}

- (UIColor *)backgroundColor
{
    if (!_backgroundColor) {
        _backgroundColor = [UIColor whiteColor];
    }
    return _backgroundColor;
}

- (UIColor *)textColor
{
    if (!_textColor) {
        _textColor = [UIColor blackColor];
    }
    return _textColor;
}

- (UIColor *)selectedTextColor
{
    if (!_selectedTextColor) {
        _selectedTextColor = [UIColor orangeColor];
    }
    return _selectedTextColor;
}

- (CGFloat)textFontSize
{
    if (!_textFontSize) {
        _textFontSize = [UIFont systemFontSize];
    }
    return _textFontSize;
}

- (CGFloat)selectedTextFontSize
{
    if (!_selectedTextFontSize) {
        _selectedTextFontSize = self.textFontSize;
    }
    return _selectedTextFontSize;
}

- (BOOL) buttonDisable
{
    if (!_buttonDisable) {
        _buttonDisable = NO;
    }
    return _buttonDisable;
}

- (BOOL) topHidden
{
    if (!_topHidden) {
        _topHidden = NO;
    }
    return _topHidden;
}

- (BOOL) middleHidden
{
    if (!_middleHidden) {
        _middleHidden = NO;
    }
    return _middleHidden;
}

- (BOOL)lineHidden
{
    if (!_lineHidden) {
        _lineHidden = NO;
    }
    return _lineHidden;
}

- (CGFloat)lineHeight
{
    if (!_lineHeight) {
        _lineHeight = 1;
    }
    return _lineHeight;
}

- (UIColor *)lineColor
{
    if (!_lineColor) {
        _lineColor = self.selectedTextColor;
    }
    return _lineColor;
}

- (CGFloat)lineBottomSpace
{
    if (!_lineBottomSpace) {
        _lineBottomSpace = 1;
    }
    return _lineBottomSpace;
}

- (NSTimeInterval)animateDuration
{
    if (!_animateDuration) {
        _animateDuration = 0.5;
    }
    return _animateDuration;
}

@end
