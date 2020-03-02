class openadsdk {
    public static TTRewardVideoAd(callBack: Function,callObj: any) {
        egret.ExternalInterface.addCallback("TTRewardVideoAd", function (message: string) {
            console.log("splash : " + message);//message form native : message from native
            if (callBack && callObj) {
					callBack.apply(callObj);
				}
        });
        egret.ExternalInterface.call("TTRewardVideoAd", "message from js");
    }
}