//
//  QXAudioPlayer.m
//  QXAudioPlayer
//
//  Created by 孟庆祥 on 2017/5/12.
//  Copyright © 2017年 mengqingxiang. All rights reserved.
//

#import "QXAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "QXAudioPlayerLoadDelegate.h"
#import "NSURL+QXURL.h"
@interface QXAudioPlayer()
{
    BOOL _bpause;
}
@property(nonatomic,strong)AVPlayer *player;
@property(nonatomic,strong)QXAudioPlayerLoadDelegate *delegate;
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
    
    
    if ([url isEqualToString:self.playUrl]) {
        [self resume];
        return;
    }
    
    self.playUrl =url;
    
    //1.资源的请求
    NSURL *currentUrl = [[NSURL URLWithString:url] streamingUrl];
    AVURLAsset *asset = [AVURLAsset assetWithURL:currentUrl];
    self.delegate = [[QXAudioPlayerLoadDelegate alloc]init];
    [asset.resourceLoader setDelegate:self.delegate queue:dispatch_get_main_queue()];
    
    //2.资源的组织
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    
    //移除原来的监听
    if (self.player) {
        [self removeObserver];
    }
    
    //3.资源的播放
    AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:item];
    self.player = player;

    //当我们把资源准备好了以后才能播放资源，所以要监听资源是否准备好了
    [self addObserver];

}


-(void)removeObserver
{
    [self.player removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}

-(void)addObserver
{
     [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
     [self.player.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus statu = [change[NSKeyValueChangeNewKey] intValue];

        if (statu == AVPlayerStatusReadyToPlay) {
            NSLog(@"我已经准备好播放了");
            [self resume];
        }else{
            NSLog(@"我没准备好播放了");
            self.state = QXPlayStateFailed;
        }
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
         BOOL playback = [change[NSKeyValueChangeNewKey] boolValue];
        if (playback) {
            NSLog(@"准备好了");
            if (!_bpause) {
                [self resume];
            }
        }else{
            NSLog(@"加载中...");
            self.state = QXPlayStateLoading;
        }
        
    }
}

-(void)pause
{
    _bpause = YES;
    [self.player pause];
    if (self.player) {
        self.state  = QXPlayStatePause;
    }
}

-(void)resume
{
    [self.player play];
    _bpause = NO;
    //playbackLikelyToKeepUp  资源准备好了，可以播放
    if (self.player && self.player.currentItem.playbackLikelyToKeepUp) {
        self.state  = QXPlayStatePlaying;
    }
}

-(void)stop
{
    if (self.player) {
        [self.player pause];
        self.state = QXPlayStateStopped;
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

#pragma mark - 接口方法
-(void)setMute:(BOOL)mute
{
    self.player.muted = mute;
}


-(BOOL)mute
{
    return self.player.isMuted;
}

-(void)setRate:(float)rate
{
    self.player.rate = rate;
}

-(float)rate
{
    return self.player.rate;
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


-(float)volume
{
    return self.player.volume;
}

-(NSTimeInterval)totolTime
{
    if (self.player) {
        return CMTimeGetSeconds(self.player.currentItem.duration);
    }
    return 0;
}

-(NSTimeInterval)currentPlayTime
{
    if (self.player) {
        return CMTimeGetSeconds(self.player.currentItem.currentTime);
    }
    return 0;
}


-(NSString*)currentPlayTimeFormat
{
    return [NSString stringWithFormat:@"%02zd:%02zd",(int)[self currentPlayTime]/60,(int)[self currentPlayTime]%60];
}

-(NSString *)totolTimeFormat
{
    return [NSString stringWithFormat:@"%02zd:%02zd",(int)[self totolTime]/60,(int)[self totolTime]%60];
}

-(NSString *)playUrl
{
    return _playUrl;
}

-(float)playProgress
{
    return self.currentPlayTime/self.totolTime;
}


-(float)loadProgress
{
    CMTimeRange range = [[self.player.currentItem.loadedTimeRanges lastObject] CMTimeRangeValue];
    CMTime time =  CMTimeAdd(range.start, range.duration);
    return CMTimeGetSeconds(time) / self.totolTime;
}
@end










