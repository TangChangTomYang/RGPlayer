//
//  AppDelegate.h
//  RGPlayer
//
//  Created by yangrui on 2018/11/12.
//  Copyright © 2018年 yangrui. All rights reserved.
//  启动mac 本地server服务
// sudo apachectl -k restart

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end


/** 音乐播放的实现
 方案一: AVAudioPlayer 只能播放本地音乐不能播放远程的音乐, 操作简单
 方案二: AVPlayer 可以播放本地和远程音乐,操作较AVAudioPlayer复杂一点
 */
