# 口语评测 JavaScript SDK

将阿里云智能科教控制台下载的 `engine.js` 放到本目录：

```
frontend/public/sdk/engine.js
```

部署后通过 `/sdk/engine.js` 访问。

也可在后端设置 `ORAL_EVAL_SDK_URL` 指向其它可访问地址。

未放置 SDK 或未配置 `ORAL_EVAL_APP_ID` / `ORAL_EVAL_APP_SECRET` 时，跟读自动回退为浏览器语音识别 + AI 文本点评。
