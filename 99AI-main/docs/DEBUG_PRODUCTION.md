# 生产环境调试指南

本文档提供生产环境常见问题的排查和调试方法。

## 📋 快速检查清单

### 1. 服务状态检查

#### Docker 部署方式
```bash
# 检查容器状态
docker ps -a

# 查看服务日志
docker-compose logs -f 99ai
docker-compose logs -f mysql
docker-compose logs -f redis

# 进入容器调试
docker exec -it 99ai sh
```

#### PM2 部署方式
```bash
# 检查进程状态
pm2 list
pm2 status

# 查看日志
pm2 logs 99AI
pm2 logs 99AI --err  # 只看错误日志
pm2 logs 99AI --out  # 只看输出日志

# 查看详细信息
pm2 info 99AI

# 重启服务
pm2 restart 99AI
pm2 reload 99AI  # 零停机重启
```

### 2. 端口和网络检查

```bash
# 检查端口是否被占用
netstat -tulpn | grep 9520
# 或
lsof -i :9520

# 检查防火墙
ufw status
# 或
iptables -L

# 测试端口连通性
curl http://localhost:9520/api/config/queryFront
telnet localhost 9520
```

### 3. 数据库连接检查

```bash
# MySQL 连接测试
mysql -h localhost -u chatgpt -p chatgpt

# 检查数据库表
mysql -h localhost -u chatgpt -p chatgpt -e "SHOW TABLES;"

# 检查数据库连接数
mysql -h localhost -u chatgpt -p chatgpt -e "SHOW PROCESSLIST;"
```

### 4. Redis 连接检查

```bash
# Redis 连接测试
redis-cli ping
# 或带密码
redis-cli -a 12345678 ping

# 查看 Redis 信息
redis-cli INFO

# 查看键值
redis-cli KEYS "*"
```

### 5. 环境变量检查

```bash
# 检查 .env 文件是否存在
ls -la .env

# 查看环境变量（在容器内）
docker exec -it 99ai env | grep -E "DB_|REDIS_|PORT"

# 检查关键环境变量
cat .env | grep -E "DB_HOST|DB_PORT|REDIS_HOST|PORT"
```

## 🔍 常见问题排查

### 问题1: 服务无法启动

**症状**: 容器或进程无法启动

**排查步骤**:
1. 检查日志文件
   ```bash
   # Docker
   docker-compose logs 99ai
   
   # PM2
   pm2 logs 99AI --err
   ```

2. 检查端口占用
   ```bash
   lsof -i :9520
   ```

3. 检查环境变量配置
   ```bash
   cat .env
   ```

4. 检查依赖安装
   ```bash
   # 在容器内
   docker exec -it 99ai sh
   ls -la node_modules
   ```

### 问题2: 数据库连接失败

**症状**: 日志显示数据库连接错误

**排查步骤**:
1. 检查数据库服务是否运行
   ```bash
   docker ps | grep mysql
   # 或
   systemctl status mysql
   ```

2. 检查数据库配置
   ```bash
   cat .env | grep DB_
   ```

3. 测试数据库连接
   ```bash
   mysql -h ${DB_HOST} -P ${DB_PORT} -u ${DB_USERNAME} -p${DB_PASSWORD} ${DB_DATABASE}
   ```

4. 检查数据库权限
   ```sql
   SHOW GRANTS FOR 'chatgpt'@'%';
   ```

### 问题3: Redis 连接失败

**症状**: 日志显示 Redis 连接错误

**排查步骤**:
1. 检查 Redis 服务
   ```bash
   docker ps | grep redis
   redis-cli ping
   ```

2. 检查 Redis 配置
   ```bash
   cat .env | grep REDIS_
   ```

3. 检查 Redis 密码
   ```bash
   redis-cli -a ${REDIS_PASSWORD} ping
   ```

### 问题4: 前端资源无法访问

**症状**: 访问页面显示 404 或空白页

**排查步骤**:
1. 检查构建文件是否存在
   ```bash
   ls -la public/admin/
   ls -la public/chat/
   ```

2. 检查文件权限
   ```bash
   ls -la public/
   chmod -R 755 public/
   ```

