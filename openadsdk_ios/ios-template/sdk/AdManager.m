//
//  AdManager.m
//  openadsdk
//
//  Created by ani on 2020/3/6.
//  Copyright © 2020 egret. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdManager.h"
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
        NSDictionary *dict = [AdManager objectConvertByJsonStr:message];
        for (NSString *key in dict) {
         NSLog(@"key: %@ value: %@", key, dict[key]);
        }
        NSMutableDictionary *dict1 = [NSMutableDictionary dictionary];
        NSString *event = @"event";
        NSObject *verify = @YES;
        NSNumber *amount = [NSNumber numberWithInt:1];
        NSString *name = @"金币";
        [dict1 setObject:event forKey:@"event"];
        [dict1 setObject:verify forKey:@"verify"];
        [dict1 setObject:amount forKey:@"amount"];
        [dict1 setObject:name forKey:@"name"];
        NSString *str = [AdManager jsonStrConvertByObject:dict1];
        __block EgretNativeIOS* support = _native;
        [support callExternalInterface:@"TTRewardVideoAd-js" Value:str];
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
+(NSString *)jsonStrConvertByObject:(NSMutableDictionary *)dict{
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
