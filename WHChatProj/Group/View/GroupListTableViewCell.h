//
//  GroupListTableViewCell.h
//  WHChatProj
//
//  Created by 行政 on 17/4/21.
//  Copyright © 2017年 lieo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupListTableViewCell : UITableViewCell

@property (nonatomic,weak)UIImageView *header;
@property (nonatomic,weak)UILabel *nameLabel;
@property (nonatomic,weak)UIView *lineView;
+(CGFloat)cellH;

@end
