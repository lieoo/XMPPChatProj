//
//  InviteUserViewController.h
//  WHChatProj
//
//  Created by 行政 on 17/4/20.
//  Copyright © 2017年 lieo. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^slideInviteUserBlock)(NSArray *friendArray);

@interface InviteUserViewController : UIViewController
@property (nonatomic,copy)slideInviteUserBlock slideInviteUserBlock;

@end
