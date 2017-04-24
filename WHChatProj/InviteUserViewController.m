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
//    [self setUpRightButton];
    [self addRightBtn];
    
}
- (void)addRightBtn{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
}
-(void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
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
//    [_currentRoom inviteUser:user.jid withMessage:@""];
    NSLog(@"%@",self.currentRoom.roomJID);
    
//    XMPPMessage* message=[[XMPPMessage alloc]init];
//    [message addAttributeWithName:@"from" stringValue:self.currentRoom.roomJID.full];
//    [message addAttributeWithName:@"to" stringValue:user.jid.full];
//    NSXMLElement* element_x=[NSXMLElement elementWithName:@"x" xmlns:@"http://jabber.org/protocol/muc#user"];
//    [message addChild:element_x];
//    NSXMLElement* element_invite=[NSXMLElement elementWithName:@"invite"];
//    [element_invite addAttributeWithName:@"from" stringValue:[XmppTools sharedManager].userJid.user];
//    [element_invite addAttributeWithName:@"to" stringValue:user.jid.full];
//    [element_x addChild:element_invite];
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    
    XMPPMessage* message=[[XMPPMessage alloc]init];
    [message addAttributeWithName:@"from" stringValue:self.currentRoom.roomJID.full];
    [message addAttributeWithName:@"to" stringValue:user.jid.full];
    NSXMLElement* element_x=[NSXMLElement elementWithName:@"x" xmlns:@"http://jabber.org/protocol/muc#user"];
    [message addChild:element_x];
    NSXMLElement* element_invite=[NSXMLElement elementWithName:@"invite"];
    [element_invite addAttributeWithName:@"from" stringValue:[XmppTools sharedManager].userJid.user];
    [element_invite addAttributeWithName:@"to" stringValue:user.jid.full];
    [element_invite addAttributeWithName:@"body" stringValue:[NSString stringWithFormat:@"%@",self.currentRoom.roomJID]];
    [element_x addChild:element_invite];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
//    [self.currentRoom editRoomPrivileges:@[[XMPPRoom itemWithRole:@"admin" jid:user.jid]]];
    [self.currentRoom editRoomPrivileges:@[[XMPPRoom itemWithRole:@"admin" jid:user.jid]]];
    
//    if (reason){
//        NSXMLElement* element_reason=[NSXMLElement elementWithName:@"reason"];
//        element_reason.stringValue=reason;
//        [element_invite addChild:element_reason];
//    }
//    if (password){
//        NSXMLElement* element_password=[NSXMLElement elementWithName:@"password"];
//        element_password.stringValue=password;
//        [element_x addChild:element_password];
//    }
    [[XmppTools sharedManager].xmppStream sendElement:message];
    
    [self performSelector:@selector(dismissController) withObject:nil afterDelay:1];
    
//    VCChat *vc = [[VCChat alloc]init];
//    vc.toUser = user.jid;
//    vc.title = user.jid.user;
//    vc.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:vc animated:TRUE];
}
- (void)dismissController{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
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
