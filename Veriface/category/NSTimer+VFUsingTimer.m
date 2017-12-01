//
//  NSTimer+VFUsingTimer.m
//  Veriface
//
//  Created by tang tang on 2017/12/1.
//  Copyright © 2017年 tang tang. All rights reserved.
//

#import "NSTimer+VFUsingTimer.h"

@implementation NSTimer (VFUsingTimer)

+ (NSTimer *)tw_scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                         block:(void(^)())block
                                       repeats:(BOOL)repeats{
    
    return [self scheduledTimerWithTimeInterval:ti
                                         target:self
                                       selector:@selector(tw_blockInvoke:)
                                       userInfo:[block copy]
                                        repeats:repeats];
}

+ (void)tw_blockInvoke:(NSTimer *)timer{
    
    void(^block)() = timer.userInfo;
    if (block) {
        block();
    }
}

@end
