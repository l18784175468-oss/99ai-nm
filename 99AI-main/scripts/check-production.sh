#!/bin/bash

# 生产环境检查脚本
# 用于快速检查生产环境状态

set -e

echo "=========================================="
echo "    99AI 生产环境检查工具"
echo "=========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查函数
check_service() {
    local service_name=$1
    local check_cmd=$2
    
    echo -n "检查 $service_name ... "
    if eval "$check_cmd" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ 运行中${NC}"
        return 0
    else
        echo -e "${RED}✗ 未运行${NC}"
        return 1
    fi
}

# 1. 检查 Docker 服务（如果使用 Docker）
echo "【1】Docker 服务检查"
if command -v docker &> /dev/null; then
    if docker ps | grep -q "99ai"; then
        echo -e "${GREEN}✓ 99AI 容器运行中${NC}"
        docker ps | grep "99ai"
    else
        echo -e "${RED}✗ 99AI 容器未运行${NC}"
    fi
    
    if docker ps | grep -q "mysql"; then
        echo -e "${GREEN}✓ MySQL 容器运行中${NC}"
    else
        echo -e "${RED}✗ MySQL 容器未运行${NC}"
    fi
    
    if docker ps | grep -q "redis"; then
        echo -e "${GREEN}✓ Redis 容器运行中${NC}"
    else
        echo -e "${RED}✗ Redis 容器未运行${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Docker 未安装或未在 PATH 中${NC}"
fi
echo ""

# 2. 检查 PM2 服务（如果使用 PM2）
echo "【2】PM2 服务检查"
if command -v pm2 &> /dev/null; then
    if pm2 list | grep -q "99AI"; then
        echo -e "${GREEN}✓ 99AI 进程运行中${NC}"
        pm2 list | grep "99AI"
    else
        echo -e "${RED}✗ 99AI 进程未运行${NC}"
    fi
else
    echo -e "${YELLOW}⚠ PM2 未安装或未在 PATH 中${NC}"
fi
echo ""

# 3. 检查端口
echo "【3】端口检查"
if command -v lsof &> /dev/null; then
    if lsof -i :9520 > /dev/null 2>&1; then
        echo -e "${GREEN}✓ 端口 9520 已被占用${NC}"
        lsof -i :9520
    else
        echo -e "${RED}✗ 端口 9520 未被占用${NC}"
    fi
elif command -v netstat &> /dev/null; then
    if netstat -tuln | grep -q ":9520"; then
        echo -e "${GREEN}✓ 端口 9520 已被占用${NC}"
    else
        echo -e "${RED}✗ 端口 9520 未被占用${NC}"
    fi
else
    echo -e "${YELLOW}⚠ 无法检查端口（需要 lsof 或 netstat）${NC}"
fi
echo ""

# 4. 检查环境变量文件
echo "【4】环境变量文件检查"
if [ -f ".env" ]; then
    echo -e "${GREEN}✓ .env 文件存在${NC}"
    
    # 检查关键环境变量
    required_vars=("DB_HOST" "DB_PORT" "DB_USERNAME" "DB_PASSWORD" "DB_DATABASE" "REDIS_HOST" "REDIS_PORT" "PORT")
    missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if ! grep -q "^${var}=" .env; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -eq 0 ]; then
        echo -e "${GREEN}✓ 所有必需的环境变量已配置${NC}"
    else
        echo -e "${YELLOW}⚠ 缺少以下环境变量: ${missing_vars[*]}${NC}"
    fi
else
    echo -e "${RED}✗ .env 文件不存在${NC}"
fi
echo ""

# 5. 检查数据库连接
echo "【5】数据库连接检查"
if [ -f ".env" ]; then
    source .env
    if command -v mysql &> /dev/null; then
        if mysql -h "${DB_HOST:-localhost}" -P "${DB_PORT:-3306}" -u "${DB_USERNAME}" -p"${DB_PASSWORD}" -e "SELECT 1" "${DB_DATABASE}" > /dev/null 2>&1; then
            echo -e "${GREEN}✓ 数据库连接成功${NC}"
        else
            echo -e "${RED}✗ 数据库连接失败${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ MySQL 客户端未安装${NC}"
    fi
