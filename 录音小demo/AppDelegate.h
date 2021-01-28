//
//  AppDelegate.h
//  录音小demo
//
//  Created by HUST on 2021/1/21.
//


//学习AVAudioPlayer、AvAudioRecorder，完成几个小demo
//
//- 做一个录音并能播放的demo，要求
//  - 使用UITabBarController，切换录制和播放界面
//  - 录制界面有录制开始、录制暂停；两个按钮，录制开始与结束按钮相互切换
//  - 播放界面有播放开始、播放暂停两个按钮
//  - 录制过程中，设置一个UIlabel，显示当前录制时间（计时器的使用）
//  - 录制结束后，点击播放，便可以播放
//  - 所有的UI设计采用代码布局

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic,strong)UIWindow *window;

@end

