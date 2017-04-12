//
//  ChatInputView.m
//  MsgCell
//
//  Created by simple on 16/3/6.
//  Copyright © 2016年 luowei. All rights reserved.
//

#import "ChatInputView.h"


@implementation ChatInputView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        //输入文本框
        [self setBackgroundColor:RGB3(248)];
        
        UIView *line = [UIView new];
        [line setBackgroundColor:RGB(218, 220, 220)];
        line.frame = CGRectMake(0, 0, self.width, 1);
        [self addSubview:line];
        
        self.recordImg = [UIButton new];
        [self.recordImg setImage:[UIImage imageNamed:@"ChatRecordIcon"] forState:UIControlStateNormal];
        self.recordImg.frame = CGRectMake(5, (self.height-30)/2.0, 30, 30);
        
        [self.recordImg addTarget:self action:@selector(recordKeyboardChange) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.recordImg];
        
        faceView = [[FaceView alloc]initWithFrame:CGRectMake(0, 50, self.width, 200)];
        faceView.delegate = self;
        [self addSubview:faceView];
        
        inputText = [UITextView new];
        inputText.frame = CGRectMake(self.recordImg.right+5, self.recordImg.top, self.width-(self.recordImg.right+5)-75, 30);
        inputText.layer.borderColor = RGB(218, 220, 220).CGColor;
        inputText.layer.borderWidth = 1;
        inputText.returnKeyType  = UIReturnKeySend;
        inputText.layer.cornerRadius = 6;
        inputText.delegate = self;
        [self addSubview:inputText];
        
        self.btnRecord = [UIButton new];
        [self.btnRecord setTitle:@"按住说话" forState:UIControlStateNormal];
        [self.btnRecord setTitle:@"松开结束" forState:UIControlStateHighlighted];
        self.btnRecord.frame = CGRectMake(inputText.left, inputText.top, inputText.width, inputText.height);
        self.btnRecord.layer.borderColor = RGB(218, 220, 220).CGColor;
        self.btnRecord.layer.borderWidth = 1;
        self.btnRecord.layer.cornerRadius = 6;
        self.btnRecord.hidden = TRUE;
        [self.btnRecord setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.btnRecord addTarget:self action:@selector(recordUpAction) forControlEvents:UIControlEventTouchUpInside];
//        [self.btnRecord addTarget:self action:@selector(recordDownAction) forControlEvents:UIControlEventTouchDown];
        UILongPressGestureRecognizer *presss = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressForRecord:)];
        [self.btnRecord addGestureRecognizer:presss];
        [self addSubview:self.btnRecord];
        
        UIImageView *faceImg = [UIImageView new];
        [faceImg setImage:[UIImage imageNamed:@"ChatFaceIcon"]];
        faceImg.frame = CGRectMake(inputText.right+5, self.recordImg.top, 30, 30);
        faceImg.userInteractionEnabled = TRUE;
        UITapGestureRecognizer *faceTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showFaceAction)];
        [faceImg addGestureRecognizer:faceTap];
        [self addSubview:faceImg];
        
        UIImageView *addImg = [UIImageView new];
        [addImg setImage:[UIImage imageNamed:@"ChatAddIcon"]];
        addImg.frame = CGRectMake(faceImg.right+5, self.recordImg.top, 30, 30);
        addImg.userInteractionEnabled = TRUE;
        UITapGestureRecognizer *addImgTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectImgAction)];
        [addImg addGestureRecognizer:addImgTap];
        [self addSubview:addImg];
        
        self.voiceHUDView.hidden = YES;
        faceData = [ChatInputView emojiDictionary];
        [[AVAudioSession sharedInstance]
         setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
    }
    return self;
}


+ (NSArray *)emojiDictionary {
    static NSArray *emojiDictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *emojiFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"expression_custom.plist"];
        emojiDictionary = [[NSArray alloc]initWithContentsOfFile:emojiFilePath];
    });
    return emojiDictionary;
}

-(id)init{
    return [self initWithFrame:CGRectMake(0, DEVICEWIDTH-50-NAV_STATUS_HEIGHT, DEVICEWIDTH, 50)];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        [self send];
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    return YES;
}

-(void)hide{
    [inputText endEditing:TRUE];
    [self hideFaceAnimation];
    self.isOpend = FALSE;
}

