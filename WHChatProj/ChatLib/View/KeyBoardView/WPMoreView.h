//
//  WPMoreView.h
//  wxDemo
//
//  Created by 吴鹏 on 16/7/27.
//  Copyright © 2016年 wupeng. All rights reserved.
//

#import <UIKit/UIKit.h>

#define  WPMoreWillShow @"WPMoreWillShow"
#define  WPMoreWillHidden @"WPMoreWillHidden"


@class WPMoreView;
@protocol WPMoreViewDelegate <NSObject>

- (void)moreViewTreated:(NSInteger)treated;

@end

@interface WPMoreView : UIView

- (id)initWithMoreFrame:(CGRect)frame mainView:(UIView *)mainView;

@property (nonatomic , weak) id<WPMoreViewDelegate>delegate;

@end
