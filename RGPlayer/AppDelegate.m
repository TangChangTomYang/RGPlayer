//
//  AppDelegate.m
//  RGPlayer
//
//  Created by yangrui on 2018/11/12.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


/** 监听远程控制事件(这个是响应者链中的方法, 只要是继承自 UIResponder ,重写即可)
 */
- (void)remoteControlReceivedWithEvent:(UIEvent *)event{
    /**
     远程事件类型定义
     typedef NS_ENUM(NSInteger, UIEventSubtype) {
     
     UIEventSubtypeNone // 不包含任何类型事件
     UIEventSubtypeMotionShake // 摇晃事件 (iOS3.0 开始支持)
     UIEventSubtypeRemoteControlPlay // 播放事件 (停止状态,按下耳机线控中间按钮一下)
     UIEventSubtypeRemoteControlPause // 暂停事件
     UIEventSubtypeRemoteControlStop //停止事件
     UIEventSubtypeRemoteControlTogglePlayPause // 播放或者暂停切换( 播放或暂停状态下, 按耳机线控中间按钮一下)
     UIEventSubtypeRemoteControlNextTrack //下一首(按耳机线控中间按钮2次)
     UIEventSubtypeRemoteControlPreviousTrack //上一首(按耳机线中间按钮3次)
     UIEventSubtypeRemoteControlBeginSeekingBackward // 快退开始(按耳机线控中间按钮3次不要松开)
     UIEventSubtypeRemoteControlEndSeekingBackward // 快退停止(按耳机线中间按钮3次到了快退的位置松开)
     UIEventSubtypeRemoteControlBeginSeekingForward //快进开始(按耳机线控中间按钮2次不松开)
     UIEventSubtypeRemoteControlEndSeekingForward   //快进停止 (按耳机线控中间按钮2次,到了快进位置松手)
     };
     */
    switch (event.subtype) {
            
            // 不包含任何操作
        case UIEventSubtypeNone : {
            NSLog(@"--------不包含任何操作");
        }break;
            
            // 摇晃事件
        case UIEventSubtypeMotionShake : {
            NSLog(@"--------摇晃事件");
        }break;
            
            //播放事件 (停止状态,按下耳机线控中间按钮一下)
        case  UIEventSubtypeRemoteControlPlay: {
            NSLog(@"--------播放事件 (停止状态,按下耳机线控中间按钮一下)");
        }break;
            
            //暂停事件
        case  UIEventSubtypeRemoteControlPause: {
            NSLog(@"--------暂停事件");
        }break;
            
            //停止事件
        case  UIEventSubtypeRemoteControlStop: {
            NSLog(@"--------停止事件");
        }break;
            
            //播放或者暂停切换( 播放或暂停状态下, 按耳机线控中间按钮一下)
        case  UIEventSubtypeRemoteControlTogglePlayPause: {
            NSLog(@"--------播放或者暂停切换( 播放或暂停状态下, 按耳机线控中间按钮一下)");
        }break;
            
            //下一首(按耳机线控中间按钮2次)
        case  UIEventSubtypeRemoteControlNextTrack: {
            NSLog(@"--------下一首(按耳机线控中间按钮2次)");
        }break;
            
            //上一首(按耳机线中间按钮3次)
        case  UIEventSubtypeRemoteControlPreviousTrack: {
            NSLog(@"--------上一首(按耳机线中间按钮3次)");
        }break;
            
            //快退开始(按耳机线控中间按钮3次不要松开)
        case  UIEventSubtypeRemoteControlBeginSeekingBackward: {
            NSLog(@"--------快退开始(按耳机线控中间按钮3次不要松开)");
        }break;
            
            //快退停止(按耳机线中间按钮3次到了快退的位置松开)
        case  UIEventSubtypeRemoteControlEndSeekingBackward: {
            NSLog(@"--------快退停止(按耳机线中间按钮3次到了快退的位置松开)");
        }break;
            
            //快进开始(按耳机线控中间按钮2次不松开)
        case  UIEventSubtypeRemoteControlBeginSeekingForward: {
            NSLog(@"--------快进开始(按耳机线控中间按钮2次不松开)");
        }break;
            
            //快进停止 (按耳机线控中间按钮2次,到了快进位置松手)
        case  UIEventSubtypeRemoteControlEndSeekingForward: {
            NSLog(@"--------快进停止 (按耳机线控中间按钮2次,到了快进位置松手)");
        }break;
            
            
        default:
            break;
    }
}


/**   在iOS 设备上添加或者移除音频输入/ 输出线路时,会发生线路改变.
 很多原因会导致线路变化,比如: 用户插入耳机或者断开USB麦克风, 当这些事件发生时,音频会根据情况改变输入/ 输出线路,同时AVAudioSession 会广播一个描述该变化的通知给所有相关的侦听器.
 */


@end
