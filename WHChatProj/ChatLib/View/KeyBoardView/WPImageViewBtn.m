//
//  WPImageViewBtn.m
//  wxDemo
//
//  Created by 吴鹏 on 16/8/3.
//  Copyright © 2016年 wupeng. All rights reserved.
//

#import "WPImageViewBtn.h"

@interface WPImageViewBtn ()

@property (nonatomic , strong) CAShapeLayer * maskLayer;
@property (nonatomic , strong) CALayer * contentLayer;

@end

@implementation WPImageViewBtn

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.fillColor = [UIColor blackColor].CGColor;
        _maskLayer.strokeColor = [UIColor clearColor].CGColor;
        _maskLayer.frame = self.bounds;
        _maskLayer.contentsCenter = CGRectMake(0.5, 0.5, 0.1, 0.1);
        _maskLayer.contentsScale = [UIScreen mainScreen].scale;                 //非常关键设置自动拉伸的效果且不变形
        _maskLayer.contents = (id)[UIImage imageNamed:@"out"].CGImage;
        
        _contentLayer = [CALayer layer];
        _contentLayer.mask = _maskLayer;
        _contentLayer.frame = self.bounds;
        [self.layer addSublayer:_contentLayer];

    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    _contentLayer.contents = (id)image.CGImage;
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state
{
    _contentLayer.contents = (id)image.CGImage;
}


@end
