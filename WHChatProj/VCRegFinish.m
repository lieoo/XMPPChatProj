//
//  VCLogin.m
//  AtChat
//
//  Created by zhouMR on 16/11/1.
//  Copyright © 2016年 luowei. All rights reserved.
//

#import "VCRegFinish.h"
#import "VCTabbarController.h"

@interface VCRegFinish ()<UITextFieldDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) UIView *vPassword;
@property (nonatomic, strong) UIView *vConfirmPwd;
@property (nonatomic, strong) UIView *vUserName;
@property (nonatomic, strong) UITextField *tfPassword;
@property (nonatomic, strong) UITextField *tfConfirmPwd;
@property (nonatomic, strong) UITextField *tfUserName;
@property (nonatomic, strong) UIButton *btnLogin;
@end

@implementation VCRegFinish

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"用户注册";
    [self initUI];
}

- (void)initUI{
    [self.view addSubview:self.vUserName];
    [self.view addSubview:self.vPassword];
    [self.view addSubview:self.vConfirmPwd];
    [self.view addSubview:self.btnLogin];
}


#pragma mark - Event
- (void)loginAction{
    [self hideKeyboard];
    NSString *password = self.tfPassword.text;
    NSString *confirmPwd = self.tfConfirmPwd.text;
    
    NSString *message = nil;
    if (password.length < 3) {
        message = @"密码不能少于6位";
    } else if (confirmPwd.length < 6) {
        message = @"确认密码不能少于6位";
    } else if (![confirmPwd isEqualToString:password]) {
        message = @"密码不一致";
    }
    
    if (message.length > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
        [alertView show];
    } else {
        //登录
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"注册中...";
        [hud hideAnimated:YES afterDelay:3];
        [[XmppTools sharedManager] registerWithUser:self.tfUserName.text password:password withSuccess:^{
            [self hideMsg];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"注册成功" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
            alert.delegate = self;
            [alert show];
            [XmppTools sharedManager].xmppvCardModule.myvCardTemp.title = self.tfUserName.text;
            [[XmppTools sharedManager].xmppvCardModule updateMyvCardTemp:[XmppTools sharedManager].xmppvCardModule.myvCardTemp];
            
       } withFail:^(NSString *error) {
           [self hideMsg];
           UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"注册失败" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
           [alert show];
       }];
    }
}


#pragma mark - Getter Setter

- (UIView *)vUserName{
    if (_vUserName) return _vUserName;
    _vUserName = [[UIView alloc]initWithFrame:CGRectMake(10, 100, DEVICEWIDTH-20, 45)];
    _vUserName.layer.borderColor = BASE_COLOR.CGColor;
    _vUserName.layer.borderWidth = 1;
    _vUserName.layer.cornerRadius = 5;
    _vUserName.layer.masksToBounds = YES;
    [_vUserName addSubview:self.tfUserName];
    return _vUserName;
}
- (UIView *)vPassword{
    if (!_vPassword) {
        _vPassword = [[UIView alloc]initWithFrame:CGRectMake(10, _vUserName.bottom+10, DEVICEWIDTH-20, 45)];
        _vPassword.layer.borderColor = BASE_COLOR.CGColor;
        _vPassword.layer.borderWidth = 1;
        _vPassword.layer.cornerRadius = 5;
        _vPassword.layer.masksToBounds = YES;
        [_vPassword addSubview:self.tfPassword];
    }
    return _vPassword;
}

- (UIView *)vConfirmPwd{
    if (!_vConfirmPwd) {
        _vConfirmPwd = [[UIView alloc]initWithFrame:CGRectMake(10, self.vPassword.bottom+10, DEVICEWIDTH-20, 45)];
        _vConfirmPwd.layer.borderColor = BASE_COLOR.CGColor;
        _vConfirmPwd.layer.borderWidth = 1;
        _vConfirmPwd.layer.cornerRadius = 5;
        _vConfirmPwd.layer.masksToBounds = YES;
        [_vConfirmPwd addSubview:self.tfConfirmPwd];
    }
    return _vConfirmPwd;
}
- (UITextField *)tfUserName{
    if (_tfUserName) return _tfUserName;
    _tfUserName = [[UITextField alloc]initWithFrame:CGRectMake(10, 2.5, DEVICEWIDTH-40, 40)];
    _tfUserName.placeholder = @"请输入用户名";
    _tfUserName.keyboardType = UIKeyboardTypeDefault;
    _tfUserName.delegate = self;
    return _tfUserName;
}
- (UITextField *)tfPassword{
    if (!_tfPassword) {
        _tfPassword = [[UITextField alloc]initWithFrame:CGRectMake(10, 2.5, DEVICEWIDTH-40, 40)];
        _tfPassword.placeholder = @"请输入密码";
        _tfPassword.secureTextEntry = YES;
        _tfPassword.delegate = self;
    }
    return _tfPassword;
}


- (UITextField *)tfConfirmPwd{
    if (!_tfConfirmPwd) {
        _tfConfirmPwd = [[UITextField alloc]initWithFrame:CGRectMake(10, 2.5, DEVICEWIDTH-40, 40)];
        _tfConfirmPwd.placeholder = @"确认密码";
        _tfConfirmPwd.secureTextEntry = YES;
        _tfConfirmPwd.delegate = self;
    }
    return _tfConfirmPwd;
}

- (UIButton*)btnLogin{
    if (!_btnLogin) {
        _btnLogin = [[UIButton alloc]initWithFrame:CGRectMake(10, self.vConfirmPwd.bottom+10, DEVICEWIDTH-20, 45)];
        _btnLogin.backgroundColor = BASE_COLOR;
        [_btnLogin setTitle:@"注册" forState:UIControlStateNormal];
        [_btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnLogin.layer.cornerRadius = 5;
        _btnLogin.layer.masksToBounds = YES;
        [_btnLogin addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnLogin;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self.navigationController popToRootViewControllerAnimated:TRUE];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self hideKeyboard];
}

- (void)hideKeyboard{
    [self.tfPassword resignFirstResponder];
    [self.tfConfirmPwd resignFirstResponder];
}

- (void)hideMsg{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
@end
