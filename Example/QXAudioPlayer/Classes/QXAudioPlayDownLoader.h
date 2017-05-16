//
//  QXAudioPlayDownLoader.h
//  QXAudioPlayer
//
//  Created by 孟庆祥 on 2017/5/15.
//  Copyright © 2017年 mengqingxiang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QXAudioPlayDownLoader;

@protocol QXAudioPlayDownLoaderDelegate <NSObject>

-(void)downLoading:(QXAudioPlayDownLoader*)loader;

@end


@interface QXAudioPlayDownLoader : NSObject
@property(nonatomic,weak)id<QXAudioPlayDownLoaderDelegate>delegate;
-(void)downWithUrl:(NSURL*)url contentOffset:(long long)contentOffset;
@property(nonatomic,assign)long long totoleSize;
@property(nonatomic,assign)long long loadedSize;
@property(nonatomic,assign)long long contentOffset;
@property(nonatomic,copy)NSString *contentType;
@end
