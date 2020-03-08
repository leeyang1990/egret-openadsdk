//
//  AppDelegate+Category.m
//  openadsdk
//
//  Created by liyang on 2020/3/7.
//  Copyright © 2020 egret. All rights reserved.
//

#import "AppDelegate+Category.h"

//#import <AppKit/AppKit.h>
#import "AdManager.h"
#import "BUDMacros.h"
#import <objc/runtime.h>
static EgretNativeIOS* _native;
@interface AppDelegate ()
@end
@implementation AppDelegate (Category)
-(void)InitAD:(UIViewController*)viewcontroller{
    self.root = viewcontroller;
    [self setupBUAdSDK];
//    [self Log];
}

- (void)setupBUAdSDK {
    //BUAdSDK requires iOS 9 and up
    [BUAdSDKManager setAppID:appKey];
#if DEBUG
    // Whether to open log. default is none.
    [BUAdSDKManager setLoglevel:BUAdSDKLogLevelDebug];
#endif
    [BUAdSDKManager setIsPaidApp:NO];
    
    // splash AD
    [self addSplashAD];
}
-(void)initJSEvent:(EgretNativeIOS*)native{
    _native= native;
    __weak EgretNativeIOS* support = _native;
    [support setExternalInterface:@"TTSplashAd" Callback:^(NSString *message) {
        //开屏广告
        printf("开屏广告");
        [self addSplashAD];
    }];
    [support setExternalInterface:@"TTFullScreenVideoAd" Callback:^(NSString *message) {
        //全屏广告
        printf("全屏广告");
        NSDictionary *dict = [AdManager objectConvertByJsonStr:message];
        if(![[dict valueForKey:@"is_horizontal"] isEqual:@YES]){
            [self loadFullscreenVideoAdWithSlotID:normal_fullscreen_ID];
        }else{
            [self loadFullscreenVideoAdWithSlotID:normal_fullscreen_landscape_ID];
        }
    }];
    [support setExternalInterface:@"TTRewardVideoAd" Callback:^(NSString *message) {
        //激励广告
        printf("激励广告");
        NSDictionary *dict = [AdManager objectConvertByJsonStr:message];
        if(![[dict valueForKey:@"is_horizontal"] isEqual:@YES]){
            [self loadRewardVideoAdWithSlotIDAndDic:normal_reward_ID :dict];
        }else{
            [self loadRewardVideoAdWithSlotIDAndDic:normal_reward_landscape_ID :dict];
        }
    }];
    [_native setExternalInterface:@"TTBannerExpressAd" Callback:^(NSString *message) {
        //banner广告
        NSDictionary *dict = [AdManager objectConvertByJsonStr:message];
        printf("banner广告");
        [self loadBanner:[dict valueForKey:@"is_top"]];
    }];
    [_native setExternalInterface:@"TTInteractionAd" Callback:^(NSString *message) {
        //插屏广告
        printf("插屏广告");
        [self loadInterstitial];
    }];
}
-(void) sendSingleEventToJS:(NSString*)name :(NSString*)event{
    NSMutableDictionary *dict1 = [NSMutableDictionary dictionary];
    [dict1 setObject:event forKey:@"event"];
    NSString *str = [AdManager jsonStrConvertByObject:dict1];
    if(_native){
        [_native callExternalInterface:name Value:str];
    }
}
#pragma mark - splash
- (void)addSplashAD {
    CGRect frame = [UIScreen mainScreen].bounds;
    BUSplashAdView *splashView = [[BUSplashAdView alloc] initWithSlotID:normal_splash_ID frame:frame];
    // tolerateTimeout = CGFLOAT_MAX , The conversion time to milliseconds will be equal to 0
    splashView.tolerateTimeout = 10;
    splashView.delegate = self;
    
    self.startTime = CACurrentMediaTime();
    [splashView loadAdData];
    [self.root.view addSubview:splashView];
    splashView.rootViewController = self.root;
}
#pragma mark - splash-delegate
- (void)splashAdDidClose:(BUSplashAdView *)splashAd {
    [splashAd removeFromSuperview];
    CFTimeInterval endTime = CACurrentMediaTime();
    BUD_Log(@"Total Runtime: %g s", endTime - self.startTime);
    [self sendSingleEventToJS:SplashAdEvent :onAdClose];
}

