//
//  GroupMsgController.h
//  WHChatProj
//
//  Created by 行政 on 17/4/18.
//  Copyright © 2017年 lieo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XMPPFramework/XMPPRoom.h>
@interface GroupMsgController : UIViewController
@property (nonatomic,strong)XMPPRoom *room;
@property (nonatomic,strong)XMPPJID *jid;
@property (nonatomic, strong) NSURL *url;

@end
