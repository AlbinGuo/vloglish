package cc.vloglish.app;

import android.content.Intent;
import android.net.Uri;

import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

/**
 * App 内更新兜底：把 APK 下载地址交给系统浏览器/下载器。
 *
 * Capacitor WebView 里直接 window.open(apk 链接) 不一定能唤起系统浏览器，
 * 表现为点了「立即更新」但没真正下载/安装。这里显式 startActivity，
 * 由系统浏览器下载 APK 后再走安装流程。
 */
@CapacitorPlugin(name = "AppUpdater")
public class AppUpdaterPlugin extends Plugin {

    @PluginMethod
    public void openDownload(PluginCall call) {
        String url = call.getString("url", "");
        if (url == null || url.trim().isEmpty()) {
            call.reject("缺少下载地址");
            return;
        }
        try {
            Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url.trim()));
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            getContext().startActivity(intent);
            call.resolve();
        } catch (Exception e) {
            call.reject("无法打开下载链接", e);
        }
    }
}