- (void)splashAd:(BUSplashAdView *)splashAd didFailWithError:(NSError *)error {
    [splashAd removeFromSuperview];
    CFTimeInterval endTime = CACurrentMediaTime();
    BUD_Log(@"Total Runtime: %g s error=%@", endTime - self.startTime, error);
    [self sendSingleEventToJS:SplashAdEvent :onError];
}

- (void)splashAdWillVisible:(BUSplashAdView *)splashAd {
    CFTimeInterval endTime = CACurrentMediaTime();
    BUD_Log(@"Total Showtime: %g s", endTime - self.startTime);
    [self sendSingleEventToJS:SplashAdEvent :onAdShow];
}
#pragma mark - reward
- (void)loadRewardVideoAdWithSlotIDAndDic:(NSString *)slotID :(NSDictionary*)dict {
#warning Every time the data is requested, a new one BURewardedVideoAd needs to be initialized. Duplicate request data by the same full screen video ad is not allowed.
    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
    model.userId = [dict valueForKey:@"userID"];
    model.rewardAmount = [(NSNumber*)[dict valueForKey:@"rewardAmount"] integerValue];
    model.rewardName = [dict valueForKey: @"rewardName"];
    self.rewardedVideoAd = [[BURewardedVideoAd alloc] initWithSlotID:slotID rewardedVideoModel:model];
    self.rewardedVideoAd.delegate = self;
    [self.rewardedVideoAd loadAdData];
}

- (void)showRewardVideoAd {
    if (self.rewardedVideoAd) {
        [self.rewardedVideoAd showAdFromRootViewController:[self root]];
    }
}
#pragma mark - reward-delegate
- (void)rewardedVideoAdDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    BUD_Log(@"%st",__func__);
    BUD_Log(@"mediaExt-%@",rewardedVideoAd.mediaExt);
}

- (void)rewardedVideoAdVideoDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    BUD_Log(@"%s",__func__);
    [self showRewardVideoAd];
}
- (void)rewardedVideoAdServerRewardDidSucceed:(BURewardedVideoAd *)rewardedVideoAd verify:(BOOL)_verify{
    BUD_Log(@"%s",__func__);
    NSMutableDictionary *dict1 = [NSMutableDictionary dictionary];
    NSString *event = onRewardVerify;
    NSObject *verify= _verify? @YES : @NO;
    NSNumber *amount = @(rewardedVideoAd.rewardedVideoModel.rewardAmount);
    NSString *name = rewardedVideoAd.rewardedVideoModel.rewardName;
    NSString *userId = rewardedVideoAd.rewardedVideoModel.userId;
    [dict1 setObject:event forKey:@"event"];
    [dict1 setObject:verify forKey:@"verify"];
    [dict1 setObject:amount forKey:@"amount"];
    [dict1 setObject:name forKey:@"name"];
    [dict1 setObject:userId forKey:@"userId"];
    NSString *str = [AdManager jsonStrConvertByObject:dict1];
    
    if(_native){
        [_native callExternalInterface:RewardVideoAdEvent Value:str];
    }
    
}
- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    BUD_Log(@"%s",__func__);
    NSLog(@"error code : %ld , error message : %@",(long)error.code,error.description);
    [self sendSingleEventToJS:RewardVideoAdEvent :onError];
}

- (void)rewardedVideoAdWillVisible:(BURewardedVideoAd *)rewardedVideoAd {
    BUD_Log(@"%s",__func__);
    [self sendSingleEventToJS:RewardVideoAdEvent :onAdShow];
}

- (void)rewardedVideoAdDidClose:(BURewardedVideoAd *)rewardedVideoAd {
    BUD_Log(@"%s",__func__);
    [self sendSingleEventToJS:RewardVideoAdEvent :onAdClose];
}

