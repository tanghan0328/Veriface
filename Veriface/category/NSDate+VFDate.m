//
//  NSDate+VFDate.m
//  Veriface
//
//  Created by tang tang on 2017/12/1.
//  Copyright © 2017年 tang tang. All rights reserved.
//

#import "NSDate+VFDate.h"

@implementation NSDate (VFDate)

+ (NSString *)nowdateToString
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss  EEEE"];
    NSString *DateTime = [formatter stringFromDate:date];
    return DateTime;
}


@end
