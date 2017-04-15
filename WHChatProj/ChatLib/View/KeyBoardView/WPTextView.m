//
//  WPTextView.m
//  wxDemo
//
//  Created by 吴鹏 on 16/7/25.
//  Copyright © 2016年 wupeng. All rights reserved.
//

#import "WPTextView.h"

@interface WPTextView ()<UITextViewDelegate>
{
    float height;
    
    BOOL isKeyBoard;
}

@property (nonatomic , strong)UIView * mainView;

@end

@implementation WPTextView

- (id)initWithFrame:(CGRect)frame mainView:(UIView *)mainView
{
    if(self = [super initWithFrame:frame]){
        self.mainView = mainView;
        CGFloat cornerRadius = 6.0f;
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderWidth = 0.5f;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.cornerRadius = cornerRadius;
        self.layer.masksToBounds = YES;
        self.layoutManager.allowsNonContiguousLayout = NO;
        
        self.font = [UIFont systemFontOfSize:16.0f];
        self.textColor = [UIColor blackColor];
        self.scrollsToTop = NO;
        self.keyboardAppearance = UIKeyboardAppearanceDefault;
        self.keyboardType = UIKeyboardTypeDefault;
        self.returnKeyType = UIReturnKeySend;
        self.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        
        self.text = nil;
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self registerForKeyboardNotifications];
        
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGSize sizeThatFits = [self sizeThatFits:self.frame.size];
    float newHeight = sizeThatFits.height;
    
    if(isKeyBoard){
        height = [UIScreen mainScreen].bounds.size.height - self.mainView.frame.origin.y - self.mainView.frame.size.height;
    }else{
        isKeyBoard = NO;
    }
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, newHeight);
    self.mainView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - height - 15 - newHeight, self.mainView.frame.size.width, 15 + newHeight);
}

#pragma mark - notification
- (void)registerForKeyboardNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter]  addObserver:self
                                              selector:@selector(keyboardWasHidden:)
                                                  name:UIKeyboardWillHideNotification
                                                object:nil];
}

- (void)keyboardWasShown:(NSNotification *)noti{
    isKeyBoard = YES;
    NSDictionary *info = [noti userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    NSString * time = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    
    [UIView animateWithDuration:[time integerValue]
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.mainView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - keyboardSize.height - self.frame.size.height - 15 , self.mainView.frame.size.width, self.frame.size.height + 15);
    } completion:^(BOOL finished) {
        [self setNeedsDisplay];
    }];
}

- (void)keyboardWasHidden:(NSNotification *)noti{
    NSDictionary *info = [noti userInfo];
    NSString * time = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    [UIView animateWithDuration:[time integerValue]
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.mainView.frame = CGRectMake(0,[UIScreen mainScreen].bounds.size.height - self.frame.size.height - 15 , self.mainView.frame.size.width, self.frame.size.height + 15);
                     } completion:nil];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}



@end
