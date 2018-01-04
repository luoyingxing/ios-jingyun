//
//  AccountBackgroundView.h
//  ios-jingyun-test
//
//  Created by conwin on 2017/12/13.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE  // 动态刷新

@interface AccountBackgroundView : UIView

// 注意: 加上IBInspectable就可以可视化显示相关的属性哦
/** 可视化设置边框宽度 */
@property (nonatomic, assign)IBInspectable CGFloat borderWidth;
/** 可视化设置边框颜色 */
@property (nonatomic, strong)IBInspectable UIColor *borderColor;

/** 可视化设置圆角 */
@property (nonatomic, assign)IBInspectable CGFloat cornerRadius;

@end
