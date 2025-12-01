# Docker Compose 修复指南

## 问题说明

您的Docker Compose配置中使用了过时的`version`字段，这在新版本的Docker Compose中已经不再需要。

## 已修复的问题

### 1. 移除过时的version字段
- **问题**: `version: '3.9'` 在新版本Docker Compose中已过时
- **修复**: 已从`docker-compose.yml`中移除version字段

### 2. 创建优化版本
- 创建了`docker-compose-modern.yml`，包含以下优化：
  - 添加了健康检查
  - 使用Redis 7-alpine镜像（更小、更快）
  - 添加了服务依赖条件
  - 添加了日志目录挂载

### 3. 优化Dockerfile
- 创建了`Dockerfile.optimized`，包含以下优化：
  - 使用稳定的Node.js 18版本而不是latest
  - 添加了curl用于健康检查
  - 优化了依赖安装过程
  - 添加了Docker健康检查

## 如何应用修复

### 选项1: 使用修复后的原始文件
```bash
# 停止当前容器
docker-compose down

# 重新构建并启动
docker-compose up -d --build
```

### 选项2: 使用优化版本
```bash
# 停止当前容器
docker-compose down

# 使用优化版本启动
docker-compose -f docker-compose-modern.yml up -d --build
```

### 选项3: 完全优化部署
```bash
# 停止当前容器
docker-compose down

# 修改docker-compose.yml使用优化的Dockerfile
# 将build部分改为：
# build:
#   context: .
#   dockerfile: Dockerfile.optimized

# 重新构建并启动
docker-compose up -d --build
```

## 验证修复

运行以下命令验证修复是否成功：
```bash
# 检查容器状态
docker-compose ps

# 查看容器日志
docker-compose logs 99ai

# 检查健康状态（如果使用优化版本）
docker-compose exec 99ai curl -f http://localhost:9520/health
```

## 其他建议

1. **定期更新基础镜像**: 建议定期更新Node.js和MySQL镜像版本
2. **监控资源使用**: 使用`docker stats`监控容器资源使用情况
3. **备份重要数据**: 定期备份MySQL和Redis数据目录

## 故障排除

如果遇到问题，请检查：
1. 确保所有端口没有被占用
2. 检查防火墙设置
3. 验证环境变量配置
4. 查看容器日志获取详细错误信息