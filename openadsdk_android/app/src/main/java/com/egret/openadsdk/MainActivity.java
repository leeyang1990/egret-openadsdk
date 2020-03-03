package com.egret.openadsdk;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.widget.Toast;

import com.egret.openadsdk.sdk.ActivityCode;
import com.egret.openadsdk.sdk.RewardVideoActivity;
import com.egret.openadsdk.sdk.SplashActivity;
import com.egret.openadsdk.sdk.TTAdManagerHolder;

import org.egret.runtime.launcherInterface.INativePlayer;
import org.egret.egretnativeandroid.EgretNativeAndroid;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

//Android项目发布设置详见doc目录下的README_ANDROID.md

public class MainActivity extends Activity {
    private final String TAG = "MainActivity";
    private EgretNativeAndroid nativeAndroid;

    public static MainActivity instance = null;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        instance = this;
        nativeAndroid = new EgretNativeAndroid(this);
        if (!nativeAndroid.checkGlEsVersion()) {
            Toast.makeText(this, "This device does not support OpenGL ES 2.0.",
                    Toast.LENGTH_LONG).show();
            return;
        }

        nativeAndroid.config.showFPS = true;
        nativeAndroid.config.fpsLogTime = 30;
        nativeAndroid.config.disableNativeRender = false;
        nativeAndroid.config.clearCache = false;
        nativeAndroid.config.loadingTimeout = 0;

        setExternalInterfaces();
        
        if (!nativeAndroid.initialize("http://tool.egret-labs.org/Weiduan/game/index.html")) {
            Toast.makeText(this, "Initialize native failed.",
                    Toast.LENGTH_LONG).show();
            return;
        }

        setContentView(nativeAndroid.getRootFrameLayout());

        this.initJSEvent();

        // 申请部分权限,建议在sdk初始化前申请,如：READ_PHONE_STATE、ACCESS_COARSE_LOCATION及ACCESS_FINE_LOCATION权限，
        // 以获取更好的广告推荐效果，如read_phone_state,防止获取不了imei时候，下载类广告没有填充的问题。
        TTAdManagerHolder.get().requestPermissionIfNecessary(this);
    }

    public  void initJSEvent(){
        //监听来自JS的开屏视频消息
        nativeAndroid.setExternalInterface("TTSplashAd", new INativePlayer.INativeInterface() {
            @Override
            public void callback(String dataFromJs) {
                Intent intent = new Intent(MainActivity.this, SplashActivity.class);
                intent.putExtra("splash_rit","801121648");
                intent.putExtra("is_express", false);
                startActivityForResult(intent, ActivityCode.OPENADSDK);
            }
        });
        //监听来自JS的激励视频消息
        nativeAndroid.setExternalInterface("TTRewardVideoAd", new INativePlayer.INativeInterface() {
            @Override
            public void callback(String dataFromJs) {
                Intent intent = new Intent(MainActivity.this, RewardVideoActivity.class);
                intent.putExtra("horizontal_rit","901121430");
                intent.putExtra("vertical_rit","901121365");

                JSONObject object = null;
                try {
                    object = new JSONObject(dataFromJs);
                    Boolean is_horizontal = object.getBoolean("is_horizontal");
                    intent.putExtra("is_horizontal",is_horizontal);
                    String userID = object.getString("userID");
                    intent.putExtra("userID",userID);
                    int rewardAmount = object.getInt("rewardAmount");
                    intent.putExtra("rewardAmount",rewardAmount);
                    String rewardName = object.getString("rewardName");
                    intent.putExtra("rewardName",rewardName);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                startActivityForResult(intent, ActivityCode.OPENADSDK);
            }
        });

    }



    @Override
    protected void onPause() {
        super.onPause();
        nativeAndroid.pause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        nativeAndroid.resume();
    }

    @Override
    public boolean onKeyDown(final int keyCode, final KeyEvent keyEvent) {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            nativeAndroid.exitGame();
        }

        return super.onKeyDown(keyCode, keyEvent);
    }

    private void setExternalInterfaces() {
        nativeAndroid.setExternalInterface("sendToNative", new INativePlayer.INativeInterface() {
            @Override
            public void callback(String message) {
                String str = "Native get message: ";
                str += message;
                Log.d(TAG, str);
                nativeAndroid.callExternalInterface("sendToJS", str);
            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == ActivityCode.OPENADSDK&&resultCode == ActivityCode.SplashAd) {
            String json = data.getStringExtra("json");
            send2JS("TTSplashAd-js",json);
        }else if(requestCode == ActivityCode.OPENADSDK&&resultCode == ActivityCode.RewardVideoAd) {
            String json = data.getStringExtra("json");
            send2JS("TTRewardVideoAd-js", json);
        }
            //
    }
    public static void jsEvent(int activityCode,String json){
        if(activityCode == ActivityCode.RewardVideoAd){
            MainActivity.instance.send2JS("TTRewardVideoAd-js",json);
        }
    }

    public  void send2JS(String tag ,String json){
        Log.i("logcodeJ",json);
        nativeAndroid.callExternalInterface(tag, json);
    }
}
