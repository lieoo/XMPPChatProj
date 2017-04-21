//
//  GroupListTableViewCell.m
//  WHChatProj
//
//  Created by 行政 on 17/4/21.
//  Copyright © 2017年 lieo. All rights reserved.
//

#import "GroupListTableViewCell.h"

#define CellH 80
@interface GroupListTableViewCell()
@end
@implementation GroupListTableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        CGFloat screenW =  [UIScreen mainScreen].bounds.size.width;
        CGFloat leftMargin = 16;
        
        UIImageView *imageV  = [[UIImageView alloc]init];
        imageV.frame = CGRectMake(15, 15, 50, 50);
//        imageV.contentMode = UIViewContentModeCenter;
        imageV.layer.cornerRadius = 10;
        imageV.clipsToBounds = YES;
        _header = imageV;
        [self.contentView addSubview:_header];
        
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake(imageV.right + 10, imageV.centerX - 15, screenW - 70,30);
        label.font = [UIFont boldSystemFontOfSize:15];
        label.textColor = [UIColor blackColor];
        _nameLabel = label;
        [self.contentView addSubview:_nameLabel];
        
        UIView *lineV = [[UIView alloc]init];
        lineV.frame = CGRectMake(leftMargin, CellH - 1, screenW - leftMargin, 1);
        lineV.backgroundColor = RGB3(229);
        _lineView = lineV;
        [self.contentView addSubview:_lineView];
    }
    return self;
}
+(CGFloat)cellH{
    return 80;
}
@end
