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

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

@property (weak, nonatomic) IBOutlet UIProgressView *loadPV;

@property (nonatomic, weak) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UISlider *playSlider;

@property (weak, nonatomic) IBOutlet UIButton *mutedBtn;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;

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
    
    // http://120.25.226.186:32812/resources/videos/minion_01.mp4
    NSURL *url = [NSURL URLWithString:@"http://127.0.0.1/seeyouseeme.mp3"];

    [[RGRemotePalyer shareInstance] playWithUrl:url isCache:YES];
    
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



@end
