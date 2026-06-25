#Requires -Version 5.1
$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $PSScriptRoot
Set-Location $RootDir

$EnvFile = ".env.prod"
$ComposeArgs = @("--env-file", $EnvFile)

function Test-Command($Name) {
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

if (-not (Test-Command docker)) {
    Write-Error "未找到 docker，请先安装 Docker Desktop。"
}

try {
    docker compose version | Out-Null
} catch {
    Write-Error "未找到 docker compose 插件。"
}

if (-not (Test-Path $EnvFile)) {
    if (Test-Path ".env.prod.example") {
        Copy-Item ".env.prod.example" $EnvFile
        Write-Host "已创建 $EnvFile，请编辑其中的密钥与域名后重新运行。"
        exit 1
    }
    Write-Error "缺少 $EnvFile 与 .env.prod.example"
}

$content = Get-Content $EnvFile -Raw
if ($content -match "change-me-in-production" -or $content -match "change-me-strong-password") {
    Write-Warning "$EnvFile 仍含默认密钥，生产环境请先修改 JWT_SECRET 与 ADMIN_PASSWORD。"
}

Write-Host "==> 构建并启动容器..."
docker compose @ComposeArgs up -d --build

Write-Host "==> 等待后端健康检查..."
$healthy = $false
for ($i = 1; $i -le 30; $i++) {
    try {
        docker compose @ComposeArgs exec -T backend curl -sf http://localhost:8000/api/health | Out-Null
        $healthy = $true
        break
    } catch {
        Start-Sleep -Seconds 2
    }
}

if (-not $healthy) {
    Write-Error "后端健康检查超时，请执行: docker compose logs backend"
}

$dbExists = $false
try {
    docker compose @ComposeArgs exec -T backend test -f /app/backend/data/teco.db | Out-Null
    $dbExists = $true
} catch {
    $dbExists = $false
}

if (-not $dbExists) {
    Write-Host "==> 初始化数据库..."
    docker compose @ComposeArgs exec -T backend python seed.py
}

$httpPort = "80"
foreach ($line in Get-Content $EnvFile) {
    if ($line -match '^\s*HTTP_PORT\s*=\s*(.+)\s*$') {
        $httpPort = $Matches[1].Trim()
        break
    }
}

Write-Host ""
Write-Host "部署完成。"
Write-Host "  站点: http://localhost:$httpPort/english"
Write-Host "  管理: http://localhost:$httpPort/gnadmin"
Write-Host "  健康: http://localhost:$httpPort/api/health"
Write-Host ""
Write-Host "常用命令:"
Write-Host "  查看日志: docker compose --env-file $EnvFile logs -f"
Write-Host "  停止服务: docker compose --env-file $EnvFile down"
Write-Host "  重新构建: docker compose --env-file $EnvFile up -d --build"
