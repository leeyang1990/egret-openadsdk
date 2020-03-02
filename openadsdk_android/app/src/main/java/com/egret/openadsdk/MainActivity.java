package com.egret.openadsdk;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.widget.Toast;

import com.egret.openadsdk.sdk.RewardVideoActivity;
import com.egret.openadsdk.sdk.SplashActivity;

import org.egret.runtime.launcherInterface.INativePlayer;
import org.egret.egretnativeandroid.EgretNativeAndroid;

//Android项目发布设置详见doc目录下的README_ANDROID.md

public class MainActivity extends Activity {
    private final String TAG = "MainActivity";
    private EgretNativeAndroid nativeAndroid;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

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
    }

    public  void initJSEvent(){
        //监听来自JS的开屏视频消息
        nativeAndroid.setExternalInterface("SplashAd", new INativePlayer.INativeInterface() {
            @Override
            public void callback(String dataFromJs) {
                Intent intent = new Intent(MainActivity.this, SplashActivity.class);
                intent.putExtra("splash_rit","801121648");
                intent.putExtra("is_express", false);
            }
        });
        //监听来自JS的激励视频消息
        nativeAndroid.setExternalInterface("RewardVideoAd", new INativePlayer.INativeInterface() {
            @Override
            public void callback(String dataFromJs) {
                Intent intent = new Intent(MainActivity.this, RewardVideoActivity.class);
                intent.putExtra("horizontal_rit","901121430");
                intent.putExtra("vertical_rit","901121365");
                startActivityForResult(intent, 200);
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
        if (requestCode == 200&&resultCode == 101) {
            String name = data.getStringExtra("data");
            Log.e("videoback", name);
            send2JS("rewardvideoback",name);
        }
        //
    }

    public  void send2JS(String tag ,String json){
        nativeAndroid.callExternalInterface(tag, json);
    }
}
