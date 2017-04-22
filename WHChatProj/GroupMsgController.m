//
//  GroupMsgController.m
//  WHChatProj
//
//  Created by 行政 on 17/4/18.
//  Copyright © 2017年 lieo. All rights reserved.
//

#import "GroupMsgController.h"
#import "VCMsgesCell.h"
#import "WPToolBarView.h"
#import "VCChatCell.h"
#import <XMPPFramework/XMPPRoomCoreDataStorage.h>
#import <MediaPlayer/MediaPlayer.h>//播放语音
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "InviteUserViewController.h"
@interface GroupMsgController ()<UITableViewDelegate,UITableViewDataSource,WPToolBarDataDelegate,UIPickerViewDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) NSInteger curIndex;//记录cell下标 用作判断是语音还是图片
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, weak) WPToolBarView *toolView;
@property (nonatomic, assign) BOOL keyBoardStatus;
@property (nonatomic, strong) UIImageView *fullImageView;
@end

@implementation GroupMsgController

- (void)addRightBtn{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"邀请好友" style:UIBarButtonItemStylePlain target:self action:@selector(inviteFriend)];
}
- (void)inviteFriend{
    NSLog(@"%s",__func__);
    InviteUserViewController *invite = [[InviteUserViewController alloc]init];
    invite.currentRoom = self.room;
    UINavigationController *naVC = [[UINavigationController alloc]initWithRootViewController: invite];
    [self.navigationController presentViewController:naVC animated:YES completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addRightBtn];
    self.title = self.room.roomJID.user;
    [self.view addSubview:_table];
    
//    XMPPRoomMessageCoreDataStorageObject *rosterstorage = [[XMPPRoomMessageCoreDataStorageObject alloc]init];
//    _room = [[XMPPRoom alloc]initWithRoomStorage:rosterstorage jid:self.jid dispatchQueue:dispatch_get_main_queue()];
//    [_room activate:[XmppTools sharedManager].xmppStream];
    
    WPToolBarView * toolView = [[WPToolBarView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height -50, [UIScreen mainScreen].bounds.size.width, 50) viewController:self];
    toolView.delegate = self;
    _toolView = toolView;
    [self.view addSubview:self.tableView];
    [self.view addSubview:_toolView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[XmppTools sharedManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self reloadMessages];
    self.automaticallyAdjustsScrollViewInsets = NO;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    XMPPMessageArchiving_Message_CoreDataObject *msg = [self.dataSource objectAtIndex:indexPath.row];
    return [VCChatCell calHeight:msg];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifider = @"VCChatCell";
    VCChatCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifider];
    XMPPMessageArchiving_Message_CoreDataObject *msg = [self.dataSource objectAtIndex:indexPath.row];
//    NSLog(@"%s__%d|%@",__func__,__LINE__,msg.body);
    NSLog(@"%s__%d|%@",__func__,__LINE__,msg);
    cell.isGoupChat = YES;
    [cell loadData:msg];
    cell.index = indexPath.row;
    __weak GroupMsgController *weakSelf = self;
    cell.touchCellIndex = ^(NSInteger index ,UITapGestureRecognizer *sender){
        XMPPRoomMessageCoreDataStorageObject *msg = [weakSelf.dataSource objectAtIndex:index];
        if ([msg.body isEqualToString:@"[语音]"]) {
            NSString *voiceBody = [msg.message attributeStringValueForName:@"timeBody"];
            NSData *data = [[NSData alloc]initWithBase64EncodedString:voiceBody options:NSDataBase64DecodingIgnoreUnknownCharacters];
            [weakSelf playWithData:data];
        }else if ([msg.body isEqualToString:@"[图片]"]){
            NSString *imageBody = [msg.message attributeStringValueForName:@"imgBody"];
            NSData *data = [[NSData alloc]initWithBase64EncodedString:imageBody options:NSDataBase64DecodingIgnoreUnknownCharacters];
            [weakSelf showImageWithData:data TapSender:sender];
        }
    };
    return cell;
}

/**
 * 重新获取历史记录
 */
- (void)reloadMessages{
    NSManagedObjectContext *context = [XmppTools sharedManager].messageArchivingCoreDataStorage.mainThreadManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
//    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"XMPPRoomMessageCoreDataStorageObject"];
    //创建查询条件
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@ and streamBareJidStr = %@ and roomJID = ", self.toUser.bare, [XmppTools sharedManager].userJid.bare,self._room];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ and roomJID = %@", [XmppTools sharedManager].userJid.bare,self.room.roomJID];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"roomJID = %@",self.room.roomJID];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@ and streamBareJidStr = %@",self.room.roomJID,[XmppTools sharedManager].userJid.bare];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    //    fetchRequest.fetchOffset = 0;
    //    fetchRequest.fetchLimit = 10;
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if(fetchedObjects.count > 0){
        if (self.dataSource != nil) {
            if ([self.dataSource count] > 0) {
                [self.dataSource removeAllObjects];
            }
            [self.dataSource addObjectsFromArray:fetchedObjects];
            [self reload];
        }
    }
}

#pragma mark - Message

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self reloadMessages];
    });
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error{
    NSLog(@"%s__%d|发送失败",__func__,__LINE__);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    
    if (message.body) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self reloadMessages];
        });
        
        UILocalNotification *noti = [[UILocalNotification alloc] init];
        [noti setAlertBody:message.body];
        [[UIApplication sharedApplication] presentLocalNotificationNow:noti];
        
    }
}

