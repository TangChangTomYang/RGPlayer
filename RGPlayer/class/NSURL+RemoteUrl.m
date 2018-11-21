//
//  NSURL+RemoteUrl.m
//  RGPlayer
//
//  Created by yangrui on 2018/11/12.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "NSURL+RemoteUrl.h"

@implementation NSURL (RemoteUrl)

-(NSURL *)streamingRrl{
    //http://xxxx
    NSURLComponents *components = [NSURLComponents componentsWithString:self.absoluteString];
    components.scheme = @"streaming";
    return  components.URL;
}

-(NSURL *)httpUrl{
    NSURLComponents *components = [NSURLComponents componentsWithString:self.absoluteString];
    components.scheme = @"http";
    return components.URL;
}
@end
