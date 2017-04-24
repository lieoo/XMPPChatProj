//
//  XmppTools.m
//  ChatMPP
//
//  Created by zhouMR on 16/10/14.
//  Copyright © 2016年 luowei. All rights reserved.
//

#import "XmppTools.h"

@implementation XmppTools

+ (instancetype)sharedManager{
    static XmppTools *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XmppTools alloc]init];
    });
    return manager;
}

- (id)init{
    if (self = [super init]) {
        [self setupStream];
    }
    return self;
}

- (void)setupStream{
    _xmppStream = [[XMPPStream alloc] init];
    _xmppStream.enableBackgroundingOnSocket = YES;
    // 在多线程中运行，为了不阻塞UI线程，
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    _xmppAutoPing = [[XMPPAutoPing alloc] init];
    
    [_xmppAutoPing setPingInterval:1000]; //控制 didReceiveIQ 方法响应时间
    [_xmppAutoPing setRespondsToQueries:YES];
    [_xmppAutoPing activate:_xmppStream];
    [_xmppAutoPing addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    
    
    // 2.autoReconnect 自动重连
    _xmppReconnect = [[XMPPReconnect alloc] init];
    [_xmppReconnect activate:_xmppStream];
    [_xmppReconnect setAutoReconnect:YES];
    [_xmppReconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    // 3.好友模块 支持我们管理、同步、申请、删除好友
    _xmppRosterMemoryStorage = [[XMPPRosterMemoryStorage alloc] init];
    _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:_xmppRosterMemoryStorage];
    [_xmppRoster activate:_xmppStream];
    
    //同时给_xmppRosterMemoryStorage 和 _xmppRoster都添加了代理
    [_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //设置好友同步策略,XMPP一旦连接成功，同步好友到本地
    [_xmppRoster setAutoFetchRoster:YES]; //自动同步，从服务器取出好友
    //关掉自动接收好友请求，默认开启自动同意
    [_xmppRoster setAutoAcceptKnownPresenceSubscriptionRequests:NO];
    
    
    //使用电子名片
    XMPPvCardCoreDataStorage *vCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _xmppvCardModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:vCardStorage];
    [_xmppvCardModule activate:_xmppStream];
    //头像
    _xmppAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_xmppvCardModule];
    [_xmppAvatarModule activate:_xmppStream];
    
    self.messageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    self.messageArchiving = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:self.messageArchivingCoreDataStorage dispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 9)];
    self.messageArchiving.clientSideMessageArchivingOnly = YES;
    [self.messageArchiving activate:self.xmppStream];
    
    
}

/**
 *  登录方法
 *  @prarm userName 用户名
 *  @prarm userPwd  密码
 */
- (void)loginWithUser:(NSString*)userName withPwd:(NSString*)userPwd withSuccess:(SuccessBlock)sblock withFail:(FailureBlock)fblock{
    self.connectToServerPurpose = ConnectToServerPurposeLogin;
    self.successBlack = sblock;
    self.failureBlack = fblock;
    self.userPassword = userPwd;
    self.userName = userName;
    [self connection:userName];
}

/**
 * 注册方法
 *  @prarm userName 用户名
 *  @prarm userPwd  密码
 */
- (void)registerWithUser:(NSString *)userName password:(NSString *)password withSuccess:(SuccessBlock)sblock withFail:(FailureBlock)fblock
{
    self.connectToServerPurpose = ConnectToServerPurposeRegister;
    self.successBlack = sblock;
    self.failureBlack = fblock;
    self.userPassword = password;
    [self connection:userName];
}

