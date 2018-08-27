//
//  JYBDScanCardBaseVC.m
//  JYBDAVCapture
//
//  Created by tianxiuping on 2018/7/26.
//  Copyright © 2018年 XP. All rights reserved.
//

#import "JYBDScanCardBaseVC.h"

@interface JYBDScanCardBaseVC ()

@end

@implementation JYBDScanCardBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addCloseButton];
}

#pragma mark - 添加关闭按钮
-(void)addCloseButton {
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    UIImage *image = [UIImage imageNamed:@"idcard_back" inBundle:[IDCardRectManager getImageBundle] compatibleWithTraitCollection:nil];
    UIImage *image = [UIImage imageNamed:@"idcard_back"];
    [closeBtn setImage:image forState:UIControlStateNormal];
    CGFloat closeBtnWidth = 40;
    CGFloat closeBtnHeight = closeBtnWidth;
    CGRect viewFrame = self.view.frame;
    closeBtn.frame = (CGRect){CGRectGetMaxX(viewFrame) - closeBtnWidth-8, CGRectGetMaxY(viewFrame) - closeBtnHeight-8, closeBtnWidth, closeBtnHeight};
    
    [closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:closeBtn];
}

#pragma mark 绑定“关闭按钮”的方法
-(void)close {
    if (self.navigationController)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - view即将出现时
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 将AVCaptureViewController的navigationBar调为透明
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:0];
    
}

#pragma mark - view即将消失时
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 将AVCaptureViewController的navigationBar调为不透明
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:1];
  
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
