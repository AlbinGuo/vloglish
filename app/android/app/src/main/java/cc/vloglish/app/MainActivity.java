package cc.vloglish.app;

import android.os.Bundle;
import android.view.View;
import android.webkit.WebSettings;
import android.webkit.WebView;
import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {
    private boolean qiniuClientAttached = false;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        applyWebViewTweaks();
    }

    @Override
    public void onStart() {
        super.onStart();
        applyWebViewTweaks();
    }

    private void applyWebViewTweaks() {
        if (this.bridge == null || this.bridge.getWebView() == null) {
            return;
        }
        WebView webView = this.bridge.getWebView();
        WebSettings settings = webView.getSettings();
        // 兜底：允许 https 页面加载 http 媒体（主路径已把七牛链升为 https）
        settings.setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);
        // 进入详情后由页面逻辑自动 play；不要再向用户手势拦截
        settings.setMediaPlaybackRequiresUserGesture(false);
        // 部分机型暂停后再 play 需要硬件合成层
        webView.setLayerType(View.LAYER_TYPE_HARDWARE, null);
        // 旧 WebView 兼容：确保本地资源与 DOM 存储可用
        settings.setDomStorageEnabled(true);
        settings.setAllowFileAccess(true);
        // 部分国产机默认缩放/字号异常，固定为正常档
        settings.setTextZoom(100);
        // 七牛 Referer 防盗链：补上站点 Referer，避免 App 源 https://localhost 被拦
        if (!qiniuClientAttached) {
            webView.setWebViewClient(new QiniuRefererWebViewClient(this.bridge));
            qiniuClientAttached = true;
        }
    }
}
