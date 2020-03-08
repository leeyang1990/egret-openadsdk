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
