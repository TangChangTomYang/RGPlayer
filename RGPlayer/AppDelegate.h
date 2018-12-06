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


/**
 
 AVFoundation.framework  音视频播放基本工具
 AudioToolbox.framework  音频控制API
 CoreGraphics.framework  轻量级2D渲染API
 CoreMedia.framework     音视频低级API
 CoreVideo.framework     视频低级API
 Foundation.framework    基本工具类
 MediaPlayer.framework   系统播放器接口
 OpenGLES.framework      3D图形渲染API
 QuartzCore.framework    视频渲染输出所需类
 libbz2.dylib            压缩工具
 libz.dylib              压缩工具
 libstdc++.dylib         C++ 标准库
 libiconv.dylib          字符编码转换工具
 */
