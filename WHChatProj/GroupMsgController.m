//
//  GroupMsgController.m
//  WHChatProj
//
//  Created by 行政 on 17/4/18.
//  Copyright © 2017年 lieo. All rights reserved.
//

#import "GroupMsgController.h"
#import "VCMsgesCell.h"

@interface GroupMsgController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation GroupMsgController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addRightBtn];
    [self.view addSubview:_table];
    [[XmppTools sharedManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)addRightBtn{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"邀请好友" style:UIBarButtonItemStylePlain target:self action:@selector(inviteFriend)];
}
- (void)inviteFriend{
    NSLog(@"%s",__func__);
}
-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [VCMsgesCell calHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    VCMsgesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VCMsgesCell"];
    XMPPMessageArchiving_Contact_CoreDataObject *data = [self.dataSource objectAtIndex:indexPath.row];
    [cell updateData:data];
    if (indexPath.row == self.dataSource.count-1) {
        cell.vLine.hidden = YES;
    }else{
        cell.vLine.hidden = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    XMPPMessageArchiving_Contact_CoreDataObject *user = [self.dataSource objectAtIndex:indexPath.row];
//    VCChat *vc = [[VCChat alloc]init];
//    vc.toUser = user.bareJid;
//    vc.title = user.bareJid.user;
//    vc.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:vc animated:TRUE];
}

- (UITableView*)table{
    if (!_table) {
        _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICEWIDTH, DEVICEHEIGHT) style:UITableViewStylePlain];
        [_table registerClass:[VCMsgesCell class] forCellReuseIdentifier:@"VCMsgesCell"];
        _table.delegate = self;
        _table.dataSource = self;
        [_table setBackgroundColor:RGB(244, 244, 244)];
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _table;
}



@end
