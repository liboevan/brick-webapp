# Brick Hub

[English README](./README.en.md)

> 现代化 Vue.js 3 仪表盘，服务于 Brick 生态

[![Vue.js](https://img.shields.io/badge/Vue.js-3.4+-green.svg)](https://vuejs.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://docker.com/)

Brick Hub 是 Brick 生态的统一管理界面，提供 NTP 管理、安全监控、系统运维等一站式入口。

## ✨ 功能亮点

- **🎛️ 统一仪表盘** - 所有 Brick 服务一站式管理
- **📊 实时监控** - 各组件状态与指标实时展示
- **🕐 NTP 管理** - 高级时间同步配置
- **🛡️ 安全中心** - 用户认证与系统安全
- **🚪 网关监控** - 反向代理与流量管理
- **📱 响应式设计** - 绿主题现代 UI，移动优先
- **⚙️ 运行时配置** - 无需重建即可切换配置
- **🐳 Docker 支持** - 生产级容器化

## 🚀 快速开始

### 一键启动（推荐）

```bash
./scripts/quick_start.sh
```

自动完成构建 → 运行 → 启动。

### 开发模式

```bash
# 安装依赖
npm install

# 启动开发服务器
npm run dev
# 访问 http://localhost:3000
```

### 生产部署

```bash
# 构建 Docker 镜像
./scripts/quick_start.sh build

# 运行容器
./scripts/quick_start.sh run

# 一步完成构建和运行
./scripts/quick_start.sh all
```

## 📋 依赖要求

- **Node.js** 18+ 及 npm
- **Docker** 与 Docker Compose（生产环境）
- **现代浏览器**（Chrome、Firefox、Safari、Edge）

## 🛠️ 脚本说明

### 主管理脚本

```bash
./scripts/quick_start.sh [action] [version]
```

| 动作 | 说明 |
|------|------|
| `build` | 仅构建 Docker 镜像 |
| `run` | 仅运行容器 |
| `test` | 测试 Web 应用（浏览器界面） |
| `clean` | 清理容器及可选镜像 |
| `logs` | 查看容器日志 |
| `status` | 查看容器状态与访问地址 |
| `all` (默认) | 全流程（构建 → 运行 → 启动） |

**示例：**
```bash
./scripts/quick_start.sh                    # 默认全流程
./scripts/quick_start.sh build              # 仅构建
./scripts/quick_start.sh run                # 仅运行
./scripts/quick_start.sh 1.0.0             # 指定版本全流程
./scripts/quick_start.sh build 1.0.0       # 指定版本构建
./scripts/quick_start.sh clean --image      # 清理容器及镜像
```

### 单独脚本

| 脚本 | 作用 | 用法 |
|------|------|------|
| `build-info.sh` | 生成构建元信息 | `./scripts/build-info.sh` |
| `clean.sh` | 清理容器与镜像 | `./scripts/clean.sh [--image]` |
| `config.sh` | 共享配置 | 被其他脚本调用 |
| `run.sh` | 运行容器 | `./scripts/run.sh [version]` |
| `build.sh` | 构建镜像 | `./scripts/build.sh [version]` |

## 🏗️ 项目结构

```
brick-hub/
├── src/                    # Vue.js 应用源码
│   ├── components/         # 组件
│   │   ├── Dashboard.vue   # 主仪表盘
│   │   ├── Login.vue       # 登录界面
│   │   ├── CustomNTP.vue   # NTP 管理
│   │   └── BuildInfo.vue   # 构建信息
│   ├── mixins/             # 复用逻辑
│   │   └── auth.ts         # 认证逻辑（TypeScript）
│   ├── config/             # 配置
│   │   └── dashboard.js    # 功能配置
│   ├── App.vue             # 根组件
│   └── main.ts             # 应用入口
├── public/                 # 静态资源与运行时配置
│   ├── config.js           # 当前配置
│   ├── config.dev.js       # 开发配置
│   ├── config.prod.js      # 生产配置
│   └── build-info.js       # 构建元信息
├── scripts/                # 管理脚本
│   ├── quick_start.sh      # 主管理脚本
│   ├── build-info.sh       # 构建信息生成
│   ├── clean.sh            # 清理
│   ├── config.sh           # 配置切换
│   ├── run.sh              # 快速运行
│   └── build.sh            # 构建脚本
├── package.json            # 依赖与脚本
├── vite.config.ts          # 构建配置
├── Dockerfile              # 生产镜像
├── docker-compose.yml      # 开发容器
└── README.md               # 本文件
```

## ⚙️ 配置说明

### 运行时配置系统

本应用支持“构建一次，随处配置”，无需重建即可切换环境。

**配置文件：**
- `public/config.js` - 当前激活配置（应用加载）
- `public/config.dev.js` - 开发环境模板
- `public/config.prod.js` - 生产环境模板

**快速切换配置：**
```bash
# 切换到开发环境
./scripts/config.sh dev

# 切换到生产环境
./scripts/config.sh prod

# 查看当前配置
./scripts/config.sh show
```

**配置结构示例：**
```javascript
window.BRICK_CONFIG = {
  // API 配置（全部经由 gateway）
  api: {
    baseUrl: 'http://localhost:17000/api',
    customNTP: {
      baseUrl: 'http://localhost:17000/api/customNTP',
      endpoints: {
        status: '/status',
        servers: '/servers',
        serverMode: '/server-mode',
        version: '/version',
        defaultServers: '/servers/default'
      }
    },
    sentinel: {
      baseUrl: 'http://localhost:17000/api/sentinel',
      endpoints: {
        health: '/health',
        metrics: '/metrics',
        alerts: '/alerts',
        configure: '/configure'
      }
    }
  },

  // 应用设置
  app: {
    title: 'Brick Hub',
    version: window.BUILD_INFO?.version || '0.1.0-dev',
    environment: 'production'
  },

  // 功能配置
  features: {
    customNTP: {
      enabled: true,
      title: 'Custom NTP',
      description: 'NTP 时间同步管理',
      icon: '🕐',
      url: '/customNTP',
      color: '#4CAF50'
    },
    sentinel: {
      enabled: true,
      title: 'Security Sentinel',
      description: '用户与安全管理',
      icon: '🛡️',
      url: '/sentinel',
      color: '#FF5722'
    },
    gateway: {
      enabled: true,
      title: 'Gateway Monitor',
      description: '反向代理与流量管理',
      icon: '🚪',
      url: '/gateway',
      color: '#2196F3'
    },
    login: {
      enabled: true,
      title: 'Login System',
      description: '用户认证与会话管理',
      icon: '🔑',
      url: '/login',
      color: '#9C27B0'
    }
  },

  // 系统信息
  system: {
    name: 'Brick System',
    version: window.BUILD_INFO?.version || '0.1.0-dev',
    status: 'online'
  },

  // 调试设置
  debug: {
    enabled: false,
    logLevel: 'info'
  }
}
```

**运行时配置原理：**
1. **一次构建**：`npm run build` 生成静态文件
2. **运行时配置**：修改 `public/config.js` 切换环境
3. **部署**：同一构建适配开发/生产
4. **无需重建**：只需更改配置文件并刷新

## 🔌 API 集成

### 后端服务

本应用集成以下 Brick 生态服务：

| 服务 | 用途 | 默认端口 | API 路径 |
|------|------|----------|----------|
| **customNTP** | NTP 时间同步 | 17003 | `/api/customNTP/*` |
| **brick-sentinel** | 认证与安全 | 17001 | `/api/sentinel/*` |
| **brick-gateway** | 反向代理与路由 | 17000 | `/api/*` |

所有 API 均通过 gateway 访问，地址为 `http://localhost:17000/api/`。

## 🎨 UI/UX 特性

### 设计系统

- **主色调**：绿主题 (#4CAF50)
- **框架**：Vue 3 与 Composition API
- **样式**：作用域 CSS 与 CSS 变量
- **响应式**：移动优先设计
- **现代 UI**：简洁、专业的界面

### 组件

- **仪表盘**：可配置功能卡片的主界面
- **登录**：现代化的登录界面
- **CustomNTP**：高级 NTP 配置界面
- **BuildInfo**：构建元信息展示

## 🧪 开发

### 开发测试

```bash
# 运行 linter
npm run lint

# 启动开发服务器
npm run dev
# 访问 http://localhost:3000
```

### 演示凭证

- **用户名**：`admin`
- **密码**：`password`

### 开发工作流程

1. **本地开发**
   ```bash
   npm run dev
   # 编辑 src/ 组件
   # 使用 mock API 测试
   ```

2. **集成测试**
   ```bash
   docker-compose up
   # 使用真实后端 API 测试
   ```

3. **生产构建**
   ```bash
   npm run build
   # 移交给领导/IT 团队
   ```

## 📦 构建与部署

### 前端开发者

```bash
# 生产环境构建
npm run build

# 测试生产构建
npm run preview

# 带特定版本构建
VERSION=1.0.0 npm run build:prod
```

### 运维/IT 团队

```bash
# 使用环境配置部署
cp env.example .env
./scripts/deploy.sh deploy

# 或手动部署
docker build -t brick-hub .
docker run -d --name brick-hub --restart unless-stopped -p 17002:80 brick-hub
```

## 🌐 网络配置

### 端口

| 端口 | 协议 | 用途 |
|------|------|------|
| `3000` | TCP | 开发服务器 |
| `17002` | TCP | 生产 HTTP 服务器 |
| `17000` | TCP | 网关（API 代理） |

### 环境变量

| 变量 | 默认值 | 描述 |
|------|------|------|
| `VERSION` | `0.1.0-dev` | 应用版本 |
| `BUILD_DATETIME` | 当前时间 | 构建时间戳 |
| `NODE_ENV` | `development` | Node.js 环境 |
| `IMAGE_NAME` | `el/brick-hub` | Docker 镜像名称 |
| `CONTAINER_NAME` | `el-brick-hub` | Docker 容器名称 |

## 🐳 Docker 部署

### 构建镜像

```bash
./scripts/quick_start.sh build [version]
```

**示例：**
```bash
./scripts/quick_start.sh build                    # 使用默认版本构建
./scripts/quick_start.sh build 1.0.0             # 使用特定版本构建
```

### 运行容器

```bash
./scripts/quick_start.sh run [version]
```

**示例：**
```bash
./scripts/quick_start.sh run                     # 使用默认版本运行
./scripts/quick_start.sh run 1.0.0              # 使用特定版本运行
```

## 🔍 监控与故障排除

### 检查服务状态

```bash
# 容器状态
./scripts/quick_start.sh status

# 查看日志
./scripts/quick_start.sh logs

# 测试应用
curl http://localhost:17002
```

### 常见问题

1. **端口冲突**：确保端口 17002 可用
2. **API 连接**：检查后端服务是否运行
3. **构建错误**：运行 `npm install` 并重试
4. **Docker 问题**：检查 Docker 是否运行
5. **配置问题**：验证 `public/config.js` 是否正确

### 开发提示

- 使用 Vue DevTools 进行调试
- 检查浏览器控制台错误
- 使用不同屏幕尺寸测试
- 验证 API 响应
- 使用配置切换脚本切换环境

## 🏗️ 架构

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Web Browser   │    │   Brick Hub     │    │   Brick Gateway │
│   (Port 17002)  │◄──►│   (Frontend)    │◄──►│   (Port 17000)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       │
                                │                       ▼
                                │              ┌─────────────────┐
                                │              │   Backend APIs  │
                                │              │  (Clock, etc.)  │
                                │              └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   Runtime Config│
                       │  (public/config)│
                       └─────────────────┘
```

## 📈 性能

- **快速加载**：优化 Vue 3 与 Vite
- **响应式**：移动优先设计
- **可扩展**：模块化组件架构
- **高效**：运行时配置系统

## 🔒 安全考虑

- **HTTPS**：生产环境使用 HTTPS
- **认证**：生产环境实施严格认证
- **CORS**：配置 API 访问的 CORS
- **更新**：定期更新依赖

## 🤝 贡献

1. Fork 项目
2. 创建功能分支
3. 进行更改
4. 全面测试
5. 提交拉取请求

## 📄 许可证

本项目是 Brick 生态系统的一部分。请查看主仓库获取许可证信息。

## 📞 支持

如遇问题，请查看故障排除部分：
- 审查 API 文档
- 在仓库中打开问题

---

**版本**：0.1.0-dev  
**最后更新**：2025 年 1 月 