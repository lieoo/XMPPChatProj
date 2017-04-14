//
//  WPToolBarView.m
//  wxDemo
//
//  Created by 吴鹏 on 16/7/25.
//  Copyright © 2016年 wupeng. All rights reserved.
//

#import "WPToolBarView.h"
//#import "WPContentLable.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>

@interface WPToolBarView ()<UITextViewDelegate,WPMoreViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,WPBiaoQingViewDelegate>
{
    BOOL isVoice;
    BOOL isBiaoQing;
    BOOL isMore;
}

@property (nonatomic , strong) UIButton * leftBtn;
@property (nonatomic , strong) UIButton * rightbtn1;
@property (nonatomic , strong) UIButton * rightbtn2;
@property (nonatomic , strong) WPTextView * textView;
@property (nonatomic , strong) WPBiaoqiangView * biaoQingView;
@property (nonatomic , strong) WPMoreView * moreView;

@property (nonatomic , strong) UIButton * voiceBtn;
@property (nonatomic , strong) UIViewController * viewController;

@end


@implementation WPToolBarView

- (id)initWithFrame:(CGRect)frame viewController:(UIViewController *)viewController
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.viewController = viewController;
        viewController.automaticallyAdjustsScrollViewInsets = NO;
        self.backgroundColor = UIColorFromRGB(0xececef);
        self.textView = [[WPTextView alloc]initWithFrame:CGRectMake(42, 7.5, self.frame.size.width - 122, 35) mainView:self];
        self.textView.delegate = self;
        self.biaoQingView = [[WPBiaoqiangView alloc]initWithBiaoQingFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 223) mainView:self];
        self.biaoQingView.delegate = self;
        self.moreView = [[WPMoreView alloc]initWithMoreFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 223) mainView:self];
        self.moreView.delegate = self;
        [self addSubview:self.textView];
        [self addSubview:self.leftBtn];
        [self addSubview:self.rightbtn1];
        [self addSubview:self.rightbtn2];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(baoqingHidden)
                                                     name:WPBiaoQingWillHidden
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moreHidden)
                                                     name:WPMoreWillHidden
                                                   object:nil];
    }
    return self;
}


#pragma mark - property

- (UIButton *)leftBtn
{
    if(!_leftBtn)
    {
        _leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(5, self.frame.size.height - 30 -10, 30,30)];
        [_leftBtn setBackgroundImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
        [_leftBtn addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _leftBtn;
}

- (UIButton *)rightbtn1
{
    if(!_rightbtn1)
    {
        _rightbtn1 = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 13 - 60, self.frame.size.height - 30 -10, 30,30)];
        [_rightbtn1 setBackgroundImage:[UIImage imageNamed:@"biaoqing"] forState:UIControlStateNormal];
        [_rightbtn1 addTarget:self action:@selector(rightbtn1Click) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _rightbtn1;
}
- (UIButton *)rightbtn2
{
    if(!_rightbtn2)
    {
        _rightbtn2 = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 5 -30, self.frame.size.height - 30 -10, 30,30)];
        [_rightbtn2 setBackgroundImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
        [_rightbtn2 addTarget:self action:@selector(rightbtn2Click) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _rightbtn2;
}

- (UIButton *)voiceBtn
{
    if(!_voiceBtn)
{
        _voiceBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, self.textView.frame.size.width, 35)];
        [_voiceBtn setTitle:@"按住 说话" forState:UIControlStateNormal];
        _voiceBtn.backgroundColor = UIColorFromRGB(0xececef);
        [_voiceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [_voiceBtn addTarget:self action:@selector(voiceBtn2Click) forControlEvents:UIControlEventTouchUpInside];
        _voiceBtn.layer.borderWidth = 0.5;
        _voiceBtn.layer.cornerRadius = 6;
        _voiceBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        UILongPressGestureRecognizer *presss = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressForRecord:)];
        [_voiceBtn addGestureRecognizer:presss];
        
    }
    return _voiceBtn;
}


#pragma mark - private

- (void)leftBtnClick
{
    if(!isVoice)
    {
        self.textView.alpha = 0;
        [self.leftBtn setBackgroundImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateNormal];
        [self addSubview:self.voiceBtn];
        [self endEditing:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:WPBiaoQingWillHidden object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:WPMoreWillHidden object:nil];
        [self.rightbtn1 setBackgroundImage:[UIImage imageNamed:@"biaoqing"] forState:UIControlStateNormal];
        self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 50, [UIScreen mainScreen].bounds.size.width, 50);
        isBiaoQing = NO;
        isMore = NO;
        
    }else
    {
        self.textView.alpha = 1;
        [self.leftBtn setBackgroundImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
        [self.textView becomeFirstResponder];
        [self.voiceBtn removeFromSuperview];
    }
    
    isVoice = !isVoice;
    [self configerViewControllerTableviewFram];
    
}