//连接服务器
- (void)connection:(NSString*)userName{
    XMPPJID *jid = [XMPPJID jidWithUser:userName domain:XMPP_HOST resource:userName];
    self.userJid = jid;
    [self.xmppStream setMyJID:jid];
    // 发送请求
    if ([self.xmppStream isConnected] || [self.xmppStream isConnecting]) {
        // 先发送下线状态
        XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
        [self.xmppStream sendElement:presence];
        
        // 断开连接
        [self.xmppStream disconnect];
    }
    NSError *error;
    [self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
}

#pragma mark - XMPPStreamDelegate

- (void)xmppStreamWillConnect:(XMPPStream *)sender {
    NSLog(@"%s--%d|正在连接",__func__,__LINE__);
}

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket {
    // 连接成功之后，由客户端xmpp发送一个stream包给服务器，服务器监听来自客户端的stream包，并返回stream feature包
    NSLog(@"%s--%d|连接成功",__func__,__LINE__);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    
    NSLog(@"ERROR:\%@\n",error);
    NSLog(@"SENDER:\n%@\n",sender);
    NSLog(@"%ld",error.code);
    if(error && error.code == 7){
        [self goOffLine];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@(TRUE) forKey:@"loginFlag"];
        [userDefaults synchronize];
        NSLog(@"%s--%d|异地登录|%@",__func__,__LINE__,error);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"该帐号在其他设备登录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        alertView.tag = 101;
        [alertView show];
    }else if (error.code != 0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"连接失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
    NSLog(@"%s--%d|连接失败|%@",__func__,__LINE__,error);
}

/**
 *  xmpp连接成功之后走这里
 */
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSError *error;
    switch (self.connectToServerPurpose) {
        case ConnectToServerPurposeLogin:
            [self.xmppStream authenticateWithPassword:self.userPassword error:&error];
            break;
        case ConnectToServerPurposeRegister:
            [self.xmppStream registerWithPassword:self.userPassword error:&error];
            
        default:
            break;
    }
}

/**
 *  密码验证成功（即登录成功）
 */
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    //NSLog(@"xmpp授权成功。");
    //设置当前用户上线状态
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [self.xmppStream sendElement:presence];
    self.successBlack();
}

/**
 *  密码验证失败
 */
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    //NSLog(@"️xmpp授权失败:%@", error.description);
    self.failureBlack(error.description);
}

/**
 *  注册成功
 */
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    self.successBlack();
}

/**
 *  注册失败
 */
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error{
    self.failureBlack(error.description);
}

-(void)goOffLine{
    //生成网络状态
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    //改变通道状态
    [self.xmppStream sendElement:presence];
    //断开链接
    [self.xmppStream disconnect];
}

#pragma mark - XMPPReconnectDelegate
//重新失败时走该方法
- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags{
    NSLog(@"%s--%d|",__func__,__LINE__);
}

//接受自动重连
- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags{
    NSLog(@"%s--%d|",__func__,__LINE__);
    return TRUE;
}

#pragma mark ===== 好友模块 委托=======
/** 收到出席订阅请求（代表对方想添加自己为好友) */
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    //添加好友一定会订阅对方，但是接受订阅不一定要添加对方为好友
    self.receivePresence = presence;
    NSString *from = presence.from.bare;
    NSRange range = [from rangeOfString:@"@"];
    from = [from substringToIndex:range.location];
    NSString *message = [NSString stringWithFormat:@"【%@】想加你为好友",from];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"同意", nil];
    alertView.tag = 100;
    [alertView show];
    
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        if (buttonIndex == 0) {
            [self.xmppRoster rejectPresenceSubscriptionRequestFrom:self.receivePresence.from];
        } else {
            [self.xmppRoster acceptPresenceSubscriptionRequestFrom:self.receivePresence.from andAddToRoster:YES];
        }
    }else if (alertView.tag == 2 && buttonIndex ==1){
     
    }
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    NSLog(@"%s %d",__func__,__LINE__);
    
    [sender fetchBanList];
    [sender fetchMembersList];
    [sender fetchModeratorsList];
    [self configNewRoom:sender];//可以自定义房间配置 此处可以自定义
    [sender fetchConfigurationForm];

    NSLog(@"加入房间成功");
//    [self getRoomList];
}

- (void)xmppRoom:(XMPPRoom *)sender didFailToDestroy:(XMPPIQ *)iqError{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"加入群组失败" delegate:nil cancelButtonTitle:@"我知道了"otherButtonTitles: nil];
    [alertView show];
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
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"100"]];
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
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_enablelogging"];//登录房间会话
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_roomadmins"];//
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field"];
    [p addAttributeWithName:@"var" stringValue:@"muc#maxhistoryfetch"];
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"0"]]; //history
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field"];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_Unmoderatedroom"];
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:p];
    
    [xmppRoom configureRoomUsingOptions:x];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 101) {
//        VCLogin *vc = [[VCLogin alloc]init];
//        UIWindow *window = [UIApplication sharedApplication].keyWindow;
//        VCNavBase *nvc = [[VCNavBase alloc]initWithRootViewController:vc];
//        window.rootViewController = nvc;
    }
}

