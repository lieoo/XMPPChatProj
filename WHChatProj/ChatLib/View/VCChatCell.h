//
//  VCChatCell.h
//  AtChat
//
//  Created by zhouMR on 16/11/2.
//  Copyright © 2016年 luowei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
typedef void(^touchCellIndex)(NSInteger index);

@interface VCChatCell : UITableViewCell

-(void)loadData:(XMPPMessageArchiving_Message_CoreDataObject *)msg;
+ (CGFloat)calHeight:(XMPPMessageArchiving_Message_CoreDataObject *)msg;

@property (nonatomic,assign) NSInteger index;
@property (nonatomic,copy)touchCellIndex touchCellIndex;

@end
