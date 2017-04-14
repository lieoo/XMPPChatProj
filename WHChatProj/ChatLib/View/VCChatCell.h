//
//  VCChatCell.h
//  AtChat
//
//  Created by zhouMR on 16/11/2.
//  Copyright © 2016年 luowei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
typedef void(^touchCellIndex)(NSInteger index,UITapGestureRecognizer *sender);

@protocol VCChatCellDelegate;

@interface VCChatCell : UITableViewCell
@property (nonatomic, weak) id<VCChatCellDelegate> delegate;
-(void)loadData:(XMPPMessageArchiving_Message_CoreDataObject *)msg;
+ (CGFloat)calHeight:(XMPPMessageArchiving_Message_CoreDataObject *)msg;

@property (nonatomic,assign) NSInteger index;
@property (nonatomic,copy)touchCellIndex touchCellIndex;

@end

@protocol VCChatCellDelegate <NSObject>

//- (void)chat:(VCChatCell*)cell didSelectWithType:(NSInteger)type withUrl:(NSURL*)url withImage:(UIImage*)img;



@end