- (void)rewardedVideoAdDidClick:(BURewardedVideoAd *)rewardedVideoAd {
    BUD_Log(@"%s",__func__);
    [self sendSingleEventToJS:RewardVideoAdEvent :onAdClicked];
}

- (void)rewardedVideoAdDidPlayFinish:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    BUD_Log(@"%s",__func__);
    [self sendSingleEventToJS:RewardVideoAdEvent :onVideoComplete];
}

- (void)rewardedVideoAdServerRewardDidFail:(BURewardedVideoAd *)rewardedVideoAd {
    BUD_Log(@"%s",__func__);
}


- (void)rewardedVideoAdClientRewardDidSucceed:(BURewardedVideoAd *)rewardedVideoAd {
    BUD_Log(@"%s",__func__);
}



#pragma mark - fullscreen
- (void)loadFullscreenVideoAdWithSlotID:(NSString *)slotID {
#warning----- Every time the data is requested, a new one BUFullscreenVideoAd needs to be initialized. Duplicate request data by the same full screen video ad is not allowed.
    self.fullscreenVideoAd = [[BUFullscreenVideoAd alloc] initWithSlotID:slotID];
    self.fullscreenVideoAd.delegate = self;
    [self.fullscreenVideoAd loadAdData];
}

- (void)showFullscreenVideoAd {
    if (self.fullscreenVideoAd) {
        [self.fullscreenVideoAd showAdFromRootViewController:[self root]];
    }
}

#pragma mark - fullscreen-delegate
- (void)fullscreenVideoMaterialMetaAdDidLoad:(BUFullscreenVideoAd *)fullscreenVideoAd {
    BUD_Log(@"%s",__func__);
    [self showFullscreenVideoAd];
}

- (void)fullscreenVideoAdVideoDataDidLoad:(BUFullscreenVideoAd *)fullscreenVideoAd {
    BUD_Log(@"%s",__func__);
    
}

- (void)fullscreenVideoAd:(BUFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *)error {
    BUD_Log(@"%s",__func__);
    NSLog(@"error code : %ld , error message : %@",(long)error.code,error.description);
    [self sendSingleEventToJS:FullScreenVideoAdEvent :onError];
}

- (void)fullscreenVideoAdDidClickSkip:(BUFullscreenVideoAd *)fullscreenVideoAd {
    BUD_Log(@"%s",__func__);
    [self sendSingleEventToJS:FullScreenVideoAdEvent :onSkippedVideo];
}

- (void)fullscreenVideoAdDidClick:(BUFullscreenVideoAd *)fullscreenVideoAd {
    BUD_Log(@"%s",__func__);
    [self sendSingleEventToJS:FullScreenVideoAdEvent :onAdClicked];
}

- (void)fullscreenVideoAdDidClose:(BUFullscreenVideoAd *)fullscreenVideoAd {
    BUD_Log(@"%s",__func__);
    [self sendSingleEventToJS:FullScreenVideoAdEvent :onAdClose];
}

#pragma mark - banner
- (void)loadBanner:(NSObject*)is_top {
    [self.bannerView removeFromSuperview];
    //是否滚动
    NSObject* isSlide = @YES;
    BUSize *size = [BUSize sizeBy:BUProposalSize_Banner600_150];
    if (isSlide) {
        self.bannerView = [[BUBannerAdView alloc] initWithSlotID:normal_banner_ID size:size rootViewController:self.root interval:30];
    } else {
        self.bannerView = [[BUBannerAdView alloc] initWithSlotID:normal_banner_ID size:size rootViewController:self.root];
    }
    const CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    
    CGFloat bannerHeight = screenWidth * size.height / size.width;

    if(![is_top isEqual:@YES]){
        self.bannerView.frame = CGRectMake(0, self.root.view.frame.size.height-bannerHeight, screenWidth, bannerHeight);
    }else{
        self.bannerView.frame = CGRectMake(0, 0, screenWidth, bannerHeight);
    }
    
    
    self.bannerView.delegate = self;
    [self.bannerView loadAdData];
    [self.root.view addSubview:self.bannerView];
}

