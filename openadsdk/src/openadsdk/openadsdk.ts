const sdk = {
    RewardVideoAd: "RewardVideoAd",
    SplashAd: "SplashAd"
}
class openadsdk {
    public static RewardVideoAd(callBack: Function, callObj: any, json: string) {
        openadsdk.addCallBack(sdk.RewardVideoAd, callBack, callObj, json);
    }
    public static SplashAd(callBack: Function, callObj: any,json: string) {
        openadsdk.addCallBack(sdk.SplashAd, callBack, callObj, json);
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