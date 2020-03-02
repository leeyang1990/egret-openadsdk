class openadsdk {
    public static sdk = "TT";
    public static RewardVideoAd(callBack: Function,callObj: any) {
        egret.ExternalInterface.addCallback(openadsdk.sdk+"RewardVideoAd-js", function (message: string) {
            console.log("reward : " + message);
            if (callBack && callObj) {
					callBack.apply(callObj);
				}
        });
        egret.ExternalInterface.call(openadsdk.sdk+"RewardVideoAd", "message from js");
    }
    public static SplashAd(callBack: Function,callObj: any) {
        egret.ExternalInterface.addCallback(openadsdk.sdk+"SplashAd-js", function (message: string) {
            console.log("splash : " + message);
            if (callBack && callObj) {
					callBack.apply(callObj);
				}
        });
        egret.ExternalInterface.call(openadsdk.sdk+"SplashAd", "message from js");
    }
}