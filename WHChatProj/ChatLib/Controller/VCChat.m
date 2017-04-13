//
//  VCChat.m
//  AtChat
//
//  Created by zhouMR on 16/11/2.
//  Copyright © 2016年 luowei. All rights reserved.
//

#import "VCChat.h"
#import "Message.h"
#import "VCChatCell.h"
#import "ChatInputView.h"
#import "WPToolBarView.h"

#import <MediaPlayer/MediaPlayer.h>//播放语音

@interface VCChat ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,XMPPStreamDelegate,WPToolBarDataDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) ChatInputView *inputText;
@property (nonatomic, assign) NSInteger curIndex;//记录cell下标 用作判断是语音还是图片
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, assign) BOOL keyBoardStatus;

@end

@implementation VCChat

- (void)viewDidLoad {
    [super viewDidLoad];
    

    WPToolBarView * toolview = [[WPToolBarView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height -50, [UIScreen mainScreen].bounds.size.width, 50) viewController:self];
    toolview.delegate = self;
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:toolview];

    
//    [self.view addSubview:self.inputText];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[XmppTools sharedManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self reloadMessages];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    XMPPMessageArchiving_Message_CoreDataObject *msg = [self.dataSource objectAtIndex:indexPath.row];
    return [VCChatCell calHeight:msg];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    VCChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VCChatCell"];
    XMPPMessageArchiving_Message_CoreDataObject *msg = [self.dataSource objectAtIndex:indexPath.row];
    NSLog(@"%s__%d|%@",__func__,__LINE__,msg.body);
    [cell loadData:msg];
    cell.index = indexPath.row;
    cell.touchCellIndex = ^(NSInteger index){
        XMPPMessageArchiving_Message_CoreDataObject *msg = [self.dataSource objectAtIndex:index];
        NSLog(@"%@",msg.body);
        
        __weak VCChat *weakSelf = self;
        if ([msg.body isEqualToString:@"[语音]"]) {
            NSString *voiceBody = [msg.message attributeStringValueForName:@"timeBody"];
            NSLog(@"%@",voiceBody);
            NSData *data = [[NSData alloc]initWithBase64EncodedString:voiceBody options:NSDataBase64DecodingIgnoreUnknownCharacters];
            [weakSelf playWithData:data];
        }
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.inputText.isOpend) {
        [self hideInput];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.inputText.isOpend) {
        [self hideInput];
    }
}

/**
 * 重新获取历史记录
 */
- (void)reloadMessages{
    NSManagedObjectContext *context = [XmppTools sharedManager].messageArchivingCoreDataStorage.mainThreadManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    //创建查询条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@ and streamBareJidStr = %@", self.toUser.bare, [XmppTools sharedManager].userJid.bare];

    [fetchRequest setPredicate:predicate];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
//    fetchRequest.fetchOffset = 0;
//    fetchRequest.fetchLimit = 10;
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    NSLog(@"%@",fetchedObjects);
    
    
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

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    if (message.body) {
        NSLog(@"%s__%d|收到消息---%@",__func__,__LINE__,message.body);
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

- (void)hideInput {
    [self.inputText hide];
//    [self handleResetHeightWithMoreFuncView];
}

- (void)dismiss{
    if (self.inputText.isOpend) {
        [self hideInput];
    }
}

#pragma mark - ChatInputViewDelegate
-(void)send:(NSString *)msg {
    if (![msg isEqualToString:@""]) {
        XMPPMessage *message = [XMPPMessage messageWithType:CHATTYPE to:self.toUser];
        [message addAttributeWithName:@"bodyType" stringValue:[NSString stringWithFormat:@"%d",TEXT]];
        [message addBody:msg];
        [[XmppTools sharedManager].xmppStream sendElement:message];
    }
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
    [self dismiss];//收起键盘
    self.tableView.frame = CGRectMake(0, 64, DEVICEWIDTH,  DEVICEHEIGHT - 64 - 50);
}
- (void)popUpMoreFuncViewDelegate{
    [self.view resignFirstResponder];
//    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, DEVICEWIDTH, DEVICEHEIGHT - 64 - 50) style:UITableViewStylePlain];
//    [self resetHeightWithMoreFuncView:YES];
//    self.table.frame = CGRectMake(0, 64, DEVICEWIDTH, DEVICEHEIGHT - 64 - 80);

}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSData *data = UIImageJPEGRepresentation(image,0.3);
    [self sendMessageWithData:data bodyName:@"[图片]"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/** 发送图片 */
- (void)sendMessageWithData:(NSData *)data bodyName:(NSString *)name {
    // 转换成base64的编码
    NSString *base64str = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    XMPPMessage *message = [XMPPMessage messageWithType:CHATTYPE to:self.toUser];
    [message addAttributeWithName:@"bodyType" stringValue:[NSString stringWithFormat:@"%d",IMAGE]];
    [message addAttributeWithName:@"imgBody" stringValue:base64str];
    [message addBody:name];
    [[XmppTools sharedManager].xmppStream sendElement:message];
}

/** 发送录音 */
- (void)sendRecordMessageWithData:(NSData *)data bodyName:(NSString *)name withTime:(float)time {
    NSString *base64str = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    XMPPMessage *message = [XMPPMessage messageWithType:CHATTYPE to:self.toUser];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    [self handleResetHeightWithMoreFuncView];
}
//- (void)handleResetHeightWithMoreFuncView{
////    CGFloat height ;
////    if (!isHaveFuncView) {
////        height = DEVICEHEIGHT-NAV_STATUS_HEIGHT-self.inputText.height + 50;
////    }else{
////        height = DEVICEHEIGHT-NAV_STATUS_HEIGHT-self.inputText.height - 80;
////    }
//    [UIView animateWithDuration:0.3 animations:^{
////        self.table.height = height;
////        if (isHaveFuncView)self.inputText.frame =  CGRectMake(0, self.table.bottom, DEVICEWIDTH, 50);
//        
//        self.table.height = DEVICEHEIGHT - 64 - 50;
//        self.inputText.frame = CGRectMake(0, self.table.bottom, kScreenWidth, 60);
//    } completion:^(BOOL finished) {
//        [self scrollToBottom];
//    }];
//}

- (void)playWithData:(NSData *)data{
    NSError *error;
     self.player= [[AVAudioPlayer alloc]initWithData:data fileTypeHint:@"" error:&error];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    if (!error) [self.player play];
}

- (UITableView*)tableView{
    if (!_tableView) {
//        _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, DEVICEWIDTH, DEVICEHEIGHT - 64 - 50) style:UITableViewStylePlain];
//        [_table registerClass:[VCChatCell class] forCellReuseIdentifier:@"VCChatCell"];
//        _table.delegate = self;
//        _table.dataSource = self;
//        _table.backgroundColor = [UIColor cyanColor];
//        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
//        _table.backgroundColor = [UIColor clearColor];
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
//        [_table addGestureRecognizer:tap];
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 50 -64) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor whiteColor];
        [_tableView registerClass:[VCChatCell class] forCellReuseIdentifier:@"VCChatCell"];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
        [_tableView addGestureRecognizer:tap];
    }
    return _tableView;
}

- (void)tap
{
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:WPBiaoQingWillHidden object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:WPMoreWillHidden object:nil];
}


- (ChatInputView*)inputText{
    if (!_inputText) {
        _inputText = [[ChatInputView alloc]initWithFrame:CGRectMake(0, self.tableView.bottom, DEVICEWIDTH, 50)];
        _inputText.delegate = self;
    }
    return _inputText;
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
