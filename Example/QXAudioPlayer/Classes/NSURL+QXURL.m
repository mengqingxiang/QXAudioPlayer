//
//  NSObject+QXURL.m
//  QXAudioPlayer
//
//  Created by 孟庆祥 on 2017/5/15.
//  Copyright © 2017年 mengqingxiang. All rights reserved.
//

#import "NSURL+QXURL.h"

@implementation NSURL (QXURL)
-(NSURL*)streamingUrl
{
    NSURLComponents *compont = [NSURLComponents componentsWithString:self.absoluteString];
    compont.scheme = @"sreaming";
    return compont.URL;
}


-(NSURL*)httpUrl
{
    NSURLComponents *compont = [NSURLComponents componentsWithString:self.absoluteString];
    compont.scheme = @"http";
    return compont.URL;
}
@end
