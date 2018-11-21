//
//  RGRemoteAudioDownloader.m
//  RGPlayer
//
//  Created by yangrui on 2018/11/12.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "RGRemoteAudioDownloader.h"
#import "RGRemoteAudilFileTool.h"


// 下载某一个区间的数据
@interface RGRemoteAudioDownloader ()<NSURLSessionDataDelegate>
@property(nonatomic, strong)NSURLSession *session;
@property(nonatomic, strong)NSOutputStream *outputStream;


@end
@implementation RGRemoteAudioDownloader



-(NSURLSession *)session{
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

-(void)downLoadWithUrl:(NSURL *)url offset:(long long)offset{
    
    [self cancleAndClean];
    self.url = url;
    self.offset = offset;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                           timeoutInterval:0];
    
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-",offset] forHTTPHeaderField:@"Range"];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    [task resume];
}

-(void)cancleAndClean{
    // 取消
    [self.session invalidateAndCancel];
    self.session = nil;
    
    // 清空本地缓存的临时文件
    [RGRemoteAudilFileTool clearTempFile:self.url];
    
    // 重置数据
    self.loadedSize = 0;
}

#pragma mark- NSURLSessionDataDelegate
// 从content-Length 取出长度
// 如果设置了请求头的Range, 那么content-Length 的长度并不是下载文件的总长度
// 需要从content-Range 中来获取下载文件的大小
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSHTTPURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
  
    self.totalSize = [response.allHeaderFields[@"Content-Length"] longLongValue];
    NSString *contentRangeStr = response.allHeaderFields[@"Content-Range"];
    if(contentRangeStr.length > 0){
        self.totalSize = [[[contentRangeStr componentsSeparatedByString:@"/"] lastObject] longLongValue];
    }
    
    self.mineType = response.MIMEType;
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:[RGRemoteAudilFileTool tempFilePath:self.url]
                                                          append:YES];
    [self.outputStream open];
    
    completionHandler(NSURLSessionResponseAllow);

}

-(void)URLSession:(NSURLSession *)session
         dataTask:(NSURLSessionDataTask *)dataTask
   didReceiveData:(NSData *)data{
    
    self.loadedSize += data.length;
    [self.outputStream write:data.bytes maxLength:data.length];
    if ([self.delegate respondsToSelector:@selector(downloading)]) {
        [self.delegate downloading];
    }
    
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    
    if (error == nil) {
        if ([RGRemoteAudilFileTool tempFileSize:self.url] == self.totalSize) {
            // 移动临时文件 --> cache文件夹
            [RGRemoteAudilFileTool moveTempFile2CachePath:self.url];
        }
    }
    else{
        NSLog(@"RGRemoteAudioDownloader 下载文件 出错了");
        
    }
}














@end
