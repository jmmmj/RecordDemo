//
//  AppDelegate.m
//  录音小demo
//
//  Created by HUST on 2021/1/21.
//

#import "AppDelegate.h"
#import "JMJTabBarController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController=[[JMJTabBarController alloc]init];
    [self.window makeKeyAndVisible];
    return YES;
}




@end
