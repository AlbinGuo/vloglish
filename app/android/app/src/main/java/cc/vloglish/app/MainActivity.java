package cc.vloglish.app;

import android.webkit.WebSettings;
import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {
    @Override
    public void onStart() {
        super.onStart();
        if (this.bridge == null || this.bridge.getWebView() == null) {
            return;
        }
        WebSettings settings = this.bridge.getWebView().getSettings();
        // 兜底：允许 https 页面加载 http 媒体（主路径已把七牛链升为 https）
        settings.setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);
        // 旧 WebView 兼容：确保本地资源与 DOM 存储可用
        settings.setDomStorageEnabled(true);
        settings.setAllowFileAccess(true);
        // 部分国产机默认缩放/字号异常，固定为正常档
        settings.setTextZoom(100);
    }
}
