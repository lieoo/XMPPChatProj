//
//  VCChat.h
//  AtChat
//
//  Created by zhouMR on 16/11/2.
//  Copyright © 2016年 luowei. All rights reserved.
//

#import "VCBase.h"
#import "XmppTools.h"

@interface VCChat : VCBase
@property (nonatomic, strong) XMPPJID *toUser;
@property (nonatomic, strong) NSURL *url;
@end