3. 检查 Nginx 配置（如果使用）
   ```bash
   nginx -t
   cat /etc/nginx/sites-enabled/99ai
   ```

### 问题5: API 请求失败

**症状**: 前端无法调用后端 API

**排查步骤**:
1. 检查 API 端点
   ```bash
   curl http://localhost:9520/api/config/queryFront
   ```

2. 检查 CORS 配置
   - 查看 `main.ts` 中的 CORS 设置

3. 检查请求日志
   ```bash
   pm2 logs 99AI | grep "POST\|GET"
   ```

### 问题6: 内存占用过高

**症状**: 服务频繁重启或内存不足

**排查步骤**:
1. 检查内存使用
   ```bash
   pm2 monit
   # 或
   docker stats 99ai
   ```

2. 调整 PM2 配置
   ```json
   {
     "max_memory_restart": "2000M"
   }
   ```

3. 检查内存泄漏
   ```bash
   node --inspect dist/main.js
   ```

## 🛠️ 调试工具和命令

### 查看实时日志
```bash
# Docker
docker-compose logs -f --tail=100 99ai

# PM2
pm2 logs 99AI --lines 100
```

### 性能监控
```bash
# PM2 监控
pm2 monit

# Docker 资源监控
docker stats

# 系统资源
top
htop
```

### 网络调试
```bash
# 查看网络连接
netstat -tulpn

# 抓包分析
tcpdump -i any port 9520

# 测试 API
curl -v http://localhost:9520/api/config/queryFront
```

### 数据库调试
```sql
-- 查看慢查询
SHOW VARIABLES LIKE 'slow_query%';
SHOW VARIABLES LIKE 'long_query_time';

-- 查看连接数
SHOW STATUS LIKE 'Threads_connected';
SHOW STATUS LIKE 'Max_used_connections';

-- 查看表大小
SELECT 
    table_name,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS size_mb
FROM information_schema.TABLES
WHERE table_schema = 'chatgpt'
ORDER BY size_mb DESC;
```

## 📝 日志文件位置

### PM2 部署
- 错误日志: `logs/err.log`
- 输出日志: `logs/out.log`

### Docker 部署
- 日志在容器内: `/usr/src/app/logs/`
- 查看方式: `docker exec -it 99ai cat logs/err.log`

## 🔧 环境变量配置检查

确保以下关键环境变量已正确配置：

```bash
# 数据库配置
DB_HOST=localhost
DB_PORT=3306
DB_USERNAME=chatgpt
DB_PASSWORD=123456
DB_DATABASE=chatgpt

# Redis 配置
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# 服务配置
PORT=9520
NODE_ENV=production
TZ=Asia/Shanghai

# 其他配置
ISDEV=false  # 生产环境设为 false
```

## 🚨 紧急恢复步骤

### 服务完全无法访问

1. **停止服务**
   ```bash
   # Docker
   docker-compose down
   
   # PM2
   pm2 stop 99AI
   ```

2. **备份数据**
   ```bash
   # 备份数据库
   mysqldump -u chatgpt -p chatgpt > backup_$(date +%Y%m%d).sql
   
   # 备份 Redis
   redis-cli SAVE
   cp /var/lib/redis/dump.rdb backup_$(date +%Y%m%d).rdb
   ```

3. **检查配置文件**
   ```bash
   cat .env
   cat pm2.conf.json
   ```

4. **重新启动**
   ```bash
   # Docker
   docker-compose up -d
   
   # PM2
   pm2 start pm2.conf.json
   ```

## 📞 获取帮助

如果以上步骤无法解决问题，请收集以下信息：

1. 错误日志（最近 100 行）
2. 环境变量配置（隐藏敏感信息）
3. 系统信息（OS、Node 版本、Docker 版本等）
4. 问题复现步骤

## 🔐 安全检查清单

- [ ] 修改默认密码（数据库、Redis、管理员账号）
- [ ] 配置防火墙规则
- [ ] 启用 HTTPS（生产环境）
- [ ] 定期备份数据库
- [ ] 监控服务状态
- [ ] 检查日志中的异常
- [ ] 更新依赖包（安全补丁）

