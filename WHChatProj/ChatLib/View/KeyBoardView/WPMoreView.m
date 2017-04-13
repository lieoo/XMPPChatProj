//
//  WPMoreView.m
//  wxDemo
//
//  Created by 吴鹏 on 16/7/27.
//  Copyright © 2016年 wupeng. All rights reserved.
//

#import "WPMoreView.h"
#import "WPTextView.h"
#import "WPToolBarView.h"

@interface UIButton (UIbuttonExt)
- (void)centerImageAndTitle:(float)space left:(float)leftSpace;
@end

@implementation UIButton (UIbuttonExt)

- (void)centerImageAndTitle:(float)spacing left:(float)leftSpace
{
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), leftSpace, 0.0, - titleSize.width-leftSpace);
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (totalHeight - titleSize.height),0.0);
}

@end

@interface WPMoreView ()<UIScrollViewDelegate>

@property (nonatomic , strong) UIView * mainView;
@property (nonatomic , strong) UIScrollView * scrollView;
@property (nonatomic , strong) NSArray * dataArray;
@property (nonatomic , strong) NSArray * titleArray;
@property (nonatomic , strong) UIPageControl * contrl;


@end

@implementation WPMoreView

- (id)initWithMoreFrame:(CGRect)frame mainView:(UIView *)mainView
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.mainView = mainView;
        self.backgroundColor = UIColorFromRGB(0xececef);
        [self registerBiaoQingNotificationCenter];
        self.dataArray = @[@"0",
                           @"1",];
        
        self.titleArray = @[@"照片",
                            @"收藏",
                            ];
        [self loadView];
    }
    return self;
}

#pragma mark - draw

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0.5, CGRectGetWidth(self.frame), 0.5));
}


#pragma mark - notificationCenter

- (void)registerBiaoQingNotificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moreShow)
                                                 name:WPMoreWillShow
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moreHidden)
                                                 name:WPMoreWillHidden
                                               object:nil];
}

- (void)moreShow
{
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         
                         for(UIView * view in self.mainView.subviews)
                         {
                             if([view isKindOfClass:[WPTextView class]])
                             {
                                 NSLog(@"WPTextView.h");
                                 self.mainView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - self.frame.size.height -15 - view.frame.size.height , self.mainView.frame.size.width, 15 + view.frame.size.height);
                             }
                         }
                         
                         
                         self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
                         
                     } completion:nil];
}

- (void)moreHidden
{
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.mainView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - self.mainView.frame.size.height, self.mainView.frame.size.width, self.mainView.frame.size.height);
                         self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height , self.frame.size.width, self.frame.size.height);
                     } completion:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WPMoreWillShow object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WPMoreWillHidden object:nil];
}


#pragma mark - loadView

- (void)loadView
{
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 1, self.frame.size.width, self.frame.size.height)];
    self.scrollView.backgroundColor = UIColorFromRGB(0xececef);
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width * 2, self.frame.size.height);
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
    
    for(NSInteger i = 0 ;i < self.dataArray.count ; i++)
    {
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake((self.frame.size.width -240)/5 * (i%4 + 1)+ i/8 * self.frame.size.width + i%4 * 60 ,
                                                                 i%8/4 * 95 + 15,
                                                                   60,
                                                                   80)];
        
        [btn setTitle:self.titleArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:UIColorFromRGB(0x8a8a8b) forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:self.dataArray[i]] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn centerImageAndTitle:5 left:0];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        [self.scrollView addSubview:btn];
    }
    //添加PageControl
    self.contrl = [[UIPageControl alloc]initWithFrame:CGRectMake((self.frame.size.width - 100)/2, self.frame.size.height - 30, 100, 20)];
    
    [self.contrl addTarget:self
                    action:@selector(pageChange)
          forControlEvents:UIControlEventValueChanged];
    
    self.contrl.numberOfPages = 2;
    self.contrl.currentPage = 0;
    self.contrl.pageIndicatorTintColor = UIColorFromRGB(0xcccccc);
    self.contrl.currentPageIndicatorTintColor = [UIColor lightGrayColor];
    [self addSubview:self.contrl];
    
}

#pragma mark - scrollview & uipagecontrol


- (void)pageChange
{
    [self.scrollView setContentOffset:CGPointMake(self.contrl.currentPage * self.frame.size.width, 0) animated:YES];
    [self.contrl setCurrentPage:self.contrl.currentPage];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [self.contrl setCurrentPage:self.scrollView.contentOffset.x / 320];
    [self.contrl updateCurrentPageDisplay];
}

#pragma mark - private
- (void)btnClick:(UIButton *)sender
{
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(moreViewTreated:)])
    {
        [self.delegate moreViewTreated:sender.tag];
    }
    
}

@end
