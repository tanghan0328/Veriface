//
//  AppDelegate.m
//  Veriface
//
//  Created by tang tang on 2017/11/24.
//  Copyright © 2017年 tang tang. All rights reserved.
//

#import "AppDelegate.h"
#import "VFVeriFaceController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    VFVeriFaceController *vf = [[VFVeriFaceController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vf];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {

}


- (void)applicationDidBecomeActive:(UIApplication *)application {

}


- (void)applicationWillTerminate:(UIApplication *)application {
}


@end
