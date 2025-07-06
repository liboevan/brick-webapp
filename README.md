# Brick Hub

> A modern Vue.js 3 dashboard for the Brick ecosystem

[![Vue.js](https://img.shields.io/badge/Vue.js-3.4+-green.svg)](https://vuejs.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://docker.com/)

Brick Hub is the central dashboard and user interface for the Brick ecosystem, providing unified access to all Brick services including NTP management, security monitoring, and system administration.

## ✨ Features

- **🎛️ Unified Dashboard** - Single interface for all Brick services
- **📊 Real-time Monitoring** - Live status and metrics for all components
- **🕐 Custom NTP Management** - Advanced time synchronization configuration
- **🛡️ Security Sentinel** - User authentication and system security
- **🚪 Gateway Monitoring** - Reverse proxy and traffic management
- **📱 Responsive Design** - Mobile-first, modern UI with green theme
- **⚙️ Runtime Configuration** - Configure without rebuilding
- **🐳 Docker Ready** - Production-ready containerization

## 🚀 Quick Start

### One-Command Setup (Recommended)

```bash
./scripts/quick_start.sh
```

This performs a complete build → run → launch cycle.

### Development Mode

```bash
# Install dependencies
npm install

# Start development server
npm run dev
# Access at http://localhost:3000
```

### Production Deployment

```bash
# Build Docker image
./scripts/quick_start.sh build

# Run container
./scripts/quick_start.sh run

# Or do both in one command
./scripts/quick_start.sh all
```

## 📋 Prerequisites

- **Node.js** 18+ and npm
- **Docker** and Docker Compose (for production)
- **Modern web browser** (Chrome, Firefox, Safari, Edge)

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
./scripts/quick_start.sh                    # Full cycle with default version
./scripts/quick_start.sh build              # Build only
./scripts/quick_start.sh run                # Run only
./scripts/quick_start.sh 1.0.0             # Full cycle with version 1.0.0
./scripts/quick_start.sh build 1.0.0       # Build with version 1.0.0
./scripts/quick_start.sh clean --image      # Clean container and all images
```

### Individual Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `build-info.sh` | Generate build metadata | `./scripts/build-info.sh` |
| `clean.sh` | Clean container and images | `./scripts/clean.sh [--image]` |
| `config.sh` | Shared configuration | Used by other scripts |
| `run.sh` | Run container | `./scripts/run.sh [version]` |
| `build.sh` | Build Docker image | `./scripts/build.sh [version]` |

## 🏗️ Project Structure

```
brick-hub/
├── src/                    # Vue.js application source
│   ├── components/         # Vue components
│   │   ├── Dashboard.vue   # Main dashboard interface
│   │   ├── Login.vue       # Authentication interface
│   │   ├── CustomNTP.vue   # NTP management interface
│   │   └── BuildInfo.vue   # Build information display
│   ├── mixins/             # Shared functionality
│   │   └── auth.js         # Authentication logic
│   ├── config/             # Configuration
│   │   └── dashboard.js    # Feature configuration
│   ├── App.vue             # Root component
│   └── main.js             # Application entry point
├── public/                 # Static assets and runtime config
│   ├── config.js           # Active runtime configuration
│   ├── config.dev.js       # Development configuration
│   ├── config.prod.js      # Production configuration
│   └── build-info.js       # Build metadata
├── scripts/                # Management scripts
│   ├── quick_start.sh      # Main management script
│   ├── build-info.sh       # Build metadata generation
│   ├── clean.sh            # Clean build artifacts
│   ├── config.sh           # Configuration switching
│   ├── run.sh              # Quick run script
│   └── build.sh            # Build script
├── package.json            # Dependencies and scripts
├── vite.config.js          # Build configuration
├── Dockerfile              # Production container
├── docker-compose.yml      # Development container
└── README.md               # This file
```

## ⚙️ Configuration

### Runtime Configuration System

The application uses a sophisticated runtime configuration system that allows **build once, configure anywhere** deployment.

**Configuration Files:**
- `public/config.js` - Active configuration (loaded by app)
- `public/config.dev.js` - Development configuration template
- `public/config.prod.js` - Production configuration template

**Quick Configuration Switch:**
```bash
# Switch to development
./scripts/config.sh dev

# Switch to production  
./scripts/config.sh prod

# Show current config
./scripts/config.sh show
```

**Configuration Structure:**
```javascript
window.BRICK_CONFIG = {
  // API Configuration - All through gateway
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

  // Application Settings
  app: {
    title: 'Brick Hub',
    version: window.BUILD_INFO?.version || '0.1.0-dev',
    environment: 'production'
  },

  // Feature Configuration
  features: {
    customNTP: {
      enabled: true,
      title: 'Custom NTP',
      description: 'Configure and manage NTP time synchronization',
      icon: '🕐',
      url: '/customNTP',
      color: '#4CAF50'
    },
    sentinel: {
      enabled: true,
      title: 'Security Sentinel',
      description: 'User management and authentication system',
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

  // System Configuration
  system: {
    name: 'Brick System',
    version: window.BUILD_INFO?.version || '0.1.0-dev',
    status: 'online'
  },

  // Debug Settings
  debug: {
    enabled: false,
    logLevel: 'info'
  }
}
```

**How Runtime Configuration Works:**
1. **Build once**: `npm run build` creates static files
2. **Configure runtime**: Modify `public/config.js` for environment
3. **Deploy**: Same build works for dev/prod with different configs
4. **No rebuild needed**: Just change config file and refresh

## 🔌 API Integration

### Backend Services

The application integrates with these Brick ecosystem services:

| Service | Purpose | Default Port | API Path |
|---------|---------|--------------|----------|
| **customNTP** | NTP time synchronization | 17003 | `/api/customNTP/*` |
| **brick-sentinel** | Authentication & security | 17001 | `/api/sentinel/*` |
| **brick-gateway** | Reverse proxy & routing | 17000 | `/api/*` |

All APIs are accessed through the gateway at `http://localhost:17000/api/`.

## 🎨 UI/UX Features

### Design System

- **Primary Color**: Green theme (#4CAF50)
- **Framework**: Vue 3 with Composition API
- **Styling**: Scoped CSS with CSS variables
- **Responsive**: Mobile-first design
- **Modern UI**: Clean, professional interface

### Components

- **Dashboard**: Main interface with configurable feature cards
- **Login**: Authentication interface with modern design
- **CustomNTP**: Advanced NTP configuration interface
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

1. **Local Development**
   ```bash
   npm run dev
   # Edit src/ components
   # Test with mock APIs
   ```

2. **Integration Testing**
   ```bash
   docker-compose up
   # Test with real backend APIs
   ```

3. **Production Build**
   ```bash
   npm run build
   # Hand over to lead/IT team
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
# Deploy using environment configuration
cp env.example .env
./scripts/deploy.sh deploy

# Or manual deployment
docker build -t brick-hub .
docker run -d --name brick-hub --restart unless-stopped -p 17002:80 brick-hub
```

## 🌐 Network Configuration

### Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3000` | TCP | Development server |
| `17002` | TCP | Production HTTP server |
| `17000` | TCP | Gateway (API proxy) |

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `VERSION` | `0.1.0-dev` | Application version |
| `BUILD_DATETIME` | Current time | Build timestamp |
| `NODE_ENV` | `development` | Node.js environment |
| `IMAGE_NAME` | `el/brick-hub` | Docker image name |
| `CONTAINER_NAME` | `el-brick-hub` | Docker container name |

## 🐳 Docker Deployment

### Build Image

```bash
./scripts/quick_start.sh build [version]
```

**Examples:**
```bash
./scripts/quick_start.sh build                    # Build with default version
./scripts/quick_start.sh build 1.0.0             # Build with specific version
```

### Run Container

```bash
./scripts/quick_start.sh run [version]
```

**Examples:**
```bash
./scripts/quick_start.sh run                     # Run with default version
./scripts/quick_start.sh run 1.0.0              # Run with specific version
```

## 🔍 Monitoring & Troubleshooting

### Check Service Status

```bash
# Container status
./scripts/quick_start.sh status

# View logs
./scripts/quick_start.sh logs

# Test application
curl http://localhost:17002
```

### Common Issues

1. **Port Conflicts**: Ensure port 17002 is available
2. **API Connection**: Check if backend services are running
3. **Build Errors**: Run `npm install` and try again
4. **Docker Issues**: Check if Docker is running
5. **Configuration**: Verify `public/config.js` is correct

### Development Tips

- Use Vue DevTools for debugging
- Check browser console for errors
- Test with different screen sizes
- Validate API responses
- Use the configuration switch script for environment changes

## 🏗️ Architecture

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

## 📈 Performance

- **Fast Loading**: Optimized Vue 3 with Vite
- **Responsive**: Mobile-first design
- **Scalable**: Modular component architecture
- **Efficient**: Runtime configuration system

## 🔒 Security Considerations

- **HTTPS**: Use HTTPS in production
- **Authentication**: Implement proper auth in production
- **CORS**: Configure CORS for API access
- **Updates**: Regularly update dependencies

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is part of the Brick ecosystem. See the main repository for license information.

## 📞 Support

For issues and questions:
- Check the troubleshooting section above
- Review the API documentation
- Open an issue in the repository

---

**Version**: 0.1.0-dev  
**Last Updated**: January 2025 