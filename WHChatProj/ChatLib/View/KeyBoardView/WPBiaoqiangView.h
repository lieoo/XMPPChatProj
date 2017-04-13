//
//  WPBiaoqiangView.h
//  wxDemo
//
//  Created by 吴鹏 on 16/7/27.
//  Copyright © 2016年 wupeng. All rights reserved.
//

#import <UIKit/UIKit.h>

#define  WPBiaoQingWillShow @"WPBiaoQingWillShow"
#define  WPBiaoQingWillHidden @"WPBiaoQingWillHidden"
@class WPBiaoqiangView;

@protocol WPBiaoQingViewDelegate <NSObject>

- (void)WPbiaoQiongStr:(NSString *)str;

@end


@interface WPBiaoqiangView : UIView

- (id)initWithBiaoQingFrame:(CGRect)frame mainView:(UIView *)mainView;

@property (nonatomic , weak)id<WPBiaoQingViewDelegate>delegate;

@end
