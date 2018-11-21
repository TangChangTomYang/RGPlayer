//
//  RGRemotePlayerResourceLoaderDelegate.m
//  RGPlayer
//
//  Created by yangrui on 2018/11/12.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "RGRemotePlayerResourceLoaderDelegate.h"
#import "RGRemoteAudioDownloader.h"
#import "NSURL+RemoteUrl.h"
#import "RGRemoteAudilFileTool.h"

@interface RGRemotePlayerResourceLoaderDelegate ()<RGRemoteAudioDownloaderDelegate>

@property(nonatomic, strong)RGRemoteAudioDownloader *downloader;
@property(nonatomic, strong)NSMutableArray *loadingRequestArrM;
@end


@implementation RGRemotePlayerResourceLoaderDelegate

-(RGRemoteAudioDownloader *)downloader{
    if(!_downloader){
        _downloader = [[RGRemoteAudioDownloader alloc] init];
        _downloader.delegate = self;
    }
    return _downloader;
}

-(NSMutableArray *)loadingRequestArrM{
    if(!_loadingRequestArrM){
        _loadingRequestArrM = [NSMutableArray array];
    }
    return _loadingRequestArrM;
}

#pragma mark- RGRemoteAudioDownloaderDelegate
// 当外界需要播放一段音频资源时, 会抛出一个请求给这个对象
// 这个对象需要根据请求的信息, 将请求到的数据再给外界
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader
shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
    
    NSLog(@">>>>>loadingRequest : %@", loadingRequest);
    
    NSURL *httpUrl = [loadingRequest.request.URL httpUrl];
    
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    long long currentOffset = loadingRequest.dataRequest.currentOffset;
    if(requestOffset != currentOffset){
        requestOffset = currentOffset;
    }
    
    
    //1. 判断, 本地是否有该音频的缓存文件, 如果有, 直接根据本地缓存,向外提供数据
    if([RGRemoteAudilFileTool cacheFileExists:httpUrl]){
        [self handleLoadingRequest:loadingRequest];
        return YES;
    }
    
    //记录所有的请求
    [self.loadingRequestArrM addObject:loadingRequest];
    
    //2.判断有没有正在下载
    if(self.downloader.loadedSize == 0){
        
        [self.downloader  downLoadWithUrl:httpUrl offset:requestOffset];
        //开始下载数据(根据请求的信息, url, requestOffset, requestLength)
        return YES;
    }
    
    //3.判断当前是否需要重新下载
    //3.1 当资源请求, 开始点 < 下载的开始点
    //3.2 当资源的请求, 开始点 > 下载的开始点 + 下载的长度 + 666(缓冲区 自定义)
    if(requestOffset < self.downloader.offset ||
       requestOffset > (self.downloader.offset + self.downloader.loadedSize + 666)){
        
        [self.downloader downLoadWithUrl:httpUrl offset:requestOffset];
        return YES;
    }
    
    //开始处理资源请求(在下载过程中, 也要不断的判断)
    //4. 不需要再请求, 当前正在进行中的请求可直接响应
    [self handkeAllLoadingRequest];

    
    return YES;
}

// 取消请求
-(void)resourceLoader:(AVAssetResourceLoader *)resourceLoader
didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSLog(@" 取消某个请求");
    [self.loadingRequestArrM removeObject:loadingRequest];
}

#pragma mark- RGRemoteAudioDownloaderDelegate
-(void)downloading{
    [self handkeAllLoadingRequest];
}

#pragma mark- 处理响应
//
-(void)handkeAllLoadingRequest{
    
    NSMutableArray *deleteRequestArrM = [NSMutableArray array];
    
    for (AVAssetResourceLoadingRequest *loadingRequest in self.loadingRequestArrM) {
        
        //1. 填充内容信息头
        NSURL *url = loadingRequest.request.URL;
        
        long long totalSize = self.downloader.totalSize;
        loadingRequest.contentInformationRequest.contentLength = totalSize;// 这个应该是文件的总大小
        
        NSString *contentType = self.downloader.mineType;
        loadingRequest.contentInformationRequest.contentType = contentType;
        
        loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES; // 是否允许一点一点的传输数据
        
        
        //2. 填充数据(数据 和 地址映射关系防止内存爆炸)
        NSData *data = [NSData dataWithContentsOfFile:[RGRemoteAudilFileTool tempFilePath:url]
                                              options:NSDataReadingMappedIfSafe
                                                error:nil];
        
        if (data.length == 0) {// 如果临时没有数据,就取缓存数据
            data = [NSData dataWithContentsOfFile:[RGRemoteAudilFileTool cacheFilePath:url]
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
        }
        
        //requestOffset 表示的是发出请求那一刻时的offset
        long long requestOffset = loadingRequest.dataRequest.requestedOffset;
        //currentOffset (比如: 已经对request 响应了一段数据,那么当前的offset 就会变为currentOffset的值)
        long long currentOffset = loadingRequest.dataRequest.currentOffset;
        if (requestOffset != currentOffset) {
            requestOffset = currentOffset;
        }
        NSInteger requestLength = loadingRequest.dataRequest.requestedLength;
        
        
        
        //响应的offset 要减去请求时的Offset
        long long responseOffset = requestOffset - self.downloader.offset;
        //响应的长度 取最小的
        long long responseLength = MIN((self.downloader.offset + self.downloader.loadedSize - requestOffset ), requestLength);
        
        NSData *subData = [data subdataWithRange:NSMakeRange(responseOffset, responseLength)];
        [loadingRequest.dataRequest respondWithData:subData];
        
        //3.请求完成, (必须把所有的关于这个请求区间的数据, 都返回完毕后, 才能完成这个请求)
        if(requestLength == responseLength){
            [loadingRequest finishLoading];
            [deleteRequestArrM addObject:loadingRequest];
        }
    }
    
    [self.loadingRequestArrM removeObjectsInArray:deleteRequestArrM];
}


//处理, 本地已经下载好的资源文件
-(void)handleLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    
    //1. 填充相应的信息头信息
    //计算大小
    NSURL *url = [loadingRequest.request.URL httpUrl];
    long long totalSize = [RGRemoteAudilFileTool cacheFileSize:url];
    loadingRequest.contentInformationRequest.contentLength = totalSize;
    
    NSString *contentType = [RGRemoteAudilFileTool contentType:url];
    loadingRequest.contentInformationRequest.contentType = contentType;
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    
    //2.
    NSData *data = [NSData dataWithContentsOfFile:[RGRemoteAudilFileTool  cacheFilePath:url]
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    NSUInteger requestLength = loadingRequest.dataRequest.requestedLength;
    // 有必要判断越界? offset+length
    NSData *subData = [data subdataWithRange:NSMakeRange(requestOffset, requestLength)];
    [loadingRequest.dataRequest respondWithData:subData];
    
    //3.完成本地请求(所有数据都给完了才能调)
    [loadingRequest finishLoading];
}




@end
