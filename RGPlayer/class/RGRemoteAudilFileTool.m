//
//  RGRemoteAudilFileTool.m
//  RGPlayer
//
//  Created by yangrui on 2018/11/12.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "RGRemoteAudilFileTool.h"
#import <MobileCoreServices/MobileCoreServices.h> // 获取文件的MineType


#define KcachePath  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
#define KtempPath   NSTemporaryDirectory()

@implementation RGRemoteAudilFileTool

+(NSString *)cacheFilePath:(NSURL *)url{

    NSString *name = url.lastPathComponent;
    NSString *path = [KcachePath stringByAppendingPathComponent:name];
    return path;
    
}
+(NSString *)tempFilePath:(NSURL *)url{
    NSString *name = url.lastPathComponent;
    NSString *path = [KtempPath stringByAppendingPathComponent:name];
    return path;
}

+(BOOL)cacheFileExists:(NSURL *)url{
    NSString *cachePath = [self cacheFilePath:url];
    BOOL isDirectory;
    BOOL isExists =[[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDirectory];
    return (isDirectory == NO && isExists == YES);
}

+(BOOL)tempFileExists:(NSURL *)url{
    NSString *tempPath = [self tempFilePath:url];
    BOOL isDirectory;
    BOOL isExists =[[NSFileManager defaultManager] fileExistsAtPath:tempPath isDirectory:&isDirectory];
    return (isDirectory == NO && isExists == YES);
}

+(long long)cacheFileSize:(NSURL *)url{
    if (![self cacheFileExists:url])return 0;

    NSString *cachePath = [self cacheFilePath:url];
    NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:cachePath error:nil];
    return  [info[NSFileSize] longLongValue];
}
+(long long)tempFileSize:(NSURL *)url{
    if (![self tempFileExists:url]) return  0;
    
    NSString *tempPath = [self tempFilePath:url];
    NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:tempPath error:nil];
    return  [info[NSFileSize] longLongValue];
}

+(void)moveTempFile2CachePath:(NSURL *)url{
    if ([self tempFileExists:url]) {
        [[NSFileManager defaultManager] moveItemAtPath:[self tempFilePath:url]
                                                toPath:[self cacheFilePath:url]
                                                 error:nil];
    }
    
}
+(void)clearTempFile:(NSURL *)url{
    if ([self tempFileExists:url]) {
        [[NSFileManager defaultManager] removeItemAtPath:[self tempFilePath:url] error:nil];
    }
}

+(NSString *)contentType:(NSURL *)url{
    
    NSString *contentType = @"";
    NSString *filePath = @"";
    NSString *fileExtension = @"";
    if([self cacheFileExists:url]){
        filePath = [self cacheFilePath:url];
        fileExtension = filePath.pathExtension;
        CFStringRef contentTypeCF = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef _Nonnull)(fileExtension), NULL);
        contentType = CFBridgingRelease(contentTypeCF);
        return contentType;
    }
    
    if([self tempFileExists:url]){
        filePath = [self tempFilePath:url];
        fileExtension = filePath.pathExtension;
        CFStringRef contentTypeCF = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef _Nonnull)(fileExtension), NULL);
        contentType = CFBridgingRelease(contentTypeCF);
        return contentType;
    }
    
    return contentType;
    
    
}

@end
