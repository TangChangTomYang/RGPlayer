//
//  RGRemotePalyer.m
//  RGPlayer
//
//  Created by yangrui on 2018/11/12.
//  Copyright © 2018年 yangrui. All rights reserved.
//   11-播放器-拦截播放请求和本地假数据测试

#import "RGRemotePalyer.h"
#import "RGRemotePlayerResourceLoaderDelegate.h"
#import "NSURL+RemoteUrl.h"


@interface RGRemotePalyer (){
    NSURL *_url ;
    RGRemotePalyerState _state;
    /**
     用来标记是否是用户主动暂停的. 用户主动暂停的不会恢复为播放中的状态
     播放器在播放过程中可能会因为各种原因造成暂停.比如: 数据缓冲不足, 其它时间打断, 用户暂停
     */
    BOOL _isUserPause ;
}

@property(nonatomic, strong)AVPlayer *player;
@property(nonatomic, strong)RGRemotePlayerResourceLoaderDelegate *resourceLoader;
@end

@implementation RGRemotePalyer


static RGRemotePalyer *_remotePlayer = nil;
+(instancetype)shareInstance{
    if (!_remotePlayer) {
        _remotePlayer = [[self alloc] init];
        
        //开启播放器后台播放功能
        [_remotePlayer activeAudioPlaybackground];
    }
    return _remotePlayer;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    if (!_remotePlayer) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _remotePlayer = [super allocWithZone:zone];
        });
    }
    return _remotePlayer;
}

#pragma mark- 激活后台模式
/** 音频后台播放的步骤
 1. target --> capabilities --> background Modes(打开) --> 勾选Audio,AirPlay,and Picture in picture
 2. 获取音频会话
 3. 设置音频会话 类别
 4. 激活音频会话
 */
-(void)activeAudioPlaybackground{
    
    //1. 获取音频会话
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    //2. 设置会话类别
    NSError *err = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&err];
    
    if (err != nil) {
        NSLog(@"音频会话设置后台模式失败: err: %@", err.localizedDescription);
        return;
    }
    
    [audioSession setActive:YES error:&err];
    
    if (err != nil) {
        NSLog(@" 激活 音频会话 后台模式失败: err: %@", err.localizedDescription);
        
    }
}



#pragma mark- 播放音乐
/** 其实AVPlayer 是一个视频播放器, 视频播放器技能播放视频也能播放音频
 */
-(AVPlayerLayer *)videoPlayWithUrl:(NSURL *)url isCache:(BOOL)isCache{
    
    [self playWithUrl:url isCache:isCache];
    
    return  [AVPlayerLayer playerLayerWithPlayer:self.player];
  
}


/**
创建一个播放器对象
资源的请求
资源的组织
给播放器, 资源的播放
如果通过url 直接创建播放器([AVPlayer playerWithURL:url]) 后直接调用播放功能([self.player play])
如果资源加载的比较慢,有可能会造成调用了play 方法后, 当前音频并没有播放的的bug

 AVPlayer *player = [AVPlayer playerWithURL:url];
 [self.player play];
 */
-(void)playWithUrl:(NSURL *)url isCache:(BOOL)isCache{
    
    //
    if(url == nil )return;
    
    // 是同一个URL 就不处理
    NSURL *currentUrl = ((AVURLAsset *)self.player.currentItem.asset).URL;
    if ([url isEqual:currentUrl]) {
        [self resume];
        return;
    }
    else if(self.player != nil){ // 不是同一个就先停止原来的, 在继续后面的播放
        [self stop];
    }
    
    
    //
    BOOL isFileUrl = [url isFileURL];
    _url = url;
    _isUserPause = NO;
    if (isCache == YES && isFileUrl == NO) {
        url = [url streamingRrl];
    }
    
    // 先移除旧的player.currentItem 的监听者,后面在给新的item添加新的监听者
    if(self.player.currentItem){
        [self removeCurrentItemObserver];
    }
    
    
    // 1.资源的请求者
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    if(isFileUrl == NO){ // 如果是远程URL 就需要设置 asset.resourceLoader 的代理,数据从代理处加载
        self.resourceLoader = [[RGRemotePlayerResourceLoaderDelegate alloc] init];
        [asset.resourceLoader setDelegate:self.resourceLoader queue:dispatch_get_main_queue()];
    }
   
    //2. 资源的组织
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    // 当资源的组织者告诉我们资源准备好了, 我们在播放
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 监听资源的准备状态
    [item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    // 通知监听当前歌曲播放完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(palyDidEndNotice:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    // 通知监听当前歌曲被打断
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidInterruptNotice:) name:AVPlayerItemPlaybackStalledNotification object:nil];
    
    
    //3. 资源的播放
    self.player = [AVPlayer playerWithPlayerItem:item];
    
