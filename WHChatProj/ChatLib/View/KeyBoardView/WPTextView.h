//
//  WPTextView.h
//  wxDemo
//
//  Created by 吴鹏 on 16/7/25.
//  Copyright © 2016年 wupeng. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WPTextView : UITextView

- (id)initWithFrame:(CGRect)frame mainView:(UIView *)mainView;

@property (nonatomic , copy) NSString * placeHolder;

@end
