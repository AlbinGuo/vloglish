# App 静态资源构建（由根目录 app/ 的 sync 脚本触发）
# 产物输出到 ../app/www，不进 Web 生产 Docker 构建
VITE_APP_TARGET=mobile
VITE_API_BASE_URL=https://en.yunankexun.com

# 外部测试（TestFlight）自动赠送 7 天试用会员已停用；正式 App 不自动赠送会员。
VITE_APP_TEST_MODE=false

# Android FCM 推送开关。
# 把 Firebase 的 google-services.json 放到 app/android/app/ 后，改成 true 再重新打包。
# 未放置该文件时保持 false，否则 Android 端注册推送会原生闪退（iOS 不受影响）。
VITE_ANDROID_PUSH_ENABLED=false
