//
//  RGRemoteAudilFileTool.h
//  RGPlayer
//
//  Created by yangrui on 2018/11/12.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface RGRemoteAudilFileTool : NSObject



+(NSString *)cacheFilePath:(NSURL *)url;
+(NSString *)tempFilePath:(NSURL *)url;

+(BOOL)cacheFileExists:(NSURL *)url;
+(BOOL)tempFileExists:(NSURL *)url;

+(long long)cacheFileSize:(NSURL *)url;
+(long long)tempFileSize:(NSURL *)url;

+(void)moveTempFile2CachePath:(NSURL *)url;
+(void)clearTempFile:(NSURL *)url;

+(NSString *)contentType:(NSURL *)url;

@end