-(void)showFaceAction{
    if (!showFace) {
        [inputText endEditing:YES];
        [self showFaceAnimation];
        self.isOpend = TRUE;
    }
}

-(void)showFaceAnimation{
    [self setKeyboard];
    CGRect f = self.frame;
    f.size.height += faceView.height;
    self.frame = f;

    if ([self.delegate respondsToSelector:@selector(handleHeight:)]) {
        [self.delegate handleHeight:faceView.height];
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, -faceView.height);
    }completion:^(BOOL finished) {
        showFace = TRUE;
    }];
    
}


-(void)hideFaceAnimation{
    if (showFace) {
        CGRect f = self.frame;
        f.size.height -= faceView.frame.size.height;
        self.frame = f;
        [UIView animateWithDuration:0.3 animations:^{
            self.transform = CGAffineTransformMakeTranslation(0, 0);
        } completion:^(BOOL finished) {
            showFace = FALSE;
        }];
    }
    
}

-(void)selectFace:(int)faceTag{
    NSLog(@"Item %d",faceTag);
    if (faceTag <= 99) {
        inputText.text = [NSString stringWithFormat:@"%@%@",inputText.text,[faceData objectAtIndex:faceTag]];
    }
}

#pragma mark delegate代理
-(void)send{
    [self sendMsg:inputText.text];
    inputText.text = @"";
}

//发送事件1
-(void)sendMsg:(NSString *)msg{
    if ([self.delegate respondsToSelector:@selector(send:)]) {
        [self.delegate send:msg];
    }
}

//录音完成
-(void)recordUpAction{
    [self.recorder stop];
    self.recorder = nil;
    AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:self.url options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds =CMTimeGetSeconds(audioDuration);
    if (audioDurationSeconds >= 1) {
        if ([self.delegate respondsToSelector:@selector(recordFinish: withTime:)]) {
            [self.delegate recordFinish:self.url withTime:audioDurationSeconds];
        }
    }

}
- (void)changeImage
{
    NSLog(@"%s",__func__);
        
    [_recorder updateMeters];//更新测量值
    float avg = [_recorder averagePowerForChannel:0];
    float minValue = -60;
    float range = 60;
    float outRange = 100;
    if (avg < minValue)
    {
        avg = minValue;
    }
    float decibels = (avg + range) / range * outRange ;
    NSLog(@"%f",decibels);
    
    if (decibels<20) {
        [self.voiceHUDView.yinjieImageView setImage:[UIImage imageNamed:@"yinjie1@2x.png"]];
    }else if (decibels<40){
        [self.voiceHUDView.yinjieImageView setImage:[UIImage imageNamed:@"yinjie2@2x.png"]];
    }else if (decibels<50){
        [self.voiceHUDView.yinjieImageView setImage:[UIImage imageNamed:@"yinjie3@2x.png"]];
    }else if (decibels<60){
        [self.voiceHUDView.yinjieImageView setImage:[UIImage imageNamed:@"yinjie4@2x.png"]];
    }else if (decibels<70){
        [self.voiceHUDView.yinjieImageView setImage:[UIImage imageNamed:@"yinjie5@2x.png"]];
    }
}

