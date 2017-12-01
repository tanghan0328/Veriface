//
//  NSTimer+VFUsingTimer.h
//  Veriface
//
//  Created by tang tang on 2017/12/1.
//  Copyright © 2017年 tang tang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (VFUsingTimer)

+ (NSTimer *)tw_scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                         block:(void(^)())block
                                       repeats:(BOOL)repeats;


@end
