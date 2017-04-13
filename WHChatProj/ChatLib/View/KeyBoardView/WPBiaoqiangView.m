//
//  WPBiaoqiangView.m
//  wxDemo
//
//  Created by 吴鹏 on 16/7/27.
//  Copyright © 2016年 wupeng. All rights reserved.
//

#import "WPBiaoqiangView.h"
#import "WPToolBarView.h"

@interface infoImageView : UIView

@property (nonatomic , strong) UIImageView * imageView;
@property (nonatomic , strong) UILabel * infoLabel;

@end

@implementation infoImageView

- (id)init
{
    self = [super init];
    if(self)
    {
        self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ([UIScreen mainScreen].bounds.size.width - 40- 80)/9 + 25, 50)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 6;
        self.layer.borderWidth = 1;
        self.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
        
        self.infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, ([UIScreen mainScreen].bounds.size.width - 40- 80)/9 + 25, 20)];
        self.infoLabel.textAlignment = NSTextAlignmentCenter;
        self.infoLabel.font = [UIFont systemFontOfSize:15];
        self.infoLabel.textColor = UIColorFromRGB(0x666666);
        [self addSubview:self.imageView];
        [self addSubview:self.infoLabel];
    }
    return self;
}


@end

@interface WPBiaoqiangView ()<UIScrollViewDelegate>

@property (nonatomic , strong) UIView * mainView;
@property (nonatomic , strong) NSArray * dataArray;
@property (nonatomic , strong) NSDictionary * dataDic;

@property (nonatomic , strong) UIScrollView * scrollView;
@property (nonatomic , strong) UIPageControl * contrl;
@property (nonatomic , strong) NSMutableArray * pointArray;

@property (nonatomic , strong) infoImageView * infoView;

@end

@implementation WPBiaoqiangView

- (id)initWithBiaoQingFrame:(CGRect)frame mainView:(UIView *)mainView
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.mainView = mainView;
        self.backgroundColor = [UIColor whiteColor];
        self.infoView = [[infoImageView alloc]init];
        [self registerBiaoQingNotificationCenter];
        [self readDataFromPlist];
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
                                             selector:@selector(baoqingShow)
                                                 name:WPBiaoQingWillShow
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(baoqingHidden)
                                                 name:WPBiaoQingWillHidden
                                               object:nil];
}

- (void)baoqingShow
{
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         for(UIView * view in self.mainView.subviews)
                         {
                             if([view isKindOfClass:[WPTextView class]])
                             {
                                 self.mainView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - self.frame.size.height -15 - view.frame.size.height , self.mainView.frame.size.width, 15 + view.frame.size.height);
                             }
                         }
                         self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
                         
                     } completion:nil];
}

- (void)baoqingHidden
{
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.mainView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - self.mainView.frame.size.height, self.mainView.frame.size.width, self.mainView.frame.size.height);
                         self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height , self.frame.size.width, self.frame.size.height);
                     } completion:nil];
}


- (void)loadView
{
//    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 1, self.frame.size.width, self.frame.size.height - 40)];
        self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 1, self.frame.size.width, self.frame.size.height)];
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width * 4, self.frame.size.height - 40);
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = UIColorFromRGB(0xececef);
    [self addSubview:self.scrollView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.scrollView addGestureRecognizer:tap];
    [self.scrollView addGestureRecognizer:longPressGr];
    self.pointArray = [NSMutableArray array];
    
    for(NSInteger i = 0 ;i < self.dataArray.count  ; i++)
    {
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:
                                   CGRectMake(20 + i/27 * self.frame.size.width + i%9 *( (self.frame.size.width - 40 - 80)/9 + 10),
                                              10+ i%27/9 * (self.scrollView.frame.size.height - 40)/3,
                                              (self.frame.size.width - 40- 80)/9,
                                              (self.scrollView.frame.size.height - 40)/3)];
          imageView.image = [UIImage imageNamed:[self.dataDic objectForKey:self.dataArray[i]]];
        [self.pointArray addObject:imageView];
        
        
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:imageView];
    }
    
    //添加PageControl
    self.contrl = [[UIPageControl alloc]initWithFrame:CGRectMake((self.frame.size.width - 100)/2, 190, 100, 20)];
    
    [self.contrl addTarget:self
                        action:@selector(pageChange)
              forControlEvents:UIControlEventValueChanged];
    
    self.contrl.numberOfPages = 4;
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

#pragma mark - tap

- (void)tap:(UIGestureRecognizer *)tap
{
    
    NSInteger i = [self getRowAndLine:[tap locationInView:self.scrollView]];
    
    if([tap isKindOfClass:[UILongPressGestureRecognizer class]])
    {
        if(i >=0 && i <104)
        {
            if(![self.dataArray[i] isEqualToString:@"[删除]"])
            {
                [self infoView:i imageView:self.pointArray[i]];
            }
        }
    }else
    {
        if(i >= 0 && i < 104)
        {
            if(![self.dataArray[i] isEqualToString:@"[删除]"])
            {
                if(self.delegate && [self.delegate respondsToSelector:@selector(WPbiaoQiongStr:)])
                    [self.delegate WPbiaoQiongStr:self.dataArray[i]];
            }else
            {
                NSLog(@"您点击了 删除按钮");
            }
        }
    }
    
    if(tap.state == UIGestureRecognizerStateEnded)
    {
        [self.infoView removeFromSuperview];
    }else
    {
        [[UIApplication sharedApplication].keyWindow addSubview:self.infoView];
    }
}

#pragma mark - 获取手指移动的具体位置 和 具体的index                                               

- (NSInteger)getRowAndLine:(CGPoint)point
{
    float w = (self.frame.size.width - 40)/9 ;
    float h = (self.scrollView.frame.size.height - 40)/3;
    NSInteger y = (point.y - 10)/h ;
    NSInteger h1 = point.x/self.frame.size.width;
    NSInteger x = (point.x - self.frame.size.width * h1 - 20)/w;
    NSInteger z = h1 * 27;

    
    if(self.frame.size.width * h1 < point.x && point.x < self.frame.size.width * h1 + self.frame.size.width - 20)
    {
        if(10 < point.y && point.y < self.scrollView.frame.size.height -30)
        {
            if(z == -1)
                z = 0;
             NSInteger i;
                i = (long)(y*9 + (x)%9) + z;
            
            return i;
            
        }
    }
    
    return  104;
    
    
}

- (void)infoView:(NSUInteger)index imageView:(UIImageView *)imageView
{
    
    
    CGRect rect  = [imageView.superview convertRect:imageView.frame toView:[UIApplication sharedApplication].keyWindow];
    self.infoView.frame = CGRectMake(rect.origin.x -12.5 , rect.origin.y- 70, imageView.frame.size.width + 25, 70);
    self.infoView.imageView.image = imageView.image;
    self.infoView.infoLabel.text = [self.dataArray[index] substringWithRange:NSMakeRange(1, [self.dataArray[index] length] - 2)];;
    
}

#pragma mark read data

- (void)readDataFromPlist
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"expression_CH" ofType:@"plist"];
     self.dataArray = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
    NSString *plistPath1 = [[NSBundle mainBundle] pathForResource:@"expressionImage_custom" ofType:@"plist"];
    self.dataDic = [[NSDictionary alloc] initWithContentsOfFile:plistPath1];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WPBiaoQingWillShow object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WPBiaoQingWillHidden object:nil];
}

@end
