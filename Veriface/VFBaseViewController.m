//
//  VFBaseViewController.m
//  Veriface
//
//  Created by tang tang on 2017/11/24.
//  Copyright © 2017年 tang tang. All rights reserved.
//

#import "VFBaseViewController.h"

@interface VFBaseViewController ()

@end

@implementation VFBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置状态栏变成白色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)initBack
{
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 45, 40);
    [btn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}



@end