- (void)reload {
    [self.tableView reloadData];
    [self scrollToBottom];
}


-(void)scrollToBottom {
    if (self.dataSource.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSource.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - ChatInputViewDelegate
-(void)send:(NSString *)msg {
    if (![msg isEqualToString:@""]) {
        XMPPMessage *message = [XMPPMessage messageWithType:CHATTYPEGROUP to:self.room.roomJID];
//        XMPPMessage *message = [[XMPPMessage alloc]initWithType:@"groupchat" to:self.room.roomJID];
        [message addAttributeWithName:@"bodyType" stringValue:[NSString stringWithFormat:@"%d",TEXT]];
        [message addAttributeWithName:@"type" stringValue:@"groupchat"];

        [message addBody:msg];
        [[XmppTools sharedManager].xmppStream sendElement:message];
    }
}
-(void)sendImageDataDic:(NSDictionary *)dic{
    UIImage *image = dic[UIImagePickerControllerOriginalImage];
    NSData *data = UIImageJPEGRepresentation(image,0.3);
    [self sendMessageWithData:data bodyName:@"[图片]"];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)recordFinish:(NSURL *)url withTime:(float)time {
    self.url = url;
    NSData *data = [[NSData alloc]initWithContentsOfURL:self.url];
    [self sendRecordMessageWithData:data bodyName:@"[语音]" withTime:time];
}

//选择图片
- (void)selectImg {
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}
- (void)disMissKeyBoardDelegate{
    //    [self dismiss];//收起键盘
    //    self.tableView.frame = CGRectMake(0, 64, DEVICEWIDTH,  DEVICEHEIGHT - 64 - 50);
}
- (void)popUpMoreFuncViewDelegate{
    [self.view resignFirstResponder];
}

/** 发送图片 */
- (void)sendMessageWithData:(NSData *)data bodyName:(NSString *)name {
    NSString *base64str = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    XMPPMessage *message = [XMPPMessage messageWithType:CHATTYPEGROUP to:self.room.roomJID];
    [message addAttributeWithName:@"bodyType" stringValue:[NSString stringWithFormat:@"%d",IMAGE]];
    [message addAttributeWithName:@"imgBody" stringValue:base64str];
    [message addBody:name];
    [[XmppTools sharedManager].xmppStream sendElement:message];
}

/** 发送录音 */
- (void)sendRecordMessageWithData:(NSData *)data bodyName:(NSString *)name withTime:(float)time {
    NSString *base64str = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    XMPPMessage *message = [XMPPMessage messageWithType:CHATTYPEGROUP to:self.room.roomJID];
    [message addAttributeWithName:@"bodyType" stringValue:[NSString stringWithFormat:@"%d",RECORD]];
    [message addAttributeWithName:@"time" stringValue:[NSString stringWithFormat:@"%f",time]];
    [message addAttributeWithName:@"timeBody" stringValue:base64str];
    [message addBody:name];
    [[XmppTools sharedManager].xmppStream sendElement:message];
}

#pragma mark - 监听事件
- (void) keyboardWillChangeFrame:(NSNotification *)note{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.tableView scrollToBottom];
    });
}
- (void)dealloc{
    NSLog(@"%s",__func__);
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [self.toolView removeFromSuperview];
//    self.toolView = nil;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
}

- (void)playWithData:(NSData *)data{
    NSError *error;
    self.player = [[AVAudioPlayer alloc]initWithData:data fileTypeHint:@"" error:&error];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    if (!error) [self.player play];
}
- (void)showImageWithData:(NSData *)data TapSender:(UITapGestureRecognizer *)sender{
    UIImage *imageData = [UIImage imageWithData:data];
    self.fullImageView = [[UIImageView alloc]initWithImage:imageData];
    self.fullImageView.userInteractionEnabled = YES;
    [self.fullImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap2:)]];
    self.fullImageView.frame = CGRectMake(kScreenWidth/2-100, kScreenHeight/2-100, 200, 200);
    self.fullImageView.backgroundColor = [UIColor blackColor];
    [[UIApplication sharedApplication].keyWindow addSubview:self.fullImageView];
    self.fullImageView.contentMode = UIViewContentModeScaleAspectFit;
    [UIView animateWithDuration:.3 animations:^{
        self.fullImageView.frame = [UIScreen mainScreen].bounds;
    }];
}
- (void)actionTap2:(UITapGestureRecognizer *)tap{
    [UIView animateWithDuration:0.2 animations:^{
        self.fullImageView.frame = CGRectMake(kScreenWidth/2-100, kScreenHeight/2-100, 200, 200);
        self.fullImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [_fullImageView removeFromSuperview];
    }];
    [UIApplication sharedApplication].statusBarHidden = NO;
}
- (UITableView*)tableView{
    if (!_table) {
        _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 50 -64) style:UITableViewStyleGrouped];
        _table.delegate = self;
        _table.dataSource = self;
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        _table.backgroundColor = [UIColor whiteColor];
        [_table registerClass:[VCChatCell class] forCellReuseIdentifier:@"VCChatCell"];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
        [_table addGestureRecognizer:tap];
    }
    return _table;
}

- (void)tap{
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:WPBiaoQingWillHidden object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:WPMoreWillHidden object:nil];
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
- (AVAudioPlayer *)player {
    if (_player == nil) {
        _player = [[AVAudioPlayer alloc] init];
        _player.volume = 1.0; // 默认最大音量
    }
    return _player;
}



@end