-(void) xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
    NSLog(@"新人加入群聊 %s ",__func__);
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    //收到对方取消定阅我得消息
    if ([presence.type isEqualToString:@"unsubscribe"]) {
        //从我的本地通讯录中将他移除
        [self.xmppRoster removeUser:presence.from];
    }
}


- (NSManagedObjectContext *)vCardContext   //电子名片模块
{
    XMPPvCardCoreDataStorage *storage = [XMPPvCardCoreDataStorage sharedInstance];
    return [storage mainThreadManagedObjectContext];
}


#pragma mark - 获取模块管理对象
- (XMPPvCardAvatarModule *)avatarModule    //头像模块
{
    return _xmppAvatarModule;
}

- (XMPPvCardTempModule *)vCardModule
{
    return _xmppvCardModule;
}

#pragma  mark --------------------自定义方法
- (XMPPJID*)getJIDWithUserId:(NSString *)userId{
    XMPPJID *chatJID = [XMPPJID jidWithString:[self idAndHost:userId]];
    return chatJID;
}

//用户名+HOST
- (NSString *)idAndHost:(NSString*)userId{
    NSString *baseStr = [NSString stringWithFormat:@"%@@%@/%@",userId,XMPP_HOST,XMPP_PLATFORM];
    return baseStr;
}

- (NSData*)getImageData:(NSString *)userId;
{
    XMPPJID *jid = [XMPPJID jidWithString:[self idAndHost:userId] resource:XMPP_PLATFORM];
    NSData *photoData = [[self avatarModule] photoDataForJID:jid];
    return photoData;
}

/**
 * 同步结束
 **/
//收到好友列表IQ会进入的方法，并且已经存入我的存储器
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender
{
    [self changeFriend];
}

// 如果不是初始化同步来的roster,那么会自动存入我的好友存储器
- (void)xmppRosterDidChange:(XMPPRosterMemoryStorage *)sender
{
    [self changeFriend];
}


-(void)changeFriend{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.xmppRosterMemoryStorage.unsortedUsers];
    self.contacts = [array mutableCopy];
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROSTER_CHANGE object:nil];
}


- (void)addFriendById:(NSString*)name
{
    [self.xmppRoster addUser:[self getJIDWithUserId:name] withNickname:@"好友"];
}

