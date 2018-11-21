//
//  RGRemoteAudioDownloader.h
//  RGPlayer
//
//  Created by yangrui on 2018/11/12.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol RGRemoteAudioDownloaderDelegate <NSObject>

-(void)downloading;
@end


@interface RGRemoteAudioDownloader : NSObject


@property(nonatomic, weak)id<RGRemoteAudioDownloaderDelegate>  delegate;

@property(nonatomic, assign)long long  totalSize;
@property(nonatomic, assign)long long  loadedSize;
@property(nonatomic, assign)long long  offset;
@property(nonatomic, copy)NSString *mineType;
@property(nonatomic, strong)NSURL *url;


-(void)downLoadWithUrl:(NSURL *)url offset:(long long)offset;
@end
