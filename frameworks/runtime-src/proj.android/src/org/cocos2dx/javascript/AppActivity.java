/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2011      Zynga Inc.
Copyright (c) 2013-2014 Chukong Technologies Inc.
 
http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package org.cocos2dx.javascript;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;
import jp.co.imobile.sdkads.android.ImobileSdkAd;
import jp.co.imobile.sdkads.android.ImobileSdkAdListener;
import android.os.Bundle;
import android.widget.FrameLayout;
import android.widget.FrameLayout.LayoutParams;
import android.view.Gravity;
import android.view.KeyEvent; 
import android.R;

public class AppActivity extends Cocos2dxActivity {
    static final String IMOBILE_BANNER_PID="32640";
    static final String IMOBILE_BANNER_MID="161737";
    static final String IMOBILE_BANNER_SID="429126";

    static final String IMOBILE_INTERSTITIAL_PID = "32640";
    static final String IMOBILE_INTERSTITIAL_MID = "161737";
    static final String IMOBILE_INTERSTITIAL_SID = "435871";

	@Override
    protected void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // スポット情報を設定します
        ImobileSdkAd.registerSpotInline(this, IMOBILE_BANNER_PID, IMOBILE_BANNER_MID, IMOBILE_BANNER_SID);
        // 広告の取得を開始します
        ImobileSdkAd.start(IMOBILE_BANNER_SID);
        
        // スポット情報を設定します
        ImobileSdkAd.registerSpotFullScreen(this, IMOBILE_INTERSTITIAL_PID, IMOBILE_INTERSTITIAL_MID, IMOBILE_INTERSTITIAL_SID);
        // 広告の取得を開始します
        ImobileSdkAd.start(IMOBILE_INTERSTITIAL_SID);
        
        // 広告を表示するViewを作成します
        FrameLayout imobileAdLayout = new FrameLayout(this);
        FrameLayout.LayoutParams imobileAdLayoutParam = new FrameLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
        // 広告の表示位置を指定
        imobileAdLayoutParam.gravity = (Gravity.BOTTOM | Gravity.CENTER);
        //広告を表示するLayoutをActivityに追加します
        addContentView(imobileAdLayout, imobileAdLayoutParam);
        // 広告を表示します
        ImobileSdkAd.showAd(this, IMOBILE_BANNER_SID, imobileAdLayout);
    }

    //戻るボタン（Backキー）押下で広告を表示
    /*
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            //3. 広告表示
            ImobileSdkAd.showAdForce(this, IMOBILE_INTERSTITIAL_SID, new ImobileSdkAdListener() {
                //4.広告が閉じられた場合（閉じるボタン、もしくはクリックボタンがタップされた場合）
                @Override
                public void onAdCloseCompleted() {
                    //5.広告が閉じられた場合、Activityを終了させます
                    AppActivity.this.finish();
                }
            });
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }*/

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        if (event.getAction() == KeyEvent.ACTION_UP) {
            switch (event.getKeyCode()) {
            case KeyEvent.KEYCODE_BACK:
                //3. 広告表示
                ImobileSdkAd.showAdForce(this, IMOBILE_INTERSTITIAL_SID, new ImobileSdkAdListener() {
                    //4.広告が閉じられた場合（閉じるボタン、もしくはクリックボタンがタップされた場合）
                    @Override
                    public void onAdCloseCompleted() {
                        //5.広告が閉じられた場合、Activityを終了させます
                        AppActivity.this.finish();
                    }
                });
                return true;
            }
        }
        return super.dispatchKeyEvent(event);
    }

    @Override
    protected void onDestroy() {
        // Activity廃棄時の後処理
        ImobileSdkAd.activityDestory();
        super.onDestroy();
    }

    @Override
    public Cocos2dxGLSurfaceView onCreateView() {
        Cocos2dxGLSurfaceView glSurfaceView = new Cocos2dxGLSurfaceView(this);
        // TestCpp should create stencil buffer
        glSurfaceView.setEGLConfigChooser(5, 6, 5, 0, 16, 8);

        return glSurfaceView;
    }
}
