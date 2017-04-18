//
//  AppDelegate.m
//  WHChatProj
//
//  Created by 行政 on 17/4/12.
//  Copyright © 2017年 lieo. All rights reserved.
//

#import "AppDelegate.h"
#import "MsgViewController.h"
#import "VCFriends.h"
#import "VCMine.h"
#import "VCLogin.h"
#import "VCTabbarController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    
    [self setUpNotifations];
    
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];

    BOOL loginFlag = [user boolForKey:@"loginFlag"];
    NSString *userName = [user objectForKey:@"userName"];
    NSString *userPassword = [user objectForKey:@"userPassword"];

    if (!loginFlag) {
        if (userName != nil && userPassword != nil) {
            [self autoLogin:userName withPwd:userPassword];
            VCTabbarController *vc = [[VCTabbarController alloc]init];
            self.window.rootViewController = vc;
        }else{
            [self showLogin];
        }
    }else{
        [self showLogin];
    }
    
    [self.window makeKeyWindow];
    
    return YES;
}

- (void)autoLogin:(NSString*)phone withPwd:(NSString*)password{
    [[XmppTools sharedManager] loginWithUser:phone withPwd:password withSuccess:^{
        NSLog(@"自动登录成功");
    } withFail:^(NSString *error) {
        [self showLogin];
    }];
}

- (void)showLogin{
    VCLogin *vc = [[VCLogin alloc]init];
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
    self.window.rootViewController = nvc;
}

- (void)setUpNotifations{
    UIUserNotificationSettings *set = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:set];
}



@end
