const sdk = {
    RewardVideoAd: "RewardVideoAd",
    SplashAd: "SplashAd",
    FullScreenVideoAd: "FullScreenVideoAd",
    BannerExpressAd: "BannerExpressAd",
    InteractionAd: "InteractionAd",
}
class openadsdk {
    public static RewardVideoAd(callBack: Function, callObj: any, json: string) {
        openadsdk.addCallBack(sdk.RewardVideoAd, callBack, callObj, json);
    }
    public static SplashAd(callBack: Function, callObj: any, json: string) {
        openadsdk.addCallBack(sdk.SplashAd, callBack, callObj, json);
    }
    public static FullScreenVideoAd(callBack: Function, callObj: any, json: string) {
        openadsdk.addCallBack(sdk.FullScreenVideoAd, callBack, callObj, json);
    }
    public static BannerExpressAd(callBack: Function, callObj: any, json: string) {
        openadsdk.addCallBack(sdk.BannerExpressAd, callBack, callObj, json);
    }
    public static InteractionAd(callBack: Function, callObj: any, json: string) {
        openadsdk.addCallBack(sdk.InteractionAd, callBack, callObj, json);
    }

    public static addCallBack(type: string, callBack: Function, callObj: any, json: string) {
        egret.ExternalInterface.addCallback("TT" + type + "-js", function (message: string) {
            if (callBack && callObj) {
                callBack.apply(callObj, [message]);
            }
        });
        egret.ExternalInterface.call("TT" + type, json);
    }
}