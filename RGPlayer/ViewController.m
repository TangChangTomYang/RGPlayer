//
//  ViewController.m
//  RGPlayer
//
//  Created by yangrui on 2018/11/12.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "ViewController.h"
#import "RGRemotePalyer.h"
#import "RGRemoteAudilFileTool.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

@property (weak, nonatomic) IBOutlet UIProgressView *loadPV;

@property (nonatomic, weak) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UISlider *playSlider;

@property (weak, nonatomic) IBOutlet UIButton *mutedBtn;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;


//

@property(nonatomic, strong)CADisplayLink *displayLink ;

@end

@implementation ViewController


- (NSTimer *)timer {
    if (!_timer) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        _timer = timer;
    }
    return _timer;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self timer];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupLockMsg];
    [self addDisplayLink];
}

- (void)update {
    
    //    NSLog(@"--%zd", [XMGRemotePlayer shareInstance].state);
    // 68
    // 01:08
    // 设计数据模型的
    // 弱业务逻辑存放位置的问题
    self.playTimeLabel.text =  [RGRemotePalyer shareInstance].currentTimeFormat;
    
    self.totalTimeLabel.text = [RGRemotePalyer shareInstance].totalTimeFormat;
    
    self.playSlider.value = [RGRemotePalyer shareInstance].progress;
    
    self.volumeSlider.value = [RGRemotePalyer shareInstance].volume;
    
    self.loadPV.progress = [RGRemotePalyer shareInstance].loadDataProgerss;
    
    self.mutedBtn.selected = [RGRemotePalyer shareInstance].muted;
    
}


- (IBAction)play:(id)sender {
    
//    [self audioPlay];
    
    [self videoPlay];
}

// 音频播放
-(void)audioPlay{
    //远程音频播放地址
    NSURL *url = [NSURL URLWithString:@"http://172.20.10.10/seeyouseeme.mp3"];
    //本地音频播放
    //url = [[NSBundle mainBundle] URLForResource:@"235319.mp3" withExtension:nil];
    [[RGRemotePalyer shareInstance] playWithUrl:url isCache:YES];
}

// 视频播放
-(void)videoPlay{
    //远程音频播放地址
    NSURL *url = [NSURL URLWithString:@"http://127.0.0.1/test.mp4"];
    //本地音频播放
    url = [[NSBundle mainBundle] URLForResource:@"aaa.mp4" withExtension:nil];
    AVPlayerLayer *layer = [[RGRemotePalyer shareInstance] avplayWithUrl:url isCache:YES];
    layer.frame = self.view.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
}

- (IBAction)pause:(id)sender {
    [[RGRemotePalyer shareInstance] pause];
}

- (IBAction)resume:(id)sender {
    [[RGRemotePalyer shareInstance] resume];
}
- (IBAction)kuaijin:(id)sender {
    [[RGRemotePalyer shareInstance] seekWithTimeDiffer:3];
}
- (IBAction)progress:(UISlider *)sender {
    [[RGRemotePalyer shareInstance] seekWithProgerss:sender.value];
}

- (IBAction)rate:(id)sender {
    [[RGRemotePalyer shareInstance] setRate:2];
}
- (IBAction)muted:(UIButton *)sender {
    sender.selected = !sender.selected;
    [[RGRemotePalyer shareInstance] setMuted:sender.selected];
}
- (IBAction)volume:(UISlider *)sender {
    [[RGRemotePalyer shareInstance] setVolume:sender.value];
}


#pragma mark- 开启远程事件, 在锁频时监听音乐播放
/** 实现锁屏界面,并接收远程事件, 步骤
 1. 获取锁屏信息中心     [MPNowPlayingInfoCenter defaultCenter]
 2. 设置锁屏显示的信息   [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = @{xxx:yyy};
 3. 启动远程事件接收     [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
 4. 播放音乐 (如果没有播放音乐, 锁屏是看不见的)
 5. 锁屏
 6. 远程操作
 7. 接收远程事件并相应对应的事件
    7.1 可以监听远程事件的前提条件:
        1> 启动远程事件接收
        2> 必须可以成为第一响应者
        3> 应用程序必须是该事件的控制者
 
 */
