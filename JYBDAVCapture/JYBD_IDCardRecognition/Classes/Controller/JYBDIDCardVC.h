//
//  JYBDIDCardVC.h
//  JYBDAVCapture
//
//  Created by tianxiuping on 2018/8/22.
//  Copyright © 2018年 XP. All rights reserved.
//身份证识别（正反面都可以识别）无人脸识别

#import "JYBDScanCardBaseVC.h"
#import "JYBDScanCardManage.h"
#import "JYBDCardIDInfo.h"
@interface JYBDIDCardVC : JYBDScanCardBaseVC

@property (nonatomic,copy) void(^finish)(JYBDCardIDInfo * info,UIImage *image);

@end
