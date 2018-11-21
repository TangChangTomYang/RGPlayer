//
//  RGRemotePalyer.h
//  RGPlayer
//
//  Created by yangrui on 2018/11/12.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RGRemotePalyerState) {
    RGRemotePalyerState_unknown = 0,//未知(比如没有加载数据)
    RGRemotePalyerState_Loading = 1,// 正在加载
    RGRemotePalyerState_Playing = 2,//正在播放
    RGRemotePalyerState_Stoped = 3, //停止
    RGRemotePalyerState_pause = 4, //暂停
    RGRemotePalyerState_playEnd = 5, //播放完成
    RGRemotePalyerState_interrupt = 6, //播放被打断
    RGRemotePalyerState_Failed // 失败(比如,没有网络缓存失败, 地址错误等)
};


@interface RGRemotePalyer : NSObject


#pragma mark- 对外状态(拉模式)
@property (nonatomic, assign, readonly) RGRemotePalyerState state;
@property(nonatomic, assign, getter=isMuted)BOOL muted;
@property(nonatomic, assign)float volume;
@property(nonatomic, assign)float rate;
@property(nonatomic, assign, readonly)NSTimeInterval totalTime;
@property (nonatomic, copy, readonly) NSString *totalTimeFormat;
@property(nonatomic, assign,readonly)NSTimeInterval currentTime;
@property (nonatomic, copy, readonly) NSString *currentTimeFormat;
@property(nonatomic, assign,readonly)float progress;
@property(nonatomic, assign,readonly)float loadDataProgerss;
@property(nonatomic, strong,readonly)NSURL *url;
@property(nonatomic, strong,readonly)NSURL *path;







#pragma mark- 对外数据接口
+(instancetype)shareInstance;
/** 通过远程地址播放(资源在 remoteServer上或者 cachePath tempPath中)
 */
-(void)playWithUrl:(NSURL *)url isCache:(BOOL)isCache;
-(void)pause;
-(void)resume;
-(void)stop;
-(void)seekWithTimeDiffer:(NSTimeInterval)timeDiffer;
-(void)seekWithProgerss:(float)progress;





@end
