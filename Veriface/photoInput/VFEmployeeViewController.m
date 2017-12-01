//
//  VFEmployeeViewController.m
//  Veriface
//
//  Created by tang tang on 2017/11/30.
//  Copyright © 2017年 tang tang. All rights reserved.
//
#import "VFEmployeeViewController.h"
#import "VFFrontViewController.h"

@interface VFEmployeeViewController ()

@property (nonatomic, strong) UIView *centerView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UITextField *nameTextFiled;
@property (nonatomic, strong) UITextField *employeeIDTextFiled;
@property (nonatomic, strong) UILabel *employeeIDLabel;
@property (nonatomic, strong) UIButton *confrimBtn;
@property (nonatomic, strong) UIButton *cancleBtn;

@end

@implementation VFEmployeeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"信息录入";
    
    UIBarButtonItem *item =[[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonSystemItemCancel target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = item;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.centerView = [[UIView alloc]initWithFrame:CGRectZero];
    self.centerView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.centerView];
    [self.centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(100);
        make.right.equalTo(self.view).with.offset(-100);
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(200);
        make.height.mas_equalTo(300);
    }];
    
    self.nameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    self.nameLabel.text = @"姓名";
    self.nameLabel.font = [UIFont systemFontOfSize:22];
    [self.centerView addSubview:self.nameLabel];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.centerView).with.offset(20);
        make.width.mas_equalTo(80);
        make.top.equalTo(self.centerView).with.offset(20);
        make.height.mas_equalTo(50);
    }];
    
    self.nameTextFiled = [[UITextField alloc]initWithFrame:CGRectZero];
    self.nameTextFiled.backgroundColor = [UIColor whiteColor];
    self.nameTextFiled.font = [UIFont systemFontOfSize:22];
    [self.centerView addSubview:self.nameTextFiled];
    
    [self.nameTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.centerView).with.offset(20);
        make.left.equalTo(self.nameLabel.mas_right).with.offset(20);
        make.right.equalTo(self.centerView).with.offset(-20);
        make.height.mas_equalTo(50);
    }];
    
    self.employeeIDLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    self.employeeIDLabel.text = @"工号";
    self.employeeIDLabel.font = [UIFont systemFontOfSize:22];
    [self.centerView addSubview:self.employeeIDLabel];
    
    [self.employeeIDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.centerView).with.offset(20);
        make.width.mas_equalTo(80);
        make.top.equalTo(self.centerView).with.offset(90);
        make.height.mas_equalTo(50);
    }];
    
    self.employeeIDTextFiled = [[UITextField alloc]initWithFrame:CGRectZero];
    self.employeeIDTextFiled.backgroundColor = [UIColor whiteColor];
    self.employeeIDTextFiled.font = [UIFont systemFontOfSize:22];
    self.employeeIDTextFiled.keyboardType = UIKeyboardTypePhonePad;
    [self.centerView addSubview:self.employeeIDTextFiled];
    
    [self.employeeIDTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.centerView).with.offset(90);
        make.left.equalTo(self.nameLabel.mas_right).with.offset(20);
        make.right.equalTo(self.centerView).with.offset(-20);
        make.height.mas_equalTo(50);
    }];
    
    self.confrimBtn = [[UIButton alloc]initWithFrame:CGRectZero];
    [self.confrimBtn setTitle:@"确认" forState:UIControlStateNormal];
    [self.confrimBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.confrimBtn.backgroundColor = [UIColor blueColor];
    self.confrimBtn.layer.cornerRadius = 4.0f;
    self.confrimBtn.layer.masksToBounds = YES;
    [self.confrimBtn addTarget:self action:@selector(onConfirmClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.centerView addSubview:self.confrimBtn];
    
    [self.confrimBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.centerView).with.offset(50);
        make.bottom.equalTo(self.centerView).with.offset(-30);
        make.width.mas_offset(200);
        make.height.mas_equalTo(50);
    }];
    
    self.cancleBtn = [[UIButton alloc]initWithFrame:CGRectZero];
    [self.cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.cancleBtn.backgroundColor = [UIColor whiteColor];
    self.cancleBtn.layer.cornerRadius = 4.0f;
    self.cancleBtn.layer.masksToBounds = YES;
    [self.cancleBtn addTarget:self action:@selector(onCancleClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.centerView addSubview:self.cancleBtn];

    [self.cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.centerView).with.offset(-50);
        make.bottom.equalTo(self.centerView).with.offset(-30);
        make.width.mas_offset(200);
        make.height.mas_equalTo(50);
        
    }];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self clearUserDefaut];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)onConfirmClick:(UIButton *)btn
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if(self.nameTextFiled.text && self.nameTextFiled.text.length >0){
        [userDefaults setObject:self.nameTextFiled.text forKey:@"employeeName"];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"请填写员工姓名" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *nameAlert = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:nameAlert];
        
        UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
        popPresenter.sourceView = self.view;
        popPresenter.sourceRect = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1);
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    if(self.employeeIDTextFiled.text && self.employeeIDTextFiled.text.length >0){
        [userDefaults setObject:self.employeeIDTextFiled.text forKey:@"empoyeeID"];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"请填写员工ID" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *nameAlert = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:nameAlert];
        
        UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
        popPresenter.sourceView = self.view;
        popPresenter.sourceRect = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1);
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    [userDefaults synchronize];
    VFFrontViewController *front = [[VFFrontViewController alloc]init];
    [self.navigationController pushViewController:front animated:YES];
    
}

- (void)onCancleClick:(UIButton *)btn
{
    [self clearUserDefaut];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
//清除存储的用户name与ID
- (void)clearUserDefaut
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"employeeName"];
    [userDefaults removeObjectForKey:@"empoyeeID"];
    [userDefaults synchronize];
}

@end
