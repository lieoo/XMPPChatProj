//
//  VCTabbarController.m
//  WHChatProj
//
//  Created by 行政 on 17/4/18.
//  Copyright © 2017年 lieo. All rights reserved.
//

#import "VCTabbarController.h"

@interface VCTabbarController ()

#define kClassKey   @"rootVCClassString"
#define kTitleKey   @"title"
#define kImgKey     @"imageName"
#define kSelImgKey  @"selectedImageName"
@end

@implementation VCTabbarController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray *childItemsArray = @[
                                 @{kClassKey  : @"MsgViewController",
                                   kTitleKey  : @"消息",
                                   kImgKey    : @"TabMessageIcon",
                                   kSelImgKey : @"TabMessageIcon"},
                                 
                                 @{kClassKey  : @"RoomListViewController",
                                   kTitleKey  : @"群聊",
                                   kImgKey    : @"TabMessageIcon",
                                   kSelImgKey : @"TabMessageIcon"},
                                 
                                 @{kClassKey  : @"VCFriends",
                                   kTitleKey  : @"好友",
                                   kImgKey    : @"TabFriendIcon",
                                   kSelImgKey : @"TabFriendIcon"},
                                 
                                 @{kClassKey  : @"VCMine",
                                   kTitleKey  : @"我",
                                   kImgKey    : @"TabMeIcon",
                                   kSelImgKey : @"TabMeIcon"}];
    
    [childItemsArray enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        UIViewController *vc = [NSClassFromString(dict[kClassKey]) new];
        vc.title = dict[kTitleKey];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        UITabBarItem *item = nav.tabBarItem;
        item.title = dict[kTitleKey];
        item.image = [UIImage imageNamed:dict[kImgKey]];
        item.selectedImage = [UIImage imageNamed:dict[kSelImgKey]];
        
        [self addChildViewController:nav];
    }];
}

@end