//    切换播放
//    AVPlayerItem *newItem;
//    [self.player replaceCurrentItemWithPlayerItem:newItem];
}
-(RGRemotePalyerState)state{
    return _state;
}

-(void)setState:(RGRemotePalyerState)state{
    _state = state;
    
    switch (state) {
        case RGRemotePalyerState_unknown:
            NSLog(@"Palyer 未知(比如没有加载数据)");
        break;
            
        case RGRemotePalyerState_Loading:
            NSLog(@"Palyer 正在加载");
        break;
            
        case RGRemotePalyerState_Playing:
            NSLog(@"Palyer 正在播放");
        break;
            
        case RGRemotePalyerState_Stoped:
            NSLog(@"Palyer 停止");
        break;
            
        case RGRemotePalyerState_pause:
            NSLog(@"Palyer 暂停");
        break;
            
        case RGRemotePalyerState_playEnd:
            NSLog(@"Palyer 播放完成");
        break;
            
        case RGRemotePalyerState_interrupt :
            NSLog(@"Palyer 播放被打断");
        break;
            
        case RGRemotePalyerState_Failed:
            NSLog(@"Palyer 失败(比如,没有网络缓存失败, 地址错误等)");
        break;
       
        default:
            break;
    }
}


-(void)pause{
    [self.player pause];
    _isUserPause = YES;
    if(self.player){
        self.state = RGRemotePalyerState_pause;
    }
}



-(void)resume{
    [self.player play];
    _isUserPause = NO;
    if(self.player != nil && // 播放器存在
       self.player.currentItem.playbackLikelyToKeepUp == YES){ // 播放器组织者里的数据准备好了, 足够播放了
        self.state = RGRemotePalyerState_Playing;
    }
}

-(void)stop{
    [self.player pause];
    self.player = nil;
    if (self.player) {
        self.state = RGRemotePalyerState_Stoped;
    }
}

-(void)setRate:(float)rate{
    self.player.rate = rate;
}

-(float)rate{
    return self.player.rate;
}


-(void)setMuted:(BOOL)muted{
    self.player.muted = muted;
}

-(BOOL)isMuted{
    return self.player.muted;
}

-(void)setVolume:(float)volume{
    if (volume > 1 || volume < 0) {
        return;
    }
    
    if (volume > 0) {
        [self setMuted:NO];
    }
    self.player.volume = volume;
}

-(float)volume{
    return self.player.volume;
}

-(NSTimeInterval)totalTime{
    CMTime totalTimeCM = self.player.currentItem.duration;
    NSTimeInterval totalTimeSec = CMTimeGetSeconds(totalTimeCM);
    
    if(isnan(totalTimeSec)){
        return 0;
    }
    return totalTimeSec;
}

- (NSString *)totalTimeFormat {
    return [NSString stringWithFormat:@"%02zd:%02zd", (int)self.totalTime / 60, (int)self.totalTime % 60];
}

-(NSTimeInterval)currentTime{
    CMTime currentTimeCM = self.player.currentItem.currentTime;
    NSTimeInterval currentTimeSec = CMTimeGetSeconds(currentTimeCM);
    
    if(isnan(currentTimeSec)){
        return 0;
    }
    return currentTimeSec;
}

