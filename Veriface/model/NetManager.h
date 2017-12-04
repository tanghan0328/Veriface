//
//  NetManager.h
//  Veriface
//
//  Created by tang tang on 2017/11/30.
//  Copyright © 2017年 tang tang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetManager : NSObject

@property (nonatomic, strong) NSString *baseAPPURLString;

+ (instancetype)sharedManager;

//直接进行打卡
-(void)requestAuthFaceWithData:(NSData *)data
                      complete:(void (^)(id object, NSError *error))complete;

//确认打卡
-(void)requestAuthFaceWithResult:(BOOL) confirm
                      employeeID:(NSString *)employeeID
                      complete:(void (^)(id object, NSError *error))complete;

//录入员工面部信息
-(void)requestLoadFaceWithData:(NSData *)data
                          name:(NSString *)name
                    employeeID:(NSString *)employeeID
                   photoNumber:(int)photoNumber
                      complete:(void (^)(id object, NSError *error))complete;
@end
