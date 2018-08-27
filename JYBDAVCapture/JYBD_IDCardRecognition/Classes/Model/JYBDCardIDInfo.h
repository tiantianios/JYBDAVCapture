//
//  JYBDCarIDInfo.h
//  JYBDAVCapture
//
//  Created by tianxiuping on 2018/6/26.
//  Copyright © 2018年 XP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JYBDCardIDInfo : NSObject

@property (nonatomic,assign) int type; //1:正面  2:反面
@property (nonatomic,copy) NSString *num; //身份证号
@property (nonatomic,copy) NSString *name; //姓名
@property (nonatomic,copy) NSString *gender; //性别
@property (nonatomic,copy) NSString *nation; //民族
@property (nonatomic,copy) NSString *address; //地址
@property (nonatomic,copy) NSString *issue; //签发机关
@property (nonatomic,copy) NSString *valid; //有效期


@end
