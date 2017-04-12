//
//  ViewController.m
//  WHChatProj
//
//  Created by 行政 on 17/4/12.
//  Copyright © 2017年 lieo. All rights reserved.
//

#import "ViewController.h"
#import "VCChat.h"

@interface ViewController ()

@property (nonatomic,strong)XMPPJID *jid;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[XmppTools sharedManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];

    [[XmppTools sharedManager] loginWithUser:@"messagetest" withPwd:@"123" withSuccess:^{
        NSLog(@"登陆成功");
       _jid = [XMPPJID jidWithString:@"localtest@127.0.0.1"];

    } withFail:^(NSString *error) {
        NSLog(@"登陆失败");
        
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    VCChat *chat =  [[VCChat alloc]init];
    chat.toUser = _jid;
    [self.navigationController pushViewController:chat animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
