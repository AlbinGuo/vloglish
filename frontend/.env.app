# App 静态资源构建（由根目录 app/ 的 sync 脚本触发）
# 产物输出到 ../app/www，不进 Web 生产 Docker 构建
VITE_APP_TARGET=mobile
VITE_API_BASE_URL=https://en.yunankexun.com

# 外部测试（TestFlight）构建标记：登录后自动开通 7 天试用会员。
# 仅 TestFlight 外部测试构建设为 true；正式发布包必须保持 false（或不设置）。
# 需后端同时设置 EXTERNAL_TEST_MODE=true 才生效。
VITE_APP_TEST_MODE=true
