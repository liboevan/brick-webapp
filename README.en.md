# Brick Hub

[中文文档](./README.md)

> A modern Vue.js 3 dashboard for the Brick ecosystem

[![Vue.js](https://img.shields.io/badge/Vue.js-3.4+-green.svg)](https://vuejs.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://docker.com/)

Brick Hub is the unified management interface for the Brick ecosystem, providing one-stop access for NTP management, security monitoring, and system administration.

## ✨ Features

- **🎛️ Unified Dashboard** - Manage all Brick services in one place
- **📊 Real-time Monitoring** - Live status and metrics for all components
- **🕐 NTP Management** - Advanced time synchronization configuration
- **🛡️ Security Center** - User authentication and system security
- **🚪 Gateway Monitoring** - Reverse proxy and traffic management
- **📱 Responsive Design** - Green theme, mobile-first modern UI
- **⚙️ Runtime Configuration** - Switch config without rebuilding
- **🐳 Docker Support** - Production-ready containerization

## 🚀 Quick Start

### One-Command Setup (Recommended)

```bash
./scripts/quick_start.sh
```

Automatically completes build → run → launch.

### Development Mode

```bash
# Install dependencies
npm install

# Start development server
npm run dev
# Visit http://localhost:3000
```

### Production Deployment

```bash
# Build Docker image
./scripts/quick_start.sh build

# Run container
./scripts/quick_start.sh run

# Build and run in one step
./scripts/quick_start.sh all
```

## 📋 Prerequisites

- **Node.js** 18+ and npm
- **Docker** and Docker Compose (for production)
- **Modern browser** (Chrome, Firefox, Safari, Edge)

## 🛠️ Scripts Reference

### Main Management Script

```bash
./scripts/quick_start.sh [action] [version]
```

| Action | Description |
|--------|-------------|
| `build` | Build Docker image only |
| `run` | Run container only |
| `test` | Test web application (browser interface) |
| `clean` | Clean container and optionally images |
| `logs` | Show container logs |
| `status` | Show container status and URLs |
| `all` (default) | Full cycle (build → run → launch) |

**Examples:**
```bash
./scripts/quick_start.sh                    # Default full cycle
./scripts/quick_start.sh build              # Build only
./scripts/quick_start.sh run                # Run only
./scripts/quick_start.sh 1.0.0             # Full cycle with version
./scripts/quick_start.sh build 1.0.0       # Build with version
./scripts/quick_start.sh clean --image      # Clean container and images
```

### Individual Scripts

| Script | Purpose | Usage |
|--------|--------|-------|
| `build-info.sh` | Generate build metadata | `./scripts/build-info.sh` |
| `clean.sh` | Clean container and images | `./scripts/clean.sh [--image]` |
| `config.sh` | Shared configuration | Used by other scripts |
| `run.sh` | Run container | `./scripts/run.sh [version]` |
| `build.sh` | Build image | `./scripts/build.sh [version]` |

## 🏗️ Project Structure

```
brick-hub/
├── src/                    # Vue.js application source
│   ├── components/         # Components
│   │   ├── Dashboard.vue   # Main dashboard
│   │   ├── Login.vue       # Login page
│   │   ├── CustomNTP.vue   # NTP management
│   │   └── BuildInfo.vue   # Build info
│   ├── mixins/             # Reusable logic
│   │   └── auth.ts         # Auth logic (TypeScript)
│   ├── config/             # Configuration
│   │   └── dashboard.js    # Feature config
│   ├── App.vue             # Root component
│   └── main.ts             # App entry
├── public/                 # Static assets & runtime config
│   ├── config.js           # Active config
│   ├── config.dev.js       # Dev config
│   ├── config.prod.js      # Prod config
│   └── build-info.js       # Build metadata
├── scripts/                # Management scripts
│   ├── quick_start.sh      # Main management script
│   ├── build-info.sh       # Build info generation
│   ├── clean.sh            # Clean
│   ├── config.sh           # Config switch
│   ├── run.sh              # Quick run
│   └── build.sh            # Build script
├── package.json            # Dependencies & scripts
├── vite.config.ts          # Build config
├── Dockerfile              # Production image
├── docker-compose.yml      # Dev container
└── README.md               # This file
```

## ⚙️ Configuration

### Runtime Configuration System

This app supports "build once, configure anywhere"—no rebuild needed for environment switching.

**Config files:**
- `public/config.js` - Active config (loaded by app)
- `public/config.dev.js` - Dev config template
- `public/config.prod.js` - Prod config template

**Quick config switch:**
```bash
# Switch to development
./scripts/config.sh dev

# Switch to production
./scripts/config.sh prod

# Show current config
./scripts/config.sh show
```

**Config structure example:**
```javascript
window.BRICK_CONFIG = {
  // API config (all via gateway)
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

  // App settings
  app: {
    title: 'Brick Hub',
    version: window.BUILD_INFO?.version || '0.1.0-dev',
    environment: 'production'
  },

  // Feature config
  features: {
    customNTP: {
      enabled: true,
      title: 'Custom NTP',
      description: 'NTP time sync management',
      icon: '🕐',
      url: '/customNTP',
      color: '#4CAF50'
    },
    sentinel: {
      enabled: true,
      title: 'Security Sentinel',
      description: 'User and security management',
      icon: '🛡️',
      url: '/sentinel',
      color: '#FF5722'
    },
    gateway: {
      enabled: true,
      title: 'Gateway Monitor',
      description: 'Reverse proxy and traffic management',
      icon: '🚪',
      url: '/gateway',
      color: '#2196F3'
    },
    login: {
      enabled: true,
      title: 'Login System',
      description: 'User authentication and session management',
      icon: '🔑',
      url: '/login',
      color: '#9C27B0'
    }
  },

  // System info
  system: {
    name: 'Brick System',
    version: window.BUILD_INFO?.version || '0.1.0-dev',
    status: 'online'
  },

  // Debug settings
  debug: {
    enabled: false,
    logLevel: 'info'
  }
}
```

**How runtime config works:**
1. **Build once**: `npm run build` generates static files
2. **Configure at runtime**: Edit `public/config.js` to switch environment
3. **Deploy**: Same build for dev/prod
4. **No rebuild needed**: Just change config and refresh

## 🔌 API Integration

### Backend Services

This app integrates the following Brick ecosystem services:

| Service | Purpose | Default Port | API Path |
|---------|--------|-------------|----------|
| **customNTP** | NTP time sync | 17003 | `/api/customNTP/*` |
| **brick-sentinel** | Auth & security | 17001 | `/api/sentinel/*` |
| **brick-gateway** | Reverse proxy & routing | 17000 | `/api/*` |

All APIs are accessed via the gateway at `http://localhost:17000/api/`.

## 🎨 UI/UX Features

### Design System

- **Primary color**: Green theme (#4CAF50)
- **Framework**: Vue 3 with Composition API
- **Styling**: Scoped CSS and CSS variables
- **Responsive**: Mobile-first design
- **Modern UI**: Clean, professional interface

### Components

- **Dashboard**: Main interface with configurable feature cards
- **Login**: Modern login interface
- **CustomNTP**: Advanced NTP config interface
- **BuildInfo**: Build metadata display

## 🧪 Development

### Development Testing

```bash
# Run linter
npm run lint

# Start development server
npm run dev
# Visit http://localhost:3000
```

### Demo Credentials

- **Username**: `admin`
- **Password**: `password`

### Development Workflow

1. **Local development**
   ```bash
   npm run dev
   # Edit src/ components
   # Test with mock APIs
   ```
2. **Integration testing**
   ```bash
   docker-compose up
   # Test with real backend APIs
   ```
3. **Production build**
   ```bash
   npm run build
   # Handover to lead/IT team
   ```

## 📦 Build and Deploy

### For Frontend Developers

```bash
# Build for production
npm run build

# Test production build
npm run preview

# Build with specific version
VERSION=1.0.0 npm run build:prod
```

### For DevOps/IT Team

```bash
# Deploy using environment config
cp env.example .env
./scripts/deploy.sh deploy

# Or manual deployment
``` 