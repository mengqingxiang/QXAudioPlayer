//
//  QXAudioPlayerLoadDelegate.m
//  QXAudioPlayer
//
//  Created by 孟庆祥 on 2017/5/15.
//  Copyright © 2017年 mengqingxiang. All rights reserved.
//

#import "QXAudioPlayerLoadDelegate.h"
#import "QXAudioCache.h"
#import "QXAudioPlayDownLoader.h"
#import "NSURL+QXURL.h"


#define kMaxLoadAudioBuffer  100

@interface QXAudioPlayerLoadDelegate()<QXAudioPlayDownLoaderDelegate>
@property(nonatomic,strong)QXAudioPlayDownLoader *downLoader;
@property(nonatomic,strong)NSMutableArray *loadRequestArray;
@end
@implementation QXAudioPlayerLoadDelegate

//该方法用来请求资源
//AVPlayer ->AVPlayerItem(资源组织器)->AVURLAsset(资源请求器)->resourceLoader(资源加载器)->delegate(用来返回数据)
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{
    //1.检测本地是否有完整的资源可以使用，有的话就使用。
    if ([QXAudioCache cachedWithUrl:loadingRequest.request.URL]) {
        [self requestLocalResourceWithUrl:loadingRequest];
        return YES;
    }
    
    
    long long currentOffset = [self currOffset:loadingRequest];
    NSURL *url = [loadingRequest.request.URL httpUrl];
    
    [self.loadRequestArray addObject:loadingRequest];
    NSLog(@"add---%@----thread%@",self.loadRequestArray,[NSThread currentThread]);
    
    //本地没有下载好的资源可以使用，判断是否正在下载，没有的话就下载
    if (self.downLoader.totoleSize==0) {
        [self.downLoader downWithUrl:url contentOffset:currentOffset];
        return YES;
    }
    
    //判断是否在下载的区间,判断的依据是
    //1.offset 小于当前的下载的offset
    if (currentOffset<self.downLoader.contentOffset || currentOffset>(self.downLoader.contentOffset+ self.downLoader.loadedSize + kMaxLoadAudioBuffer)) {
        [self.downLoader downWithUrl:url contentOffset:loadingRequest.dataRequest.requestedOffset];
        return YES;
    }
    
    //能到这里的请求说明都是可以匹配到我当前请求数据的区间
    [self dealWihtRequest];
    return YES;
}



-(long long)currOffset:(AVAssetResourceLoadingRequest *)loadingRequest
{
    long long currentOffset = loadingRequest.dataRequest.requestedOffset;
    if (loadingRequest.dataRequest.currentOffset != currentOffset) {
        currentOffset = loadingRequest.dataRequest.currentOffset;
    }
    return currentOffset;
}


- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    if ([self.loadRequestArray containsObject:loadingRequest]) {
        [self.loadRequestArray removeObject:loadingRequest];
    }
    NSLog(@"取消---%@",self.loadRequestArray);
}


-(void)dealWihtRequest
{
    NSMutableArray *finishArray = [NSMutableArray array];
    for (AVAssetResourceLoadingRequest*loadingRequest in self.loadRequestArray) {
        //填充信息
        loadingRequest.contentInformationRequest.contentLength = self.downLoader.totoleSize;
        loadingRequest.contentInformationRequest.contentType = self.downLoader.contentType;
        loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
        
        NSError *error;
        NSData *data = [NSData dataWithContentsOfFile:[QXAudioCache tmpPathWithUrl:loadingRequest.request.URL] options:NSDataReadingMappedIfSafe error:&error];
        if (data==nil) {
            data = [NSData dataWithContentsOfFile:[QXAudioCache cachePathWithUrl:loadingRequest.request.URL] options:NSDataReadingMappedIfSafe error:&error];
        }
        if (!error) {
            
            long long requestLength = loadingRequest.dataRequest.requestedLength;
            long long currentOffset = [self currOffset:loadingRequest];
            long long start = currentOffset - self.downLoader.contentOffset;
            long long end = MIN(self.downLoader.contentOffset + self.downLoader.loadedSize - currentOffset, requestLength);
            NSData *currentData = [data subdataWithRange:NSMakeRange(start, end)];
            [loadingRequest.dataRequest respondWithData:currentData];
            
            if (end == requestLength) {//这个区间的所有的数据都反回来了
                [loadingRequest finishLoading];
                [finishArray addObject:loadingRequest];
            }
        }
    }
    
    //将完成的任务删除
    [self.loadRequestArray removeObjectsInArray:finishArray];
}


#pragma make - 加载本地资源
-(void)requestLocalResourceWithUrl:(AVAssetResourceLoadingRequest *)loadingRequest
{
    //当我们请求一个资源的时候，要知道资源的大小，type，是否支持小段读取
    loadingRequest.contentInformationRequest.contentLength = [QXAudioCache cacheSizeWithUrl:loadingRequest.request.URL];
    loadingRequest.contentInformationRequest.contentType = [QXAudioCache contentType:loadingRequest.request.URL];
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    
    NSData *content = [NSData dataWithContentsOfFile:[QXAudioCache cachePathWithUrl:loadingRequest.request.URL] options:NSDataReadingMappedIfSafe error:nil];
    NSData *responContent = [content subdataWithRange:NSMakeRange(loadingRequest.dataRequest.currentOffset, loadingRequest.dataRequest.requestedLength)];
    [loadingRequest.dataRequest respondWithData:responContent];
    [loadingRequest finishLoading];
}


-(NSMutableArray *)loadRequestArray
{
    if (_loadRequestArray == nil) {
        _loadRequestArray = [NSMutableArray array];
    }
    return _loadRequestArray;
}



-(QXAudioPlayDownLoader *)downLoader
{
    if (_downLoader==nil) {
        _downLoader = [[QXAudioPlayDownLoader alloc]init];
        _downLoader.delegate = self;
    }
    return _downLoader;
}

#pragma mark - QXAudioPlayDownLoaderDelegate
-(void)downLoading:(QXAudioPlayDownLoader *)loader
{
    NSLog(@"downLoading...");
    [self dealWihtRequest];
}
@end
