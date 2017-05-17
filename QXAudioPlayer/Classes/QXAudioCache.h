//
//  QXAudioCache.h
//  QXAudioPlayer
//
//  Created by 孟庆祥 on 2017/5/15.
//  Copyright © 2017年 mengqingxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QXAudioCache : NSObject

//检测本地是否有完整的资源
+(BOOL)cachedWithUrl:(NSURL*)url;

//tmp 路径 是否存在
+(BOOL)tmpedWithUrl:(NSURL*)url;

//tmp 路径
+(NSString*)tmpPathWithUrl:(NSURL*)url;

//删除tmp
+(void)removeTmpWithUrl:(NSURL*)url;

//获得资源的存储路径
+(NSString*)cachePathWithUrl:(NSURL*)url;

//获取资源的大小
+(long long)cacheSizeWithUrl:(NSURL*)url;

//获取资源的大小
+(long long)tmpSizeWithUrl:(NSURL*)url;

//获取资源的type
+(NSString*)contentType:(NSURL*)url;

//转移资源的路径
+(void)movePathWithUrl:(NSURL*)url;
@end