- (void)removeFriend:(NSString *)name
{
    [self.xmppRoster removeUser:[self getJIDWithUserId:name]];
}
//
//- (void)sendTextMsg:(NSString *)msg withId:(NSString*)toUser{
//    XMPPJID *jid = [self getJIDWithUserId:toUser];
//    XMPPMessage *message = [XMPPMessage messageWithType:CHATTYPE to:jid];
//    [message addBody:msg];
//    XMPPElement *attachment = [XMPPElement elementWithName:@"MSGTYPE" stringValue:@"0"];
//    [message addChild:attachment];
//    [self.xmppStream sendElement:message];
//}
//
//- (void)sendGroupMsg:(NSString *)msg withRoomId:(NSString *)roomName{
//    NSString *newRoomName=[[roomName componentsSeparatedByString:@"@"]firstObject];
//    NSString* roomJid = [NSString stringWithFormat:@"%@%@",newRoomName,XMPP_GROUPSERVICE];
//    XMPPMessage *message = [XMPPMessage messageWithType:kXMPP_SUBDOMAIN to:[XMPPJID jidWithString:roomJid]];
//    [message addChild:[DDXMLNode elementWithName:@"body" stringValue:msg]];
//    [self.xmppStream sendElement:message];
//}
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    
    if ([self isChatRoomInvite:message].length) {
        NSLog(@"%s--%d|收到邀请|",__func__,__LINE__);
//        NSLog(@"%@",message.from.user);
        self.groupName = message.from.user;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@邀请你加入%@",[self isChatRoomInvite:message],self.groupName] delegate:self cancelButtonTitle:nil otherButtonTitles:@"我知道了",nil];
        alertView.tag = 2;
        [alertView show];
        
        //群聊邀请
        NSString *roomId = [NSString stringWithFormat:@"%@@%@",self.groupName, XMPP_GROUPSERVICE];
        XMPPJID *roomJID = [XMPPJID jidWithString:roomId];
        XMPPRoomMemoryStorage *xmppRoomStorage = [[XMPPRoomMemoryStorage alloc] init];
        XMPPRoom *xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:xmppRoomStorage jid:roomJID dispatchQueue:dispatch_get_main_queue()];
        [xmppRoom activate:[XmppTools sharedManager].xmppStream];
        [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [xmppRoom joinRoomUsingNickname:[XmppTools sharedManager].xmppStream.myJID.user history:nil password:nil];
    }
}
#pragma mark -- 危险写法 以后改
-(NSString *)isChatRoomInvite:(XMPPMessage *)message{
    if (message.childCount>0){
        for (NSXMLElement* element in message.children) {
            if ([element.name isEqualToString:@"x"] && [element.xmlns isEqualToString:@"http://jabber.org/protocol/muc#user"]){
                for (NSXMLElement* element_a in element.children) {
                    if ([element_a.name isEqualToString:@"invite"]){
                        NSRange range = [element_a.prettyXMLString rangeOfString:@"\""];
                        NSRange range2 = [element_a.prettyXMLString rangeOfString:@"@"];
                        NSString *string = [element_a.prettyXMLString substringWithRange:NSMakeRange(range.location + 1, range2.location - range.location - 1)];
                        return string;
                    }
                }
            }
        }
    }
    return @"";
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error{
    
}
- (NSData*)getCurUserImageData
{
    XMPPJID *jid = [XMPPJID jidWithString:[self idAndHost:self.userName] resource:XMPP_PLATFORM];
    NSData *photoData = [[self avatarModule] photoDataForJID:jid];
    return photoData;
}
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    NSLog(@"\niq:%@\n",iq.type);
    NSLog(@"iqType:%@ %s %d",iq.type,__func__,__LINE__);
//    NSLog(@"%@",iq);
    // 以下两个判断其实只需要有一个就够了
    NSString *elementID = iq.elementID;
    if (![elementID isEqualToString:@"getMyRooms"]) {
        return YES;
    }
    
    NSArray *results = [iq elementsForXmlns:@"http://jabber.org/protocol/disco#items"];
    if (results.count < 1) {
        return YES;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    for (DDXMLElement *element in iq.children) {
        if ([element.name isEqualToString:@"query"]) {
            for (DDXMLElement *item in element.children) {
                if ([item.name isEqualToString:@"item"]) {
                    [array addObject:item];          //array  就是你的群列表
                    
                }
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_GET_GROUPS object:array];
    return YES;
}
//邀请好友
- (void)inviteUser:(NSString *)jidStr toRoom:(XMPPRoom *)room withMessage:(NSString *)message{
    XMPPJID * jid = [XMPPJID jidWithString:jidStr];
    [room inviteUser:jid withMessage:message];
}
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
    NSLog(@"%@",message.type);
    NSLog(@"%@",message.body);
    NSLog(@"%s",__func__);
}
/**
 * 更改密码  ------ 暂时未修改成功
 */
- (void)changePassworduseWord:(NSString *)checkPassword withUser:(NSString*)userName
{
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:register"];
    NSXMLElement *msgXml = [NSXMLElement elementWithName:@"iq"];
    [msgXml addAttributeWithName:@"type" stringValue:@"set"];
    [msgXml addAttributeWithName:@"to" stringValue:XMPP_HOST];//serverip];
    [msgXml addAttributeWithName:@"id" stringValue:@"change1"];
    DDXMLNode *username=[DDXMLNode elementWithName:@"username" stringValue:userName];//不带@后缀
    DDXMLNode *password=[DDXMLNode elementWithName:@"password" stringValue:checkPassword];//要改的密码
    [query addChild:username];
    [query addChild:password];
    [msgXml addChild:query];
    NSLog(@"%@",msgXml);
    [self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:nil];
    [self.xmppStream sendElement:msgXml];
}

@end
