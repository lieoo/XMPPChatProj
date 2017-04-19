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

@interface RoomListViewController ()<XMPPRoomDelegate,UITableViewDataSource,UITableViewDelegate>

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
    
    [self.view addSubview:_table];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getRoomsResult:) name:kXMPP_GET_GROUPS object:nil];
    
}

- (void)getRoomsResult:(NSNotification *)notification
{
    NSArray *array = [notification object];
    NSLog(@"%@,群组列表：%@",[NSThread currentThread],array);
    [self.RoomDataSource addObjectsFromArray:array];
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
    
    DDXMLElement *item = self.RoomDataSource[indexPath.row];
    
    NSString *text = [NSString stringWithFormat:@"房间名:%@",[item attributeForName:@"name"].stringValue];
    cell.textLabel.text = text;
    cell.detailTextLabel.text = [item attributeForName:@"jid"].stringValue;
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [VCMsgesCell calHeight];
}

- (void)addRightBtn{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"创建聊天" style:UIBarButtonItemStylePlain target:self action:@selector(creatChat)];
}
- (void)addLeftBtn{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"查找房间" style:UIBarButtonItemStylePlain target:self action:@selector(searchGroup)];
}
- (void)creatChat{
    NSLog(@"%s",__func__);
    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init]; [formatter setDateFormat:@"yyyyMMddHHmmss"];
//    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
//    NSString *roomId = [NSString stringWithFormat:@"%@@group.im.joker.cn/%@",currentTime,[XmppTools sharedManager].xmppStream.myJID.bare];
    NSString *roomId = [NSString stringWithFormat:@"%@@group.im.joker.cn/%@",@"lieoo",[XmppTools sharedManager].xmppStream.myJID.bare];
    XMPPJID *roomJID = [XMPPJID jidWithString:roomId];
    XMPPRoomMemoryStorage *xmppRoomStorage = [[XMPPRoomMemoryStorage alloc] init];
    XMPPRoom *xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:xmppRoomStorage jid:roomJID dispatchQueue:dispatch_get_main_queue()];
    [xmppRoom activate:[XmppTools sharedManager].xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoom joinRoomUsingNickname:@"NickName" history:nil password:nil];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    NSLog(@"加入房间成功");
//    [self configNewRoom:sender];

    NSString *message = [NSString stringWithFormat:@"群<%@>已创建完成",sender.roomJID.user];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [alertView show];
    });
    [self.xmppRoom fetchConfigurationForm];
    [self.xmppRoom fetchBanList];
    [self.xmppRoom fetchMembersList];
    [self.xmppRoom fetchModeratorsList];
}
- (void)configNewRoom:(XMPPRoom *)xmppRoom
{
    NSXMLElement *x = [NSXMLElement elementWithName:@"x"xmlns:@"jabber:x:data"];
    NSXMLElement *p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_persistentroom"];//永久房间
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_maxusers"];//最大用户
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:@"10000"]];
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
}
- (void)searchGroup{
    NSLog(@"%s",__func__);
}
- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID
{
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