else
    echo -e "${YELLOW}⚠ 无法检查数据库（.env 文件不存在）${NC}"
fi
echo ""

# 6. 检查 Redis 连接
echo "【6】Redis 连接检查"
if [ -f ".env" ]; then
    source .env
    if command -v redis-cli &> /dev/null; then
        if [ -n "${REDIS_PASSWORD}" ]; then
            if redis-cli -h "${REDIS_HOST:-localhost}" -p "${REDIS_PORT:-6379}" -a "${REDIS_PASSWORD}" ping > /dev/null 2>&1; then
                echo -e "${GREEN}✓ Redis 连接成功${NC}"
            else
                echo -e "${RED}✗ Redis 连接失败${NC}"
            fi
        else
            if redis-cli -h "${REDIS_HOST:-localhost}" -p "${REDIS_PORT:-6379}" ping > /dev/null 2>&1; then
                echo -e "${GREEN}✓ Redis 连接成功${NC}"
            else
                echo -e "${RED}✗ Redis 连接失败${NC}"
            fi
        fi
    else
        echo -e "${YELLOW}⚠ Redis 客户端未安装${NC}"
    fi
else
    echo -e "${YELLOW}⚠ 无法检查 Redis（.env 文件不存在）${NC}"
fi
echo ""

# 7. 检查前端文件
echo "【7】前端文件检查"
if [ -d "public/admin" ] && [ "$(ls -A public/admin 2>/dev/null)" ]; then
    echo -e "${GREEN}✓ Admin 前端文件存在${NC}"
else
    echo -e "${RED}✗ Admin 前端文件不存在或为空${NC}"
fi

if [ -d "public/chat" ] && [ "$(ls -A public/chat 2>/dev/null)" ]; then
    echo -e "${GREEN}✓ Chat 前端文件存在${NC}"
else
    echo -e "${RED}✗ Chat 前端文件不存在或为空${NC}"
fi
echo ""

# 8. 检查 API 端点
echo "【8】API 端点检查"
if command -v curl &> /dev/null; then
    if curl -s http://localhost:9520/api/config/queryFront > /dev/null 2>&1; then
        echo -e "${GREEN}✓ API 端点可访问${NC}"
    else
        echo -e "${RED}✗ API 端点无法访问${NC}"
    fi
else
    echo -e "${YELLOW}⚠ curl 未安装，跳过 API 检查${NC}"
fi
echo ""

# 9. 检查日志文件
echo "【9】日志文件检查"
if [ -d "logs" ]; then
    echo -e "${GREEN}✓ logs 目录存在${NC}"
    if [ -f "logs/err.log" ]; then
        err_count=$(tail -n 100 logs/err.log | grep -i "error" | wc -l)
        if [ "$err_count" -gt 0 ]; then
            echo -e "${YELLOW}⚠ 最近 100 行日志中有 $err_count 个错误${NC}"
        else
            echo -e "${GREEN}✓ 最近 100 行日志无错误${NC}"
        fi
    fi
else
    echo -e "${YELLOW}⚠ logs 目录不存在${NC}"
fi
echo ""

# 10. 检查磁盘空间
echo "【10】磁盘空间检查"
if command -v df &> /dev/null; then
    disk_usage=$(df -h . | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$disk_usage" -lt 80 ]; then
        echo -e "${GREEN}✓ 磁盘使用率: ${disk_usage}%${NC}"
    elif [ "$disk_usage" -lt 90 ]; then
        echo -e "${YELLOW}⚠ 磁盘使用率: ${disk_usage}%（建议清理）${NC}"
    else
        echo -e "${RED}✗ 磁盘使用率: ${disk_usage}%（空间不足）${NC}"
    fi
fi
echo ""

echo "=========================================="
echo "检查完成！"
echo "=========================================="

