//
//  IDInfoViewController.h
//  IDCardRecognition
//
//  Created by tianxiuping on 2018/6/27.
//  Copyright © 2018年 XP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JYBDCardIDInfo.h"
#import "JYBDBankCardInfo.h"
@class JYBDCardIDInfo;

@interface IDInfoViewController : UIViewController

// 身份证信息
@property (nonatomic,strong) JYBDCardIDInfo *IDInfo;

// 身份证信息
@property (nonatomic,strong) JYBDBankCardInfo *cardInfo;

// 图像
@property (nonatomic,strong) UIImage *IDImage;

@end