- (void)rightbtn1Click
{
    self.textView.alpha = 1;
    if(!isBiaoQing)
    {
        [self.viewController.view addSubview:self.biaoQingView];
        
        [self.rightbtn1 setBackgroundImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateNormal];
        [self.leftBtn setBackgroundImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter] postNotificationName:WPMoreWillHidden object:nil];
        [self endEditing:YES];
        [self.voiceBtn removeFromSuperview];
        [[NSNotificationCenter defaultCenter] postNotificationName:WPBiaoQingWillShow object:nil];
        [self.textView setNeedsDisplay];
        isVoice = NO;
        isMore = NO;
        isBiaoQing = YES;
        
    }else{
        [self.rightbtn1 setBackgroundImage:[UIImage imageNamed:@"biaoqing"] forState:UIControlStateNormal];
        [self.textView becomeFirstResponder];
        [self.biaoQingView removeFromSuperview];
        isBiaoQing = NO;
       
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"keyboardWillChangeFrame" object:nil];

    [self configerViewControllerTableviewFram];
    
}

- (void)rightbtn2Click
{
    
    self.textView.alpha = 1;
    if(!isMore)
    {
        [self.viewController.view addSubview:self.moreView];
        [[NSNotificationCenter defaultCenter] postNotificationName:WPBiaoQingWillHidden object:nil];
        [self endEditing:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:WPMoreWillShow object:nil];
        [self.leftBtn setBackgroundImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
        [self.rightbtn1 setBackgroundImage:[UIImage imageNamed:@"biaoqing"] forState:UIControlStateNormal];
        [self.voiceBtn removeFromSuperview];
        [self.textView setNeedsDisplay];
        isVoice = NO;
        isBiaoQing = NO;
        isMore = YES;
    }else
    {
        [self.textView becomeFirstResponder];
        [self.moreView removeFromSuperview];
        isMore = NO;
    }
    
    [self configerViewControllerTableviewFram];
}

//- (void)voiceBtn2Click
//{
//    
//}
- (void)changeImage {
    [_recorder updateMeters];//更新测量值
    float avg = [_recorder averagePowerForChannel:0];
    float minValue = -60;
    float range = 60;
    float outRange = 100;
    if (avg < minValue){
        avg = minValue;
    }
    float decibels = (avg + range) / range * outRange;
    
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
    bSend = YES;
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
            [_voiceHUDView removeFromSuperview];
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
    NSDictionary *recorderSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:16000.0],AVSampleRateKey,
                                      [NSNumber numberWithInt:kAudioFormatAppleIMA4],AVFormatIDKey,
                                      [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                                      [NSNumber numberWithInt:AVAudioQualityMax], AVEncoderAudioQualityKey,
                                      nil];
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

//录音完成
-(void)recordUpAction{
    [self.recorder stop];
    self.recorder = nil;
    [self.voiceHUDView removeAllSubviews];
    [self.voiceHUDView removeFromSuperview];
    AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:self.url options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds =CMTimeGetSeconds(audioDuration);
    if (audioDurationSeconds >= 1) {
        if ([self.delegate respondsToSelector:@selector(recordFinish: withTime:)]) {
            [self.delegate recordFinish:self.url withTime:audioDurationSeconds];
        }
    }
}
- (void)baoqingHidden{
    [self.rightbtn1 setBackgroundImage:[UIImage imageNamed:@"biaoqing"] forState:UIControlStateNormal];
    isBiaoQing = NO;
    [self configerViewControllerTableviewFram];
}

- (void)moreHidden{
    isMore = NO;
}

- (void)configerViewControllerTableviewFram
{
    for(UIView * view in self.viewController.view.subviews)
    {
        if([view isKindOfClass:[UITableView class]])
        {
            [UIView animateWithDuration:0.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 view.frame = CGRectMake(0,64, view.frame.size.width, self.frame.origin.y - 64);
                             } completion:nil];
        }
    }
}


#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    isBiaoQing = NO;
    isMore = NO;
    [self.moreView removeFromSuperview];
    [self.biaoQingView removeFromSuperview];
    [self.rightbtn1 setBackgroundImage:[UIImage imageNamed:@"biaoqing"] forState:UIControlStateNormal];
    [self configerViewControllerTableviewFram];

}

- (BOOL)textView: (UITextView *)textview shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]){
        if ([self.delegate respondsToSelector:@selector(send:)]) {
            [self.delegate send:self.textView.text];
            self.textView.text = @"";
        }
        return NO;
    }
    return YES;
}

#pragma mark - WPMoreViewDelegate

- (void)moreViewTreated:(NSInteger)treated{
    if(treated == 0){
        if (![self isPhotoLibraryAvailable])return;
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self.viewController presentViewController:imagePickerController animated:YES completion:nil];
    }
}


#pragma mark - imagepickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    if(self.delegate && [self.delegate respondsToSelector:@selector(sendImageDataDic:)]){
        [self.delegate sendImageDataDic:info];
    }
}
- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (VoiceHUDView *)voiceHUDView{
    if (_voiceHUDView == nil) {
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

- (NSURL*)url{
    if (!_url) {
        NSString *tmpDir = NSTemporaryDirectory();
        NSString *urlPath = [tmpDir stringByAppendingString:@"record.caf"];
        _url = [NSURL fileURLWithPath:urlPath];
    }
    return _url;
}
#pragma mark - biaoqingDelegate

- (void)WPbiaoQiongStr:(NSString *)str{
    self.textView.text = [NSString stringWithFormat:@"%@%@",self.textView.text,str];
}

@end
