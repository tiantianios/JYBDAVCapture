//
//  UIAlertController+IDCardExtend.h
//  JYBDAVCapture
//
//  Created by tianxiuping on 2018/6/27.
//  Copyright © 2018年 XP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (IDCardExtend)

// 创建AlertController
+(instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message okAction:(UIAlertAction *)okAction cancelAction:(UIAlertAction *)cancelAction;

// 创建ActionSheetController
+(instancetype)actionSheetControllerWithTitle:(NSString *)title message:(NSString *)message okAction:(UIAlertAction *)okAction cancelAction:(UIAlertAction *)cancelAction;

@end
