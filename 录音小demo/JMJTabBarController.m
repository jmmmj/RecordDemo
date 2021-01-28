//
//  JMJTabBarController.m
//  录音小demo
//
//  Created by HUST on 2021/1/21.
//

#import "JMJTabBarController.h"
#import "JMJRecordController.h"
#import "JMJPlayController.h"


@interface JMJTabBarController ()

@end

@implementation JMJTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIViewController* v1=[[JMJRecordController alloc]init];
    UIViewController* v2=[[JMJPlayController alloc]init];
    self.viewControllers=@[v1,v2];
    self.tabBar.items[0].title=@"录制";
    self.tabBar.items[1].title=@"播放";
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor blackColor],NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:20]}            forState:UIControlStateNormal];
    [self.tabBar setTintColor:[UIColor brownColor]];
    
}


@end
