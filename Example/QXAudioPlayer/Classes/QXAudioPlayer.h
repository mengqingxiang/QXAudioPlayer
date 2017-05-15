//
//  QXAudioPlayer.h
//  QXAudioPlayer
//
//  Created by 孟庆祥 on 2017/5/12.
//  Copyright © 2017年 mengqingxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QXAudioPlayer : NSObject

+(instancetype)shareInstance;
/**
 播放音频
 @param remote audio url
 */
-(void)playWithUrl:(NSString*)url;

-(void)pause;

-(void)resume;

-(void)stop;

// 快进或快退
-(void)seekWithProgress:(float)progress;
// 快进或快退
-(void)seekWithOffset:(float)Offset;
-(void)setRate:(float)rate;
-(void)setMute:(BOOL)mute;
-(void)setVolume:(float)volume;

@end
