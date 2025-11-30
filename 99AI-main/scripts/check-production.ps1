# 99AI 生产环境检查脚本 (Windows PowerShell)
# 用于快速检查生产环境状态

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    99AI 生产环境检查工具" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 1. 检查 Docker 服务
Write-Host "【1】Docker 服务检查" -ForegroundColor Yellow
if (Get-Command docker -ErrorAction SilentlyContinue) {
    $containers = docker ps --format "{{.Names}}" 2>$null
    if ($containers -match "99ai") {
        Write-Host "✓ 99AI 容器运行中" -ForegroundColor Green
        docker ps | Select-String "99ai"
    } else {
        Write-Host "✗ 99AI 容器未运行" -ForegroundColor Red
    }
    
    if ($containers -match "mysql") {
        Write-Host "✓ MySQL 容器运行中" -ForegroundColor Green
    } else {
        Write-Host "✗ MySQL 容器未运行" -ForegroundColor Red
    }
    
    if ($containers -match "redis") {
        Write-Host "✓ Redis 容器运行中" -ForegroundColor Green
    } else {
        Write-Host "✗ Redis 容器未运行" -ForegroundColor Red
    }
} else {
    Write-Host "⚠ Docker 未安装或未在 PATH 中" -ForegroundColor Yellow
}
Write-Host ""

# 2. 检查 PM2 服务
Write-Host "【2】PM2 服务检查" -ForegroundColor Yellow
if (Get-Command pm2 -ErrorAction SilentlyContinue) {
    $pm2List = pm2 list 2>$null
    if ($pm2List -match "99AI") {
        Write-Host "✓ 99AI 进程运行中" -ForegroundColor Green
        pm2 list | Select-String "99AI"
    } else {
        Write-Host "✗ 99AI 进程未运行" -ForegroundColor Red
    }
} else {
    Write-Host "⚠ PM2 未安装或未在 PATH 中" -ForegroundColor Yellow
}
Write-Host ""

# 3. 检查端口
Write-Host "【3】端口检查" -ForegroundColor Yellow
$port = Get-NetTCPConnection -LocalPort 9520 -ErrorAction SilentlyContinue
if ($port) {
    Write-Host "✓ 端口 9520 已被占用" -ForegroundColor Green
    $port | Format-Table LocalAddress, LocalPort, State, OwningProcess
} else {
    Write-Host "✗ 端口 9520 未被占用" -ForegroundColor Red
}
Write-Host ""

# 4. 检查环境变量文件
Write-Host "【4】环境变量文件检查" -ForegroundColor Yellow
if (Test-Path ".env") {
    Write-Host "✓ .env 文件存在" -ForegroundColor Green
    
    $envContent = Get-Content ".env"
    $requiredVars = @("DB_HOST", "DB_PORT", "DB_USERNAME", "DB_PASSWORD", "DB_DATABASE", "REDIS_HOST", "REDIS_PORT", "PORT")
    $missingVars = @()
    
    foreach ($var in $requiredVars) {
        if (-not ($envContent -match "^${var}=")) {
            $missingVars += $var
        }
    }
    
    if ($missingVars.Count -eq 0) {
        Write-Host "✓ 所有必需的环境变量已配置" -ForegroundColor Green
    } else {
        Write-Host "⚠ 缺少以下环境变量: $($missingVars -join ', ')" -ForegroundColor Yellow
    }
} else {
    Write-Host "✗ .env 文件不存在" -ForegroundColor Red
}
Write-Host ""

# 5. 检查前端文件
Write-Host "【5】前端文件检查" -ForegroundColor Yellow
if (Test-Path "public\admin") {
    $adminFiles = Get-ChildItem "public\admin" -ErrorAction SilentlyContinue
    if ($adminFiles) {
        Write-Host "✓ Admin 前端文件存在" -ForegroundColor Green
    } else {
        Write-Host "✗ Admin 前端文件目录为空" -ForegroundColor Red
    }
} else {
    Write-Host "✗ Admin 前端文件目录不存在" -ForegroundColor Red
}

if (Test-Path "public\chat") {
    $chatFiles = Get-ChildItem "public\chat" -ErrorAction SilentlyContinue
    if ($chatFiles) {
        Write-Host "✓ Chat 前端文件存在" -ForegroundColor Green
    } else {
        Write-Host "✗ Chat 前端文件目录为空" -ForegroundColor Red
    }
} else {
    Write-Host "✗ Chat 前端文件目录不存在" -ForegroundColor Red
}
Write-Host ""

# 6. 检查 API 端点
Write-Host "【6】API 端点检查" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:9520/api/config/queryFront" -Method GET -TimeoutSec 5 -ErrorAction Stop
    Write-Host "✓ API 端点可访问 (状态码: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "✗ API 端点无法访问: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# 7. 检查日志文件
Write-Host "【7】日志文件检查" -ForegroundColor Yellow
if (Test-Path "logs") {
    Write-Host "✓ logs 目录存在" -ForegroundColor Green
    if (Test-Path "logs\err.log") {
        $errLog = Get-Content "logs\err.log" -Tail 100 -ErrorAction SilentlyContinue
        $errorCount = ($errLog | Select-String -Pattern "error" -CaseSensitive:$false).Count
        if ($errorCount -gt 0) {
            Write-Host "⚠ 最近 100 行日志中有 $errorCount 个错误" -ForegroundColor Yellow
        } else {
            Write-Host "✓ 最近 100 行日志无错误" -ForegroundColor Green
        }
    }
} else {
    Write-Host "⚠ logs 目录不存在" -ForegroundColor Yellow
}
Write-Host ""

# 8. 检查磁盘空间
Write-Host "【8】磁盘空间检查" -ForegroundColor Yellow
$disk = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -eq (Get-Location).Drive.Root }
$freeSpacePercent = [math]::Round(($disk.Free / $disk.Used) * 100, 2)
$usedPercent = [math]::Round((($disk.Used / ($disk.Free + $disk.Used)) * 100), 2)

if ($usedPercent -lt 80) {
    Write-Host "✓ 磁盘使用率: $usedPercent%" -ForegroundColor Green
} elseif ($usedPercent -lt 90) {
    Write-Host "⚠ 磁盘使用率: $usedPercent%（建议清理）" -ForegroundColor Yellow
} else {
    Write-Host "✗ 磁盘使用率: $usedPercent%（空间不足）" -ForegroundColor Red
}
Write-Host ""

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "检查完成！" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

