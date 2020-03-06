//
//  AdManager.m
//  openadsdk
//
//  Created by ani on 2020/3/6.
//  Copyright © 2020 egret. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdManager.h"
#import <EgretNativeIOS.h>
@implementation AdManager

+(void)initJSEvent:(EgretNativeIOS*)_native{
    [_native setExternalInterface:@"TTSplashAd" Callback:^(NSString *message) {
        //开屏广告
        printf("开屏广告");
    }];
    [_native setExternalInterface:@"TTFullScreenVideoAd" Callback:^(NSString *message) {
        //全屏广告
        printf("全屏广告");
    }];
    [_native setExternalInterface:@"TTRewardVideoAd" Callback:^(NSString *message) {
        //激励广告
        printf("激励广告");
      
    }];
    [_native setExternalInterface:@"TTBannerExpressAd" Callback:^(NSString *message) {
        //banner广告
        printf("banner广告");
    }];
    [_native setExternalInterface:@"TTInteractionAd" Callback:^(NSString *message) {
        //插屏广告
        printf("插屏广告");
    }];
}
+(NSDictionary *)objectConvertByJsonStr:(NSString *)jsonStr{
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"error:%@",error);
    }
    return dict;
}
+(NSString *)jsonStrConvertByObject:(NSDictionary *)dict{
    if ([NSJSONSerialization isValidJSONObject:dict]) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        NSString *resultStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        return resultStr;
    }else{
        return nil;
    }
}
@end
