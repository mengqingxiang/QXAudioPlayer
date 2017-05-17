//
//  QXAudioPlayer.h
//  QXAudioPlayer
//
//  Created by 孟庆祥 on 2017/5/12.
//  Copyright © 2017年 mengqingxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,QXPlayState) {
    QXPlayStateUnknown = 0,
    QXPlayStateLoading = 1,
    QXPlayStatePlaying = 2,
    QXPlayStateStopped = 3,
    QXPlayStatePause = 4,
    QXPlayStateFailed = 5,
};


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

@property(nonatomic,copy)NSString *playUrl; //资源的url
@property(nonatomic,assign,readonly)NSTimeInterval totolTime;//总时长
@property(nonatomic,assign,readonly)NSTimeInterval currentPlayTime;//当前的播放时长
@property(nonatomic,copy,readonly)NSString* totolTimeFormat;//格式化后总时长
@property(nonatomic,copy,readonly)NSString* currentPlayTimeFormat;//格式化后当前的播放时长
@property(nonatomic,assign,readonly)float playProgress;//当前的播放进度
@property(nonatomic,assign,readonly)float loadProgress;//当前的缓存进度
@property(nonatomic,assign)float rate;
@property(nonatomic,assign)BOOL mute;
@property(nonatomic,assign)float volume;
@property(nonatomic,assign)QXPlayState state;//状态
@end