#pragma mark - banner-delegate
- (void)bannerAdViewDidLoad:(BUBannerAdView * _Nonnull)bannerAdView WithAdmodel:(BUNativeAd *_Nullable)admodel {
    BUD_Log(@"%s",__func__);
}

- (void)bannerAdViewDidBecomVisible:(BUBannerAdView *_Nonnull)bannerAdView WithAdmodel:(BUNativeAd *_Nullable)admodel {
    BUD_Log(@"%s",__func__);
    [self sendSingleEventToJS:BannerExpressAdEvent :onAdShow];
}

- (void)bannerAdViewDidClick:(BUBannerAdView *_Nonnull)bannerAdView WithAdmodel:(BUNativeAd *_Nullable)admodel {
    BUD_Log(@"%s",__func__);
    [self sendSingleEventToJS:BannerExpressAdEvent :onAdClicked];
}

- (void)bannerAdView:(BUBannerAdView *_Nonnull)bannerAdView didLoadFailWithError:(NSError *_Nullable)error {
    BUD_Log(@"%s",__func__);
    NSLog(@"error code : %ld , error message : %@",(long)error.code,error.description);
    [self sendSingleEventToJS:BannerExpressAdEvent :onError];
}

- (void)bannerAdView:(BUBannerAdView *)bannerAdView dislikeWithReason:(NSArray<BUDislikeWords *> *)filterwords {
    BUD_Log(@"%s",__func__);
    [UIView animateWithDuration:0.25 animations:^{
        bannerAdView.alpha = 0;
    } completion:^(BOOL finished) {
        [bannerAdView removeFromSuperview];
        if (self.bannerView == bannerAdView) {
            self.bannerView = nil;
        }
    }];
    [self sendSingleEventToJS:BannerExpressAdEvent :onSelected];
    [self sendSingleEventToJS:BannerExpressAdEvent :onAdClose];
}

- (void)bannerAdViewDidCloseOtherController:(BUBannerAdView *)bannerAdView interactionType:(BUInteractionType)interactionType {
    BUD_Log(@"%s",__func__);
}

#pragma mark - interstitial
- (void)loadInterstitial {
    self.interstitialAd = [[BUInterstitialAd alloc] initWithSlotID:normal_interstitial_ID size:[BUSize sizeBy:BUProposalSize_Interstitial600_600]];
    self.interstitialAd.delegate = self;
    [self.interstitialAd loadAdData];

}
#pragma mark - interstitial-delegate
- (void)interstitialAdDidClose:(BUInterstitialAd *)interstitialAd {
    [self.interstitialAd loadAdData];
     BUD_Log(@"interstitialAd AdDidClose");
    [self sendSingleEventToJS:InteractionAdEvent :onAdClose];
}


- (void)interstitialAdDidLoad:(BUInterstitialAd *)interstitialAd {
    BUD_Log(@"interstitialAd data load sucess");
    [self.interstitialAd showAdFromRootViewController:self.root];
}


- (void)interstitialAd:(BUInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    BUD_Log(@"interstitialAd data load fail");
    NSLog(@"error code : %ld , error message : %@",(long)error.code,error.description);
    [self sendSingleEventToJS:BannerExpressAdEvent :onError];
}

- (void)interstitialAdDidCloseOtherController:(BUInterstitialAd *)interstitialAd interactionType:(BUInteractionType)interactionType {
    NSString *str = @"";
    if (interactionType == BUInteractionTypePage) {
        str = @"ladingpage";
    } else if (interactionType == BUInteractionTypeVideoAdDetail) {
        str = @"videoDetail";
    } else {
        str = @"appstoreInApp";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:str message:[NSString stringWithFormat:@"%s",__func__] delegate:self cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
    [alert show];
}

@end
