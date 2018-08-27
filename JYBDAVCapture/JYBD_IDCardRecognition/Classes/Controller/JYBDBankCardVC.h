//
//  JYBDBankCardVC.h
//  JYBDAVCapture
//
//  Created by tianxiuping on 2018/7/26.
//  Copyright © 2018年 XP. All rights reserved.
//银行卡扫描

#import <UIKit/UIKit.h>
#import "JYBDBankCardInfo.h"
#import "JYBDScanCardBaseVC.h"
#import "JYBDScanCardManage.h"
@interface JYBDBankCardVC : JYBDScanCardBaseVC

@property (nonatomic,copy) void(^finish)(JYBDBankCardInfo * info,UIImage *image);



@end
