//
//  QXAudioPlayDownLoader.m
//  QXAudioPlayer
//
//  Created by 孟庆祥 on 2017/5/15.
//  Copyright © 2017年 mengqingxiang. All rights reserved.
//

#import "QXAudioPlayDownLoader.h"
#import "QXAudioCache.h"
@interface QXAudioPlayDownLoader()<NSURLSessionDataDelegate>
@property(nonatomic,strong)NSURLSession *session;
@property(nonatomic,strong)NSOutputStream *stream;
@property(nonatomic,strong)NSURL *url;
@end
@implementation QXAudioPlayDownLoader

-(NSURLSession *)session
{
    if (_session==nil) {
        NSURLSessionConfiguration *configuar = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuar delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}


-(void)downWithUrl:(NSURL*)url contentOffset:(long long)contentOffset
{
    self.url = url;
    self.contentOffset = contentOffset;
    [self clearTmp];
    NSMutableURLRequest *requet = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [requet setValue:[NSString stringWithFormat:@"bytes=%lld-",contentOffset] forHTTPHeaderField:@"Range"];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:requet];
    [task resume];
}


-(void)clearTmp
{
    [self.session invalidateAndCancel];
    self.session = nil;
    [QXAudioCache removeTmpWithUrl:self.url];
}


#pragma mark -delegate

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    self.totoleSize = [response.allHeaderFields[@"Content-Length"] longLongValue];
    NSString *contentRange = response.allHeaderFields[@"Content-Range"];
    self.contentType = response.MIMEType;
    if (contentRange.length>0) {
        [[[contentRange componentsSeparatedByString:@"/"] lastObject] longLongValue];
    }
    self.stream = [NSOutputStream outputStreamToFileAtPath:[QXAudioCache tmpPathWithUrl:response.URL] append:YES];
    [self.stream open];
    completionHandler(NSURLSessionResponseAllow);
}


-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    self.loadedSize += data.length;
    [self.stream write:data.bytes maxLength:data.length];
    
    if ([self.delegate respondsToSelector:@selector(downLoading:)]) {
        [self.delegate downLoading:self];
    }
}


-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (!error && [QXAudioCache tmpSizeWithUrl:self.url]==self.totoleSize) {//下载完成检测是否完整后转移到cache中
        [QXAudioCache movePathWithUrl:self.url];
    }
}
@end
