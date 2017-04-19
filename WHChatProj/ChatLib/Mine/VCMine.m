//
//  VCMeTab.m
//  LifeChat
//
//  Created by simple on 16/4/23.
//  Copyright © 2016年 com.sean. All rights reserved.
//

#import "VCMine.h"
#import "CellUserImg.h"

@interface VCMine ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) UITableView *table;
@property (nonatomic,weak)UIImagePickerController *picker;
@end

@implementation VCMine

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的";
    [self.view addSubview:self.table];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.table reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 70*RATIO_WIDHT320;
    }else{
        return 40*RATIO_WIDHT320;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *identifier = @"CellUserImg";
        CellUserImg *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[CellUserImg alloc]init];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell updateData:[XmppTools sharedManager].userName];
        return cell;
        
    }
//    else if (indexPath.section == 1){
//        static NSString *identifier = @"CellMeAction";
//        CellMeAction *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//        if (!cell) {
//            cell = [[CellMeAction alloc]init];
//        }
//        [cell updateData:@"我的二维码" andIcon:@"QrIcon"];
//        return cell;
//    }else if (indexPath.section == 2){
//        static NSString *identifier = @"CellMeAction";
//        CellMeAction *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//        if (!cell) {
//            cell = [[CellMeAction alloc]init];
//        }
//        [cell updateData:@"设置" andIcon:@"SettingIcon"];
//        return cell;
//    }
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];// 取消选中
    

    // 显示图片选择器
    [self presentViewController:self.picker animated:YES completion:nil];

//    if(indexPath.section == 0){
//        VCPhoto *vc = [[VCPhoto alloc]init];
//        vc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:vc animated:TRUE];
//    }else if (indexPath.section == 1) {
//        VCQr *vc = [[VCQr alloc]init];
//        vc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:vc animated:TRUE];
//    }else if (indexPath.section == 2) {
//        VCSetting *vc = [[VCSetting alloc]init];
//        vc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:vc animated:TRUE];
//    }
}
-(UIImagePickerController *)picker{
    if (_picker)return _picker;
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    return _picker;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    // 获取图片 设置图片
    UIImage *image = info[UIImagePickerControllerEditedImage];
    // 隐藏当前模态窗口
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // 更新到服务器
    XMPPvCardTemp *myvCard = [XmppTools sharedManager].xmppvCardModule.myvCardTemp;
    myvCard.photo = UIImageJPEGRepresentation(image, 0.02);
    [[XmppTools sharedManager].xmppvCardModule updateMyvCardTemp:myvCard];
}


#pragma mark - geter seter
- (UITableView*)table{
    if (!_table) {
        _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICEWIDTH, DEVICEHEIGHT) style:UITableViewStyleGrouped];
        _table.delegate = self;
        _table.dataSource = self;
    }
    return _table;
}
@end
