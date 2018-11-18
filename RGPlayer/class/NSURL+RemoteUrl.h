//
//  NSURL+RemoteUrl.h
//  RGPlayer
//
//  Created by yangrui on 2018/11/12.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (RemoteUrl)

-(NSURL *)streamingRrl;
-(NSURL *)httpUrl;
@end
