//
//  QXAudioCache.m
//  QXAudioPlayer
//
//  Created by 孟庆祥 on 2017/5/15.
//  Copyright © 2017年 mengqingxiang. All rights reserved.
//

#import "QXAudioCache.h"
#import <MobileCoreServices/MobileCoreServices.h>


#define chcheDirectory NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define tmpDirectory NSTemporaryDirectory()
@implementation QXAudioCache

/*
    关于iOS的沙盒,3个常用的目录分别为 Document ,Library, tmp
    document  存放的文件会呗itunes同步，app推出后不会删除。
    tmp :存放临时文件，app推出时候可能会删除
    Library :存放临时文件，推出后删除。
 */

+(NSString*)cachePathWithUrl:(NSURL*)url
{
    return [chcheDirectory stringByAppendingString:url.pathComponents.lastObject];
}



+(NSString*)tmpPathWithUrl:(NSURL*)url
{
    return [tmpDirectory stringByAppendingString:url.pathComponents.lastObject];
}

+(void)removeTmpWithUrl:(NSURL*)url
{
    if ([self tmpedWithUrl:url]) {
        [[NSFileManager defaultManager]removeItemAtPath:[self tmpPathWithUrl:url] error:nil];
    }
}

+(BOOL)tmpedWithUrl:(NSURL*)url
{
    NSString *path = [self tmpPathWithUrl:url];
    return  [[NSFileManager defaultManager] fileExistsAtPath:path];
}



+(BOOL)cachedWithUrl:(NSURL*)url
{
    NSString *path = [self cachePathWithUrl:url];
    return  [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+(long long)cacheSizeWithUrl:(NSURL*)url
{
    if ([self cachePathWithUrl:url]) {
        NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:[self cachePathWithUrl:url] error:nil];
        return [info[@"NSFileSize"] longLongValue];
    }
    return 0;
}

+(long long)tmpSizeWithUrl:(NSURL*)url
{
    if ([self tmpedWithUrl:url]) {
        NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:[self tmpPathWithUrl:url] error:nil];
        return [info[@"NSFileSize"] longLongValue];
    }
    return 0;
}

+(NSString*)contentType:(NSURL*)url
{
    if ([self cachedWithUrl:url]) {
        NSString *ext = [self cachePathWithUrl:url].pathExtension;
        //UTTypeCreatePreferredIdentifierForTag 需要倒入这个<MobileCoreServices.h>
        CFStringRef ref = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef _Nonnull)(ext), NULL);
        return CFBridgingRelease(ref);
    }
    return @"";
}

+(void)movePathWithUrl:(NSURL*)url
{
    if ([self tmpedWithUrl:url]) {
        [[NSFileManager defaultManager]moveItemAtPath:[self tmpPathWithUrl:url] toPath:[self cachePathWithUrl:url] error:nil];
    }
}
@end
