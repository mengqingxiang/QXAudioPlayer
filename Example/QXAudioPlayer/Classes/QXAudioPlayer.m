//
//  QXAudioPlayer.m
//  QXAudioPlayer
//
//  Created by 孟庆祥 on 2017/5/12.
//  Copyright © 2017年 mengqingxiang. All rights reserved.
//

#import "QXAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
@interface QXAudioPlayer()
@property(nonatomic,strong)AVPlayer *player;
@end

static QXAudioPlayer *_shareInstance;
@implementation QXAudioPlayer


+(instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[QXAudioPlayer alloc]init];
    });
    return _shareInstance;
}


-(void)playWithUrl:(NSString *)url
{
    //1.资源的请求
    AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:url]];
    
    //2.资源的组织
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    
    //移除原来的监听
    if (self.player) {
        [self.player removeObserver:self forKeyPath:@"status"];
    }
    
    //3.资源的播放
    AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:item];
    self.player = player;

    //当我们把资源准备好了以后才能播放资源，所以要监听资源是否准备好了
    [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];

}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus statu = [change[NSKeyValueChangeNewKey] intValue];

        if (statu == AVPlayerStatusReadyToPlay) {
            NSLog(@"我已经准备好播放了");
            [self.player play];
        }else{
            NSLog(@"我没准备好播放了");
        }
    }
}

-(void)pause
{
    [self.player pause];
}

-(void)resume
{
    [self.player play];
}

-(void)stop
{
    if (self.player) {
        [self.player pause];
        self.player = nil;
    }
}

-(void)seekWithProgress:(float)progress
{
    
    if (progress<0 || progress >1) {
        return;
    }
    
    CMTime totolTime = self.player.currentItem.duration;
    NSTimeInterval time = CMTimeGetSeconds(totolTime);
    NSTimeInterval playTime = time * progress;
    CMTime seekTime = CMTimeMake(playTime, 1);
    [self.player seekToTime:seekTime completionHandler:^(BOOL finished) {
        if (finished) {
            NSLog(@"加载这个音频");
        }else{
            NSLog(@"不加载这个音频");
        }
    }];
}


-(void)seekWithOffset:(float)Offset
{
    CMTime totolTime = self.player.currentItem.duration;
    NSTimeInterval time = CMTimeGetSeconds(totolTime);
    NSTimeInterval  currentTime = CMTimeGetSeconds(self.player.currentItem.currentTime)+Offset;
    float per = currentTime/time;
    [self seekWithProgress:per];
}

-(void)setRate:(float)rate
{
    [self.player setRate:rate];
}


-(void)setMute:(BOOL)mute
{
    [self.player setMuted:mute];
}

-(void)setVolume:(float)volume
{
    if (volume<0 || volume>1) {
        return;
    }
    if (volume>0) {
        [self setMute:NO];
    }
    
    [self.player setVolume:volume];
}
@end










