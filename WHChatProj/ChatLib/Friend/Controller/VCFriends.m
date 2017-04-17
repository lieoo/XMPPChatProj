//
//  VCMessages.m
//  AtChat
//
//  Created by zhouMR on 16/11/1.
//  Copyright © 2016年 luowei. All rights reserved.
//

#import "VCFriends.h"
#import "VCFriendsCell.h"
#import "VCChat.h"
#import "VCAddFriend.h"

@interface VCFriends ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) XMPPJID *jid;

@end

@implementation VCFriends

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addRightBtn];
    [self.view addSubview:self.table];
    self.dataSource = [XmppTools sharedManager].contacts;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rosterChange) name:kXMPP_ROSTER_CHANGE object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.table reloadData];
}

- (void)addRightBtn{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addUser)];
}

- (void)addUser{
    VCAddFriend *vc = [[VCAddFriend alloc]init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:TRUE];
}
- (void)deleteUser{
    [[XmppTools sharedManager]removeFriend:self.jid.user];
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
    VCChat *vc = [[VCChat alloc]init];
    vc.toUser = user.jid;
    vc.title = user.jid.user;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:TRUE];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        XMPPUserMemoryStorageObject *userObj = [self.dataSource objectAtIndex:indexPath.row];
        self.jid = userObj.jid;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"是否删除%@",userObj.jid.user] message:nil delegate:self cancelButtonTitle:@"删除!"  otherButtonTitles:@"等等再说", nil];
        alert.tag = 1;
        [alert show];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1 && buttonIndex == 0)[self deleteUser];
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
