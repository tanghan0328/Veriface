//
//  NSDate+VFDate.m
//  Veriface
//
//  Created by tang tang on 2017/12/1.
//  Copyright © 2017年 tang tang. All rights reserved.
//

#import "NSDate+VFDate.h"

@implementation NSDate (VFDate)

//获取当前时间 年月日 星期
+ (NSString *)nowdateToString
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd EEEE"];
    NSString *DateTime = [formatter stringFromDate:date];
    return DateTime;
}
//获取当前时间 时分秒
+ (NSString *)nowdateHHToString
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *DateTime = [formatter stringFromDate:date];
    return DateTime;
}

@end
