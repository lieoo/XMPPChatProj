//
//  WPToolBarView.h
//  wxDemo
//
//  Created by 吴鹏 on 16/7/25.
//  Copyright © 2016年 wupeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPTextView.h"
#import "WPBiaoqiangView.h"
#import "WPMoreView.h"
#import <AVFoundation/AVFoundation.h>
#import "VoiceHUDView.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@class WPToolBarView;
@protocol WPToolBarDataDelegate <NSObject>

//- (void)wp_respond:(WPDataModel *)dataModel;

-(void)send:(NSString *)msg;
-(void)sendImageDataDic:(NSDictionary *)dic;
-(void)recordFinish:(NSURL *)url withTime:(float)time;

@end

@interface WPToolBarView : UIView

@property (nonatomic , weak) id<WPToolBarDataDelegate>delegate;

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) VoiceHUDView *voiceHUDView;
@property (nonatomic, strong) NSURL *url;

- (id)initWithFrame:(CGRect)frame viewController:(UIViewController *)viewController;


@end
