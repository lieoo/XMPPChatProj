//
//  InviteUserViewController.m
//  WHChatProj
//
//  Created by 行政 on 17/4/20.
//  Copyright © 2017年 lieo. All rights reserved.
//

#import "InviteUserViewController.h"
#import "VCFriendsCell.h"
@interface InviteUserViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) NSInteger curIndex;//记录cell下标 用作判断是语音还是图片
@property (nonatomic, strong) NSArray *friendArray;

@end

@implementation InviteUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"好友";
    [self.view addSubview:self.table];
    [self.table reloadData];
    self.dataSource = [XmppTools sharedManager].contacts;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rosterChange) name:kXMPP_ROSTER_CHANGE object:nil];
    [self setUpRightButton];
}
- (void)setUpRightButton{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(inviteUser)];
}
- (void)inviteUser{
    if (_slideInviteUserBlock) {
        _slideInviteUserBlock(_friendArray);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [VCFriendsCell calHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    VCFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VCFriendsCell"];
    XMPPUserMemoryStorageObject *user = [self.dataSource objectAtIndex:indexPath.row];
    [cell updateData:user];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    XMPPUserMemoryStorageObject *user = [self.dataSource objectAtIndex:indexPath.row];
//    VCChat *vc = [[VCChat alloc]init];
//    vc.toUser = user.jid;
//    vc.title = user.jid.user;
//    vc.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:vc animated:TRUE];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
}

- (void)rosterChange {
    if ([XmppTools sharedManager].contacts.count) {
        self.dataSource = [XmppTools sharedManager].contacts;
        [self.table reloadData];
    }
}

- (UITableView*)table{
    if (!_table) {
        _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICEWIDTH, DEVICEHEIGHT) style:UITableViewStylePlain];
        [_table registerClass:[VCFriendsCell class] forCellReuseIdentifier:@"VCFriendsCell"];
        _table.delegate = self;
        _table.dataSource = self;
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_table setBackgroundColor:RGB(244, 244, 244)];
    }
    return _table;
}
@end