- (void)longPressForRecord:(UILongPressGestureRecognizer *)press{
    
 
    self.voiceHUDView.hidden = NO;
    
    static BOOL bSend;
    switch (press.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            [self recordDownAction];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint currentPoint = [press locationInView:press.view];
            
            if (currentPoint.y < -50){
                self.voiceHUDView.recallImageView.hidden = NO;
                self.voiceHUDView.yinjieImageView.hidden = YES;
                self.voiceHUDView.voiceImageView.hidden = YES;
                self.voiceHUDView.msgLabel.text = @"松开手指 取消发送";
                bSend = NO;

            }else{
                bSend = YES;
                self.voiceHUDView.voiceImageView.hidden = NO;
                self.voiceHUDView.recallImageView.hidden = YES;
                self.voiceHUDView.yinjieImageView.hidden = NO;
                self.voiceHUDView.msgLabel.text = @"松开手指 立即发送";
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            if (bSend){
                [self recordUpAction];
            }else{
                [self.recorder stop];
                [self.recorder deleteRecording];
            }
            [_voiceHUDView removeAllSubviews];
            _voiceHUDView = nil;
            [_timer invalidate];
            break;
        }
        case UIGestureRecognizerStateFailed:
            NSLog(@"failed");
            break;
        default:
            break;
    }

}
//录音开始
-(void)recordDownAction{
    NSError *error = nil;
    
    //激活AVAudioSession
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (session != nil) {
        [session setActive:YES error:nil];
    }else {
        NSLog(@"session error: %@",error);
    }
    
    //设置AVAudioRecorder类的setting参数
    NSDictionary *recorderSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:16000.0],AVSampleRateKey,
                                      [NSNumber numberWithInt:kAudioFormatAppleIMA4],AVFormatIDKey,
                                      [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                                      [NSNumber numberWithInt:AVAudioQualityMax], AVEncoderAudioQualityKey,
                                      nil];
    
    //实例化AVAudioRecorder对象
    self.recorder = [[AVAudioRecorder alloc] initWithURL:self.url settings:recorderSettings error:&error];
    self.recorder.meteringEnabled = YES;
    if (error) {
        NSLog(@"recorder error: %@", error);
    }
    //开始录音
    [self.recorder record];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                              target:self
                                            selector:@selector(changeImage)
                                            userInfo:nil
                                             repeats:YES];
}

//键盘和录音切换
-(void)recordKeyboardChange{
    if (isKeyboard) {
        [self setKeyboard];
        [inputText becomeFirstResponder];
        self.isOpend = TRUE;
    }else{
        [self setRecord];
        self.isOpend = FALSE;
    }
}

-(void)setKeyboard{
    [self.recordImg setImage:[UIImage imageNamed:@"ChatRecordIcon"] forState:UIControlStateNormal];
    self.btnRecord.hidden = TRUE;
    inputText.hidden = FALSE;
    isKeyboard = FALSE;
}

- (void)setRecord{
    [inputText endEditing:FALSE];
    [self.recordImg setImage:[UIImage imageNamed:@"ChatKeyboardIcon"] forState:UIControlStateNormal];
    self.btnRecord.hidden = FALSE;
    inputText.hidden = TRUE;
    isKeyboard = TRUE;
    [self hide];
}

//删除表情
-(void)deleFace{
    NSString *content = inputText.text;
    if ([content length] > 0) {
        int length = 0;
        NSRange tail = [content rangeOfString:@"]" options:NSBackwardsSearch];
        if (tail.length > 0) {
            NSRange fore = [content rangeOfString:@"[" options:NSBackwardsSearch];
            
            length = (int)(tail.location - fore.location);
        }
        
        //判别查找到的字符串是否正确
        NSString *cccc = [inputText.text substringToIndex:[inputText.text length] - (length+1)];
        inputText.text = cccc;
    }
}

//选择图片
- (void)selectImgAction{
    if ([self.delegate respondsToSelector:@selector(selectImg)]) {
        [self.delegate selectImg];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if(showFace){
        [self hideFaceAnimation];
    }
    return  TRUE;
}


#pragma mark - FaceViewDelegate
- (void)selectFaceVoiw:(NSString *)face{
    inputText.text = [NSString stringWithFormat:@"%@%@",inputText.text,face];
}

- (void)sendActionWithBtn{
    [self send];
}

- (NSURL*)url{
    if (!_url) {
        NSString *tmpDir = NSTemporaryDirectory();
        NSString *urlPath = [tmpDir stringByAppendingString:@"record.caf"];
        _url = [NSURL fileURLWithPath:urlPath];
    }
    return _url;
}
- (VoiceHUDView *)voiceHUDView{
    if (!_voiceHUDView) {
        CGPoint point =  [UIApplication sharedApplication].keyWindow.center;
         VoiceHUDView *voiceView = [[[NSBundle mainBundle] loadNibNamed:@"VoiceHUDView" owner:self options:nil]firstObject];
            voiceView.frame = CGRectMake(point.x-100,point.y-100, 200, 200);
        voiceView.layer.cornerRadius = 10;
        voiceView.clipsToBounds = YES;
        voiceView.recallImageView.hidden = YES;
        _voiceHUDView = voiceView;
        [[UIApplication sharedApplication].keyWindow addSubview:_voiceHUDView];
    }
    return _voiceHUDView;
}
@end
