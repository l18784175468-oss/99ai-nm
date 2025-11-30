# 项目打包指南

## 前置要求

1. **安装 Node.js** (版本 18 或更高)
2. **安装 pnpm** (推荐使用 pnpm 作为包管理器)
   ```bash
   npm install -g pnpm
   ```

## 打包步骤

### 方法一：使用打包脚本（推荐）

#### Windows 系统
```powershell
# 直接执行各个模块的打包命令
cd admin
pnpm install
pnpm build
cd ..

cd chat
pnpm install
pnpm build
cd ..

cd service
pnpm install
pnpm build
cd ..
```

#### Linux/Mac 系统
```bash
chmod +x build.sh
./build.sh
```

### 方法二：手动打包

#### 1. 打包 Admin 模块
```bash
cd admin
pnpm install
pnpm build
cd ..
```

#### 2. 打包 Chat 模块
```bash
cd chat
pnpm install
pnpm build
cd ..
```

#### 3. 打包 Service 模块
```bash
cd service
pnpm install
pnpm build
cd ..
```

#### 4. 复制文件到 AIWebQuickDeploy

将以下文件复制到 `AIWebQuickDeploy` 目录：

**从 service 目录复制：**
- `dist/*` → `AIWebQuickDeploy/dist/`
- `pm2.conf.json` → `AIWebQuickDeploy/pm2.conf.json`
- `package.json` → `AIWebQuickDeploy/package.json`
- `.env.example` → `AIWebQuickDeploy/.env.example` (如果存在)
- `.env.docker` → `AIWebQuickDeploy/.env.docker` (如果存在)
- `Dockerfile` → `AIWebQuickDeploy/Dockerfile`
- `docker-compose.yml` → `AIWebQuickDeploy/docker-compose.yml`
- `.dockerignore` → `AIWebQuickDeploy/.dockerignore` (如果存在)

**从 admin 目录复制：**
- `dist/*` → `AIWebQuickDeploy/public/admin/`

**从 chat 目录复制：**
- `dist/*` → `AIWebQuickDeploy/public/chat/`

## 打包后的目录结构

```
AIWebQuickDeploy/
├── dist/              # Service 构建产物
├── public/
│   ├── admin/         # Admin 前端构建产物
│   └── chat/          # Chat 前端构建产物
├── pm2.conf.json      # PM2 配置文件
├── package.json       # 项目依赖配置
├── Dockerfile         # Docker 构建文件
├── docker-compose.yml # Docker Compose 配置
└── .env.example       # 环境变量示例文件
```

## 注意事项

1. **依赖安装**：如果 `node_modules` 目录不存在，打包脚本会自动安装依赖
2. **构建顺序**：建议按照 admin → chat → service 的顺序打包
3. **清理旧文件**：打包前会自动清理 `AIWebQuickDeploy` 目录中的旧文件
4. **环境变量**：打包后需要手动配置 `.env` 文件

## 验证打包结果

打包完成后，检查以下内容：

1. ✅ `AIWebQuickDeploy/dist/main.js` 存在
2. ✅ `AIWebQuickDeploy/public/admin/index.html` 存在
3. ✅ `AIWebQuickDeploy/public/chat/index.html` 存在
4. ✅ 所有配置文件已复制

## 常见问题

### Q: pnpm 未找到
**A:** 安装 pnpm：
```bash
npm install -g pnpm
```

### Q: 构建失败
**A:** 
1. 检查 Node.js 版本是否符合要求
2. 删除 `node_modules` 和 `pnpm-lock.yaml`，重新安装依赖
3. 检查网络连接，确保能访问 npm 仓库

### Q: 文件复制失败
**A:** 
1. 确保有写入权限
2. 检查目标目录是否存在
3. 手动创建缺失的目录