- (NSString *)currentTimeFormat {
    return [NSString stringWithFormat:@"%02zd:%02zd", (int)self.currentTime / 60, (int)self.currentTime % 60];
}

-(float)progress{
    if (self.totalTime == 0) {
        return 0;
    }
    return self.currentTime / self.totalTime;
}

-(float)loadDataProgerss{
    
    if (self.totalTime == 0) {
        return 0;
    }
    
    CMTimeRange loadTimeRange = [[[self.player.currentItem loadedTimeRanges] lastObject] CMTimeRangeValue];
    
    CMTime loadTimeCM = CMTimeAdd(loadTimeRange.start, loadTimeRange.duration);
    
    NSTimeInterval loadTimeSec = CMTimeGetSeconds(loadTimeCM);
    
    return loadTimeSec / self.totalTime;
    
}


-(void)seekWithProgerss:(float)progress{
    if(progress > 1 || progress < 0){
        return;
    }
    
    // 获取当前音频资源的总时长
    NSTimeInterval totalTimeSec = [self totalTime];
    NSTimeInterval currentTimeSec = totalTimeSec * progress;
    int32_t timeScale = self.player.currentItem.duration.timescale;
    
    CMTime progessTimeCM = CMTimeMake(currentTimeSec * timeScale , timeScale);
    
    
    [self.player seekToTime:progessTimeCM completionHandler:^(BOOL finished) {
        
        if (finished) {
            NSLog(@"加载这个时间点的资源成功");
        }
        else{
          NSLog(@"加载这个时间点的资源----失败");
        }
    }];
}



-(void)seekWithTimeDiffer:(NSTimeInterval)timeDiffer{
    
    NSTimeInterval currentTimeSec = [self currentTime];
    NSTimeInterval totaltimeSec = [self totalTime];
    
    NSTimeInterval playtimeSec = currentTimeSec + timeDiffer;
    if(playtimeSec < 0){
        playtimeSec = 0;
    }
    
    if(playtimeSec > totaltimeSec ){
        playtimeSec = totaltimeSec;
    }
    
    [self seekWithProgerss:(playtimeSec / totaltimeSec)];
}


-(void)removeCurrentItemObserver{
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
}


#pragma mark- 经停播放器通知
// 当前歌曲播放完成
-(void)palyDidEndNotice:(NSNotification *)noti{
    self.state = RGRemotePalyerState_playEnd;
    
}

// 当前歌曲被打算
-(void)playDidInterruptNotice:(NSNotification *)noti{
    // 来点,或 资源跟不上
    self.state = RGRemotePalyerState_interrupt;
}



#pragma mark- KVO 监听Item的状态
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context{
    // 监听资源组织者的状态是否可以播放了
    // 这个一般只有在开始时调用一次
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = (AVPlayerItemStatus)[change[NSKeyValueChangeNewKey] integerValue];
   
        if (status == AVPlayerItemStatusReadyToPlay) {
            NSLog(@"资源准备好了, 可以播放了");
            [self resume];
        }
        else{
            NSLog(@" item 的 状态 位置");
            self.state = RGRemotePalyerState_Failed;
        }
        
        return;
    }
    
    // 监听资源组织这的数据是被准备, 足够了
    // 这个在播放过程中可能调多次
    if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        BOOL isPlaybackLikelyToKeepUp = (AVPlayerItemStatus)[change[NSKeyValueChangeNewKey] integerValue];
        
        if (isPlaybackLikelyToKeepUp == YES) {
            NSLog(@"资源准备足够播放了");
            // 如果不是用户暂停的, 就恢复播放
            if(_isUserPause == NO ){
                [self resume];
            }
        }
        else{
            NSLog(@"资源准备 还没好");
            self.state = RGRemotePalyerState_Loading; // 正在加载...
        }
        
        return;
    }
    
}

-(void)dealloc{
    
    [self removeCurrentItemObserver];
}



@end
