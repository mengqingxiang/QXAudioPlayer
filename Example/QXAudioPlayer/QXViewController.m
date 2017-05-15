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

@end

@implementation QXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}


- (IBAction)play:(id)sender {
    [[QXAudioPlayer shareInstance] playWithUrl:@"http://audio.xmcdn.com/group23/M04/63/C5/wKgJNFg2qdLCziiYAGQxcTOSBEw402.m4a"];
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
@end
