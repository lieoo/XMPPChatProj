//
//  VCFriendsCell.h
//  AtChat
//
//  Created by zhouMR on 16/11/2.
//  Copyright © 2016年 luowei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCFriendsCell : UITableViewCell
+ (CGFloat)calHeight;
- (void)updateData:(XMPPUserMemoryStorageObject*)user;
@end