-(void)setupLockMsg{
    // 1. 获取锁屏中心
    MPNowPlayingInfoCenter *infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    //2. 创建显示信息的字典
    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"dzq"]];
    NSDictionary *infoDic = @{
                              MPMediaItemPropertyArtist : @"歌手", // 歌手
                              MPMediaItemPropertyAlbumTitle : @"歌曲名称", // 歌曲名称
                              MPMediaItemPropertyArtwork : artwork, // 封面图片
                              MPMediaItemPropertyPlaybackDuration :@(189), // 总时长
                              MPNowPlayingInfoPropertyElapsedPlaybackTime: @(20), // 已经播放时长 NSNumber
                              };
    
    //3. 设置显示的数据
    infoCenter.nowPlayingInfo = infoDic;
    
    //4.接收远程事件()
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}


// 添加定时器
-(void)addDisplayLink{
    //1.
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];
    //2.
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    //3.
    self.displayLink = displayLink;
    
}

// 定时器事件 (这个方法在后台时也会执行多次)
-(void)displayLinkAction:(CADisplayLink *)displayLink{
    
    //NSLog(@"=----------------");
}



-(void)removeDisplayLink{
    [self.displayLink invalidate];
    self.displayLink = nil;
}


/** 监听远程控制事件
 这个远程事件方法可以在多个地方重写, 但是最终在哪个地方调用是根据响应者链的顺序来定的
 优先调用最外层, 最后在调用最里层(AppDelegate 如果有重写)
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
            NSLog(@"不包含任何操作");
        }break;
            
        // 摇晃事件
        case UIEventSubtypeMotionShake : {
            NSLog(@"摇晃事件");
        }break;
            
        //播放事件 (停止状态,按下耳机线控中间按钮一下)
        case  UIEventSubtypeRemoteControlPlay: {
            NSLog(@"播放事件 (停止状态,按下耳机线控中间按钮一下)");
        }break;
            
        //暂停事件
        case  UIEventSubtypeRemoteControlPause: {
            NSLog(@"暂停事件");
        }break;
            
        //停止事件
        case  UIEventSubtypeRemoteControlStop: {
            NSLog(@"停止事件");
        }break;
            
        //播放或者暂停切换( 播放或暂停状态下, 按耳机线控中间按钮一下)
        case  UIEventSubtypeRemoteControlTogglePlayPause: {
            NSLog(@"播放或者暂停切换( 播放或暂停状态下, 按耳机线控中间按钮一下)");
        }break;
            
        //下一首(按耳机线控中间按钮2次)
        case  UIEventSubtypeRemoteControlNextTrack: {
            NSLog(@"下一首(按耳机线控中间按钮2次)");
        }break;
            
        //上一首(按耳机线中间按钮3次)
        case  UIEventSubtypeRemoteControlPreviousTrack: {
            NSLog(@"上一首(按耳机线中间按钮3次)");
        }break;
            
        //快退开始(按耳机线控中间按钮3次不要松开)
        case  UIEventSubtypeRemoteControlBeginSeekingBackward: {
            NSLog(@"快退开始(按耳机线控中间按钮3次不要松开)");
        }break;
            
        //快退停止(按耳机线中间按钮3次到了快退的位置松开)
        case  UIEventSubtypeRemoteControlEndSeekingBackward: {
            NSLog(@"快退停止(按耳机线中间按钮3次到了快退的位置松开)");
        }break;
            
        //快进开始(按耳机线控中间按钮2次不松开)
        case  UIEventSubtypeRemoteControlBeginSeekingForward: {
            NSLog(@"快进开始(按耳机线控中间按钮2次不松开)");
        }break;
            
        //快进停止 (按耳机线控中间按钮2次,到了快进位置松手)
        case  UIEventSubtypeRemoteControlEndSeekingForward: {
            NSLog(@"快进停止 (按耳机线控中间按钮2次,到了快进位置松手)");
        }break;
        
            
        default:
        break;
    }
}


#pragma mark- 摇一摇
/** 摇一摇 开始
 注意: 摇一摇只有在前台或者锁屏后屏幕点亮后才能工作
 */
-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    NSLog(@"摇一摇 开始");
}


/** 摇一摇 结束
 */
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
   NSLog(@"摇一摇 结束");
}

/** 摇一摇 取消
 */
-(void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event{
   NSLog(@" 摇一摇 取消");
}














@end
