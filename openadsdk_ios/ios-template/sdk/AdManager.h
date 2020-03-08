//
//  AdManager.h
//  ios-template
//
//  Created by ani on 2020/3/6.
//  Copyright © 2020 egret. All rights reserved.
//
// SDK
#define normal_banner_ID                  @"900546859"
#define normal_interstitial_ID            @"900546957"
#define normal_reward_ID                  @"900546826"
#define normal_reward_landscape_ID        @"900546319"
#define normal_fullscreen_ID              @"900546299"
#define normal_fullscreen_landscape_ID    @"900546154"
#define normal_splash_ID                  @"800546808"
#define appKey                            @"5000546"
#define RewardVideoAdEvent                @"TTRewardVideoAd-js"
#define SplashAdEvent                     @"TTSplashAd-js"
#define FullScreenVideoAdEvent            @"TTFullScreenVideoAd-js"
#define BannerExpressAdEvent              @"TTBannerExpressAd-js"
#define InteractionAdEvent                @"TTInteractionAd-js"

#define onAdClicked                       @"onAdClicked"//广告点击
#define onAdShow                          @"onAdShow"//广告出现
#define onAdDismiss                       @"onAdDismiss"//插屏广告关闭
#define onError                           @"onError"//错误
#define onSelected                        @"onSelected"//banner关闭按钮
#define onCancel                          @"onCancel"//点击取消
#define onAdVideoBarClick                 @"onAdVideoBarClick"//视频类bar点击
#define onAdClose                         @"onAdClose"//广告关闭
#define onVideoComplete                   @"onVideoComplete"//视频类播放完成
#define onVideoError                      @"onVideoError"//视频类错误
#define onRewardVerify                    @"onRewardVerify"//激励确认
#define onSkippedVideo                    @"onSkippedVideo"//视频类跳过

#import <Foundation/Foundation.h>
#import <EgretNativeIOS.h>
@interface AdManager : NSObject
+(NSDictionary *)objectConvertByJsonStr:(NSString *)jsonStr;
+(NSString *)jsonStrConvertByObject:(NSMutableDictionary *)dict;
@end
