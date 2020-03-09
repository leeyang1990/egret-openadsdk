#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <BUAdSDK/BUAdSDKManager.h>
#import <BUAdSDK/BUAdSDK.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate,BUSplashAdDelegate,BURewardedVideoAdDelegate,BUFullscreenVideoAdDelegate,BUBannerAdViewDelegate,BUInterstitialAdDelegate>
@property (nonatomic, assign) CFTimeInterval startTime;
@property (nonatomic, assign) UIViewController *root;
@property (nonatomic, strong) BURewardedVideoAd *rewardedVideoAd;
@property (nonatomic, strong) BUFullscreenVideoAd *fullscreenVideoAd;
@property(nonatomic, strong) BUBannerAdView *bannerView;
@property (nonatomic, strong) BUInterstitialAd *interstitialAd;
@end
