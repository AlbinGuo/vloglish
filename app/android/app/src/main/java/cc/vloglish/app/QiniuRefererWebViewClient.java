package cc.vloglish.app;

import android.net.Uri;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;
import com.getcapacitor.Bridge;
import com.getcapacitor.BridgeWebViewClient;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * 七牛 Referer 防盗链会拦截 App WebView。
 * 页面源是 https://localhost，图片请求会带这个 Referer 被 CDN 拦下。
 * 这里对七牛域名的图片 GET 补上站点 Referer，与网页端白名单一致。
 *
 * 音视频绝不能走 shouldInterceptRequest：WebView 系统播放器依赖 Range/206，
 * 用 HttpURLConnection 把 mp4 流接管后详情页和听页都会无法播放。
 * 媒体改由播放器直连，并让 video 使用 no-referrer；
 * 空 Referer + 短时签名 URL（需七牛勾选「允许空 Referer」）。
 */
public class QiniuRefererWebViewClient extends BridgeWebViewClient {
    private static final String SITE_REFERER = "https://en.yunankexun.com/";
    private static final int CONNECT_TIMEOUT_MS = 15000;
    private static final int READ_TIMEOUT_MS = 120000;

    public QiniuRefererWebViewClient(Bridge bridge) {
        super(bridge);
    }

    @Override
    public WebResourceResponse shouldInterceptRequest(WebView view, WebResourceRequest request) {
        if (request != null && shouldProxyQiniu(request)) {
            WebResourceResponse proxied = fetchWithSiteReferer(request);
            if (proxied != null) {
                return proxied;
            }
        }
        return super.shouldInterceptRequest(view, request);
    }

    private static boolean shouldProxyQiniu(WebResourceRequest request) {
        if (!"GET".equalsIgnoreCase(request.getMethod())) {
            return false;
        }
        if (isMediaRequest(request)) {
            return false;
        }
        Uri uri = request.getUrl();
        if (uri == null) {
            return false;
        }
        String host = uri.getHost();
        if (host == null) {
            return false;
        }
        host = host.toLowerCase(Locale.US);
        return host.equals("oss.sxakgs.com")
                || host.endsWith(".oss.sxakgs.com")
                || host.endsWith(".qiniucdn.com")
                || host.endsWith(".qnssl.com")
                || host.endsWith(".qiniudn.com");
    }

    /** 系统播放器拉的音视频（含 Range 探测），不要接管。 */
    private static boolean isMediaRequest(WebResourceRequest request) {
        Map<String, String> headers = request.getRequestHeaders();
        if (headers != null) {
            for (Map.Entry<String, String> entry : headers.entrySet()) {
                if (entry.getKey() == null) {
                    continue;
                }
                String key = entry.getKey().toLowerCase(Locale.US);
                if (key.equals("range")) {
                    return true;
                }
                if (key.equals("accept")) {
                    String accept = entry.getValue() == null ? "" : entry.getValue().toLowerCase(Locale.US);
                    if (accept.contains("video/") || accept.contains("audio/")) {
                        return true;
                    }
                }
            }
        }
        Uri uri = request.getUrl();
        String path = uri != null && uri.getPath() != null ? uri.getPath().toLowerCase(Locale.US) : "";
        return path.endsWith(".mp4")
                || path.endsWith(".webm")
                || path.endsWith(".m3u8")
                || path.endsWith(".mp3")
                || path.endsWith(".m4a")
                || path.endsWith(".aac")
                || path.endsWith(".wav")
                || path.endsWith(".ogg")
                || path.endsWith(".opus");
    }

    private static WebResourceResponse fetchWithSiteReferer(WebResourceRequest request) {
        HttpURLConnection conn = null;
        try {
            conn = (HttpURLConnection) new URL(request.getUrl().toString()).openConnection();
            conn.setInstanceFollowRedirects(true);
            conn.setConnectTimeout(CONNECT_TIMEOUT_MS);
            conn.setReadTimeout(READ_TIMEOUT_MS);
            conn.setRequestMethod("GET");

            Map<String, String> incoming = request.getRequestHeaders();
            if (incoming != null) {
                for (Map.Entry<String, String> entry : incoming.entrySet()) {
                    String key = entry.getKey();
                    if (key == null || skipForwardedRequestHeader(key)) {
                        continue;
                    }
                    conn.setRequestProperty(key, entry.getValue());
                }
            }
            conn.setRequestProperty("Referer", SITE_REFERER);

            int status = conn.getResponseCode();
            String reason = conn.getResponseMessage();
            if (reason == null || reason.isEmpty()) {
                reason = status >= 400 ? "Error" : "OK";
            }

            String contentType = conn.getContentType();
            String mime = "application/octet-stream";
            if (contentType != null && !contentType.isEmpty()) {
                int sep = contentType.indexOf(';');
                mime = (sep > 0 ? contentType.substring(0, sep) : contentType).trim();
            }

            InputStream stream = status >= 400 ? conn.getErrorStream() : conn.getInputStream();
            if (stream == null) {
                conn.disconnect();
                return null;
            }

            Map<String, String> headers = responseHeaders(conn);
            return new WebResourceResponse(mime, null, status, reason, headers, stream);
        } catch (Exception ignored) {
            if (conn != null) {
                conn.disconnect();
            }
            return null;
        }
    }

    private static boolean skipForwardedRequestHeader(String key) {
        String lower = key.toLowerCase(Locale.US);
        return lower.equals("host")
                || lower.equals("connection")
                || lower.equals("referer")
                || lower.equals("referrer")
                || lower.equals("accept-encoding")
                || lower.equals("content-length");
    }

    private static Map<String, String> responseHeaders(HttpURLConnection conn) {
        Map<String, String> headers = new HashMap<>();
        Map<String, List<String>> raw = conn.getHeaderFields();
        if (raw == null) {
            return headers;
        }
        for (Map.Entry<String, List<String>> entry : raw.entrySet()) {
            String key = entry.getKey();
            if (key == null || entry.getValue() == null || entry.getValue().isEmpty()) {
                continue;
            }
            String lower = key.toLowerCase(Locale.US);
            if (lower.equals("content-encoding") || lower.equals("transfer-encoding")) {
                continue;
            }
            headers.put(key, entry.getValue().get(0));
        }
        return headers;
    }
}
