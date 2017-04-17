//
//  AppDelegate.m
//  WHChatProj
//
//  Created by 行政 on 17/4/12.
//  Copyright © 2017年 lieo. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "VCFriends.h"
#import "VCMine.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    // 注册通知
    UIUserNotificationSettings *set = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:set];
    
    
    ViewController  *c1 =[[ViewController alloc]init];
    c1.tabBarItem.title=@"消息";
    c1.tabBarItem.image=[UIImage imageNamed:@"TabMessageIcon"];

    VCFriends *c2=[[VCFriends alloc]init];
    c2.tabBarItem.title=@"好友";
    c2.tabBarItem.image=[UIImage imageNamed:@"TabFriendIcon"];

    VCMine *c3=[[VCMine alloc]init];
    c3.tabBarItem.title=@"我的";
    c3.tabBarItem.image=[UIImage imageNamed:@"TabMeIcon"];
    
    UINavigationController *nav1 = [[UINavigationController alloc]initWithRootViewController:c1];
    UINavigationController *nav2 = [[UINavigationController alloc]initWithRootViewController:c2];
    UINavigationController *nav3 = [[UINavigationController alloc]initWithRootViewController:c3];
    
    UITabBarController *tabbarC = [[UITabBarController alloc]init];
    tabbarC.viewControllers=@[nav1,nav2,nav3];
    
    self.window.rootViewController = tabbarC;
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
