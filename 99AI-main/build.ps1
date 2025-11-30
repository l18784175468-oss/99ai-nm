# 99AI 项目打包脚本 (Windows PowerShell)
# 用于打包 admin、chat 和 service 模块

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    开始打包 99AI 项目..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"

# 检查 pnpm 是否安装
if (-not (Get-Command pnpm -ErrorAction SilentlyContinue)) {
    Write-Host "错误: 未找到 pnpm，请先安装 pnpm" -ForegroundColor Red
    Write-Host "安装命令: npm install -g pnpm" -ForegroundColor Yellow
    exit 1
}

# 1. 打包 admin
Write-Host "【1/3】打包 Admin 模块..." -ForegroundColor Yellow
Set-Location admin
if (-not (Test-Path "node_modules")) {
    Write-Host "安装 Admin 依赖..." -ForegroundColor Gray
    pnpm install
}
Write-Host "构建 Admin..." -ForegroundColor Gray
pnpm build
if ($LASTEXITCODE -ne 0) {
    Write-Host "Admin 打包失败！" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Set-Location ..
Write-Host "✓ Admin 打包完成" -ForegroundColor Green
Write-Host ""

# 2. 打包 chat
Write-Host "【2/3】打包 Chat 模块..." -ForegroundColor Yellow
Set-Location chat
if (-not (Test-Path "node_modules")) {
    Write-Host "安装 Chat 依赖..." -ForegroundColor Gray
    pnpm install
}
Write-Host "构建 Chat..." -ForegroundColor Gray
pnpm build
if ($LASTEXITCODE -ne 0) {
    Write-Host "Chat 打包失败！" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Set-Location ..
Write-Host "✓ Chat 打包完成" -ForegroundColor Green
Write-Host ""

# 3. 打包 service
Write-Host "【3/3】打包 Service 模块..." -ForegroundColor Yellow
Set-Location service
if (-not (Test-Path "node_modules")) {
    Write-Host "安装 Service 依赖..." -ForegroundColor Gray
    pnpm install
}
Write-Host "构建 Service..." -ForegroundColor Gray
pnpm build
if ($LASTEXITCODE -ne 0) {
    Write-Host "Service 打包失败！" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Set-Location ..
Write-Host "✓ Service 打包完成" -ForegroundColor Green
Write-Host ""

# 4. 复制文件到 AIWebQuickDeploy
Write-Host "【4/4】复制文件到 AIWebQuickDeploy..." -ForegroundColor Yellow

# 清理目标目录
if (Test-Path "AIWebQuickDeploy\dist") {
    Remove-Item -Path "AIWebQuickDeploy\dist\*" -Recurse -Force -ErrorAction SilentlyContinue
}
if (Test-Path "AIWebQuickDeploy\public\admin") {
    Remove-Item -Path "AIWebQuickDeploy\public\admin\*" -Recurse -Force -ErrorAction SilentlyContinue
}
if (Test-Path "AIWebQuickDeploy\public\chat") {
    Remove-Item -Path "AIWebQuickDeploy\public\chat\*" -Recurse -Force -ErrorAction SilentlyContinue
}

# 确保目录存在
New-Item -ItemType Directory -Force -Path "AIWebQuickDeploy\dist" | Out-Null
New-Item -ItemType Directory -Force -Path "AIWebQuickDeploy\public\admin" | Out-Null
New-Item -ItemType Directory -Force -Path "AIWebQuickDeploy\public\chat" | Out-Null

# 复制 service 文件
Write-Host "复制 Service 文件..." -ForegroundColor Gray
Copy-Item -Path "service\pm2.conf.json" -Destination "AIWebQuickDeploy\pm2.conf.json" -Force
Copy-Item -Path "service\package.json" -Destination "AIWebQuickDeploy\package.json" -Force

# 复制环境变量示例文件（如果存在）
if (Test-Path "service\.env.example") {
    Copy-Item -Path "service\.env.example" -Destination "AIWebQuickDeploy\.env.example" -Force
}
if (Test-Path "service\.env.docker") {
    Copy-Item -Path "service\.env.docker" -Destination "AIWebQuickDeploy\.env.docker" -Force
}

# 复制 Docker 相关文件
if (Test-Path "service\Dockerfile") {
    Copy-Item -Path "service\Dockerfile" -Destination "AIWebQuickDeploy\Dockerfile" -Force
}
if (Test-Path "service\docker-compose.yml") {
    Copy-Item -Path "service\docker-compose.yml" -Destination "AIWebQuickDeploy\docker-compose.yml" -Force
}
if (Test-Path "service\.dockerignore") {
    Copy-Item -Path "service\.dockerignore" -Destination "AIWebQuickDeploy\.dockerignore" -Force
}

# 复制构建产物
Write-Host "复制构建产物..." -ForegroundColor Gray
if (Test-Path "service\dist") {
    Copy-Item -Path "service\dist\*" -Destination "AIWebQuickDeploy\dist" -Recurse -Force
}
if (Test-Path "admin\dist") {
    Copy-Item -Path "admin\dist\*" -Destination "AIWebQuickDeploy\public\admin" -Recurse -Force
}
if (Test-Path "chat\dist") {
    Copy-Item -Path "chat\dist\*" -Destination "AIWebQuickDeploy\public\chat" -Recurse -Force
}

Write-Host "✓ 文件复制完成" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    打包完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "打包文件位置: AIWebQuickDeploy\" -ForegroundColor Yellow
Write-Host ""
