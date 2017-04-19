//
//  RoomListViewController.m
//  WHChatProj
//
//  Created by 行政 on 17/4/18.
//  Copyright © 2017年 lieo. All rights reserved.
//

#import "RoomListViewController.h"
#import "VCMsgesCell.h"
#import "XMPPRoomMemoryStorage.h"

@interface RoomListViewController ()<XMPPRoomDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (nonatomic,strong)XMPPRoom *xmppRoom;
@property (nonatomic,strong)XMPPRoomCoreDataStorage *xmppRoomStorage;
@property (nonatomic,strong)NSMutableArray *RoomDataSource;
@property (nonatomic,strong)UITableView *table;
@end

@implementation RoomListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addRightBtn];

    [self addLeftBtn];
    
    [self getRoomList];
    
    [self.view addSubview:self.table];
    
    [[XmppTools sharedManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getRoomsResult:) name:kXMPP_GET_GROUPS object:nil];
    
}
- (void)CreatRoomTest{
    UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"请输入群名" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好的", nil];
    alertV.tag = 0;
    alertV.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertV show];
}
//加入没有房间 会创建。此处应该和后端配合
- (void)getRoomsResult:(NSNotification *)notification{
    NSLog(@"%@",notification.object);
    
    [self.RoomDataSource removeAllObjects];
    [self.RoomDataSource addObjectsFromArray:[notification object]];
    [self.table reloadData];
}


- (void)getRoomList{
    NSXMLElement *queryElement= [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
    NSXMLElement *iqElement = [NSXMLElement elementWithName:@"iq"];
    [iqElement addAttributeWithName:@"type" stringValue:@"get"];
    [iqElement addAttributeWithName:@"from" stringValue:[XmppTools sharedManager].xmppStream.myJID.bare];
//    NSString *service = [NSString stringWithFormat:@"group.127.0.0.1"];
    NSString *service = [NSString stringWithFormat:@"conference.127.0.0.1"];
    [iqElement addAttributeWithName:@"to" stringValue:service];
    [iqElement addAttributeWithName:@"id" stringValue:@"getMyRooms"];
    [iqElement addChild:queryElement];
    [[XmppTools sharedManager].xmppStream sendElement:iqElement];

}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.RoomDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"roomCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    DDXMLElement *item = self.RoomDataSource[indexPath.row];
    NSString *text = [NSString stringWithFormat:@"房间名:%@",[item attributeForName:@"name"].stringValue];
    cell.textLabel.text = text;
    cell.detailTextLabel.text = [item attributeForName:@"jid"].stringValue;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)addRightBtn{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"创建/加入聊天" style:UIBarButtonItemStylePlain target:self action:@selector(CreatRoomTest)];
}
- (void)addLeftBtn{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"查找房间" style:UIBarButtonItemStylePlain target:self action:@selector(searchGroup)];
}
//
//- (void)creatChat{
//    NSLog(@"%s",__func__);
//    
//    NSString *roomId = [NSString stringWithFormat:@"%@@group.im.joker.cn/%@",@"lieoo",[XmppTools sharedManager].xmppStream.myJID.bare];
//    XMPPJID *roomJID = [XMPPJID jidWithString:roomId];
//    XMPPRoomMemoryStorage *xmppRoomStorage = [[XMPPRoomMemoryStorage alloc] init];
//    XMPPRoom *xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:xmppRoomStorage jid:roomJID dispatchQueue:dispatch_get_main_queue()];
//    [xmppRoom activate:[XmppTools sharedManager].xmppStream];
//    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
//    [xmppRoom joinRoomUsingNickname:@"NickName" history:nil password:nil];
//}
//
- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    [self configNewRoom:sender];//可以自定义房间配置 此处可以自定义
    [self setUpJoinAndCreatRoomConfig];
    NSLog(@"加入房间成功");
    [self getRoomList];
}

- (void)setUpJoinAndCreatRoomConfig{
    [self.xmppRoom fetchConfigurationForm];
    [self.xmppRoom fetchBanList];
    [self.xmppRoom fetchMembersList];
    [self.xmppRoom fetchModeratorsList];

}
- (void)xmppRoom:(XMPPRoom *)sender didFailToDestroy:(XMPPIQ *)iqError{
    
}
- (void)configNewRoom:(XMPPRoom *)xmppRoom
{
    NSXMLElement *x = [NSXMLElement elementWithName:@"x"xmlns:@"jabber:x:data"];
    NSXMLElement *p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_persistentroom"];//永久房间
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_maxusers"];//最大用户
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"10000"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_changesubject"];//允许改变主题
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_publicroom"];//公共房间
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:@"0"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_allowinvites"];//允许邀请
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:@"1"]];
    [x addChild:p];
    
    [xmppRoom configureRoomUsingOptions:x];
}

- (void)xmppRoomDidCreate:(XMPPRoom *)sender{
    NSLog(@"%s",__func__);
    
    //    NSString *message = [NSString stringWithFormat:@"群<%@>已创建完成",sender.roomJID.user];
    NSString *message = [NSString stringWithFormat:@"群已创建完成"];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    });
    [self configNewRoom:sender];//可以自定义房间配置 此处可以自定义
    [self setUpJoinAndCreatRoomConfig];
}
- (void)searchGroup{
    NSLog(@"%s",__func__);
    NSXMLElement *queryElement= [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
    NSXMLElement *iqElement = [NSXMLElement elementWithName:@"iq"];
    [iqElement addAttributeWithName:@"type" stringValue:@"get"];
    [iqElement addAttributeWithName:@"from" stringValue:[XmppTools sharedManager].xmppStream.myJID.bare];
    NSString *service = [NSString stringWithFormat:@"conference.127.0.0.1"];
    [iqElement addAttributeWithName:@"to" stringValue:service];
    [iqElement addAttributeWithName:@"id" stringValue:@"getMyRooms"];
    [iqElement addChild:queryElement];
    [[XmppTools sharedManager].xmppStream sendElement:iqElement];
}
- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID{
    NSLog(@"%s",__func__);
}
//有人退出群聊
- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID{
    NSLog(@"%s",__func__);
}
//有人在群里发言
- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID{
    NSLog(@"%s",__func__);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *roomId = [NSString stringWithFormat:@"%@@conference.127.0.0.1",[alertView textFieldAtIndex:0].text];
    XMPPJID *roomJID = [XMPPJID jidWithString:roomId];
    // 如果不需要使用自带的CoreData存储，则可以使用这个。
    XMPPRoomMemoryStorage *xmppRoomStorage = [[XMPPRoomMemoryStorage alloc] init];
    XMPPRoom *xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:xmppRoomStorage jid:roomJID dispatchQueue:dispatch_get_main_queue()];
    [xmppRoom activate:[XmppTools sharedManager].xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoom joinRoomUsingNickname:[XmppTools sharedManager].xmppStream.myJID.user history:nil password:nil];
}
- (UITableView*)table{
    if (!_table) {
       _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICEWIDTH, DEVICEHEIGHT) style:UITableViewStylePlain];
        [_table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"roomCell"];
        _table.delegate = self;
        _table.dataSource = self;
        [_table setBackgroundColor:RGB(244, 244, 244)];
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _table;
}
- (NSMutableArray *)RoomDataSource{
    if (_RoomDataSource) return _RoomDataSource;
    _RoomDataSource = [NSMutableArray array];
    return _RoomDataSource;
}
@end
