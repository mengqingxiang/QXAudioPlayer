//
//  QXViewController.m
//  QXAudioPlayer
//
//  Created by mengqingxiang on 05/12/2017.
//  Copyright (c) 2017 mengqingxiang. All rights reserved.
//

#import "QXViewController.h"
#import "QXAudioPlayer.h"
@interface QXViewController ()
@property (weak, nonatomic) IBOutlet UISlider *fastSlid;
@property (weak, nonatomic) IBOutlet UILabel *leftLable;
@property (weak, nonatomic) IBOutlet UILabel *rightLable;

@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
@property (weak, nonatomic) IBOutlet UISlider *voice;
@property (weak, nonatomic) IBOutlet UISlider *loadSlid;
@property(nonatomic,strong)NSTimer *timer;
@end

@implementation QXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    //关于iOS的沙盒
    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSUserDirectory, NSUserDomainMask, YES);
    NSLog(@"%@---%@",arr,NSHomeDirectory());
    
    

    
    
    
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
    self.timer = timer;
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [timer fire];
}


- (IBAction)play:(id)sender {
    //http://audio.xmcdn.com/group23/M04/63/C5/wKgJNFg2qdLCziiYAGQxcTOSBEw402.m4a
    [[QXAudioPlayer shareInstance] playWithUrl:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4"];

}

- (IBAction)pause:(id)sender {
    [[QXAudioPlayer shareInstance] pause];
}

- (IBAction)continue:(id)sender {
    [[QXAudioPlayer shareInstance] resume];
}


- (IBAction)fast:(UIButton*)sender {
    [[QXAudioPlayer shareInstance] seekWithOffset:15];
}

- (IBAction)fastWithProgress:(UISlider*)sender {
    [[QXAudioPlayer shareInstance] seekWithProgress:sender.value];
}

- (IBAction)mute:(UIButton*)sender {
    sender.selected = !sender.selected;
    [[QXAudioPlayer shareInstance] setMute:sender.selected];
}

- (IBAction)rete:(id)sender {
    [[QXAudioPlayer shareInstance] setRate:1.5];
}

- (IBAction)voice:(UISlider*)sender {
    [[QXAudioPlayer shareInstance] setVolume:sender.value];
}

- (IBAction)fastToProgress:(UISlider*)sender {
    [[QXAudioPlayer shareInstance] seekWithProgress:sender.value];
}

-(void)update
{
    QXAudioPlayer *play = [QXAudioPlayer shareInstance];
    NSLog(@"---%d",play.state);
    self.leftLable.text = play.currentPlayTimeFormat;
    self.rightLable.text = play.totolTimeFormat;
    self.fastSlid.value = play.playProgress;
    self.loadSlid.value = play.loadProgress;
    self.voice.value = play.volume;
    self.muteBtn.selected = play.mute;
}
@end
