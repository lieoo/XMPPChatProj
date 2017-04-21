//
//  ViewController.m
//  WHChatProj
//
//  Created by 行政 on 17/4/12.
//  Copyright © 2017年 lieo. All rights reserved.
//

#import "MsgViewController.h"
#import "VCChat.h"
#import "VCMsgesCell.h"
#import "GroupMsgController.h"
#import "XMPPRoomMemoryStorage.h"
#import "XMPPMessageArchiving_Contact_CoreDataObject.h"
@interface MsgViewController ()<UITableViewDelegate,UITableViewDataSource,XMPPStreamDelegate>

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic,strong)XMPPJID *jid;

@end

@implementation MsgViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[XmppTools sharedManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self reloadContacts];
    self.tabBarController.tabBar.hidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息";
    [self.view addSubview:self.table];
}
- (NSMutableArray *)dataSource{
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

#pragma mark -- 这里群聊与私人聊天的区别在于 bareJid 是否含有服务器的名称
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    XMPPMessageArchiving_Contact_CoreDataObject *user = [self.dataSource objectAtIndex:indexPath.row]; 
    if (!([user.bareJidStr rangeOfString:XMPP_GROUPSERVICE].location == NSNotFound)) {
        GroupMsgController *groupVC = [[GroupMsgController alloc]init];
        XMPPRoomMemoryStorage *roomStorage = [[XMPPRoomMemoryStorage alloc] init];
        XMPPRoom *xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomStorage jid:user.bareJid dispatchQueue:dispatch_get_main_queue()];
        groupVC.room = xmppRoom;
        self.tabBarController.tabBar.hidden = YES;
        [self.navigationController pushViewController:groupVC animated:TRUE];
    }else{
        VCChat *vc = [[VCChat alloc]init];
        vc.toUser = user.bareJid;
        vc.title = user.bareJid.user;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:TRUE];
    }
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

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    if (message.body) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self reloadContacts];
        });
    }
}
- (void)dealloc{
    NSLog(@"MsgViewController dealloc");
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[XmppTools sharedManager].xmppStream removeDelegate:self];
}
- (void)reloadContacts{
    NSManagedObjectContext *context = [XmppTools sharedManager].messageArchivingCoreDataStorage.mainThreadManagedObjectContext;
    
    // 2.FetchRequest【查哪张表】
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Contact_CoreDataObject"];
    //创建查询条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@", [XmppTools sharedManager].userJid.bare];

    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"mostRecentMessageTimestamp" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if(!error && fetchedObjects.count > 0){
        
            if ([self.dataSource count] > 0) {
                [self.dataSource removeAllObjects];
            }
            [self.dataSource addObjectsFromArray:fetchedObjects];
        
        [self.table reloadData];
    }
}

@end
