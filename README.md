# Brick Hub - Frontend Application

A modern Vue.js 3 application serving as the central dashboard and user interface for the Brick ecosystem. Provides unified access to all Brick services including NTP management, security monitoring, and system administration.

## 🚀 Features

- **Unified Dashboard**: Single interface for all Brick services
- **Real-time Monitoring**: Live status and metrics for all components
- **Custom NTP Management**: Advanced time synchronization configuration
- **Security Sentinel**: User authentication and system security
- **Gateway Monitoring**: Reverse proxy and traffic management
- **Responsive Design**: Mobile-first, modern UI with green theme
- **Runtime Configuration**: Configure without rebuilding
- **Docker Ready**: Production-ready containerization

## 📋 Prerequisites

- Node.js 18+ and npm
- Docker and Docker Compose (for production)
- Modern web browser (Chrome, Firefox, Safari, Edge)

## 🛠️ Quick Start

### Option 1: One-Command Setup (Recommended)

```bash
./scripts/quick_start.sh
```

This performs a complete build → docker build → run cycle.

### Option 2: Development Mode

```bash
# Install dependencies
npm install

# Start development server
npm run dev
# Access at http://localhost:3000
```

### Option 3: Step-by-Step Production

```bash
# Build the application
./scripts/quick_start.sh build

# Build Docker image
./scripts/quick_start.sh docker-build

# Run container
./scripts/quick_start.sh docker-run
```

## 📚 Scripts Reference

### Main Management Script

```bash
./scripts/quick_start.sh [command]
```

**Commands:**
- `dev` - Start development server
- `build` - Build application only
- `docker-build` - Build Docker image only
- `docker-run` - Run container only
- `docker-stop` - Stop and remove container
- `clean` - Clean build artifacts
- `docker-clean` - Clean Docker artifacts
- `install` - Install dependencies
- `test` - Run linting tests
- `default` - Full cycle (build → docker-build → docker-run)

### Individual Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `dev.sh` | Development workflow | `./scripts/dev.sh [mode]` |
| `docker.sh` | Docker operations | `./scripts/docker.sh [action]` |
| `deploy.sh` | Production deployment | `./scripts/deploy.sh [action]` |
| `config-switch.sh` | Configuration management | `./scripts/config-switch.sh [env]` |
| `build-info.sh` | Build metadata | `./scripts/build-info.sh` |

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
│   ├── dev.sh              # Development workflow
│   ├── docker.sh           # Docker operations
│   ├── deploy.sh           # Production deployment
│   ├── config-switch.sh    # Configuration switching
│   └── build-info.sh       # Build metadata generation
├── package.json            # Dependencies and scripts
├── vite.config.js          # Build configuration
├── Dockerfile              # Production container
├── docker-compose.yml      # Development container
└── README.md               # This file
```

## 🔧 Configuration

### Runtime Configuration System

The application uses a sophisticated runtime configuration system that allows **build once, configure anywhere** deployment.

**Configuration Files:**
- `public/config.js` - Active configuration (loaded by app)
- `public/config.dev.js` - Development configuration template
- `public/config.prod.js` - Production configuration template

**Quick Configuration Switch:**
```bash
# Switch to development
./scripts/config-switch.sh dev

# Switch to production  
./scripts/config-switch.sh prod

# Show current config
./scripts/config-switch.sh show
```

**Configuration Structure:**
```javascript
window.BRICK_CONFIG = {
  // API Configuration - All through gateway
  api: {
    baseUrl: 'http://localhost:17000/api',
    clock: {
      baseUrl: 'http://localhost:17000/api/clock',
      endpoints: {
        currentTime: '/current-time',
        timezone: '/timezone',
        format: '/format'
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
    clock: {
      enabled: true,
      title: 'Custom NTP',
      description: 'Configure and manage NTP time synchronization',
      icon: '🕐',
      url: '/clock',
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
| **brick-clock** | NTP time synchronization | 17003 | `/api/clock/*` |
| **brick-sentinel** | Authentication & security | 17001 | `/api/sentinel/*` |
| **brick-gateway** | Reverse proxy & routing | 17000 | `/api/*` |

### API Documentation

- **Clock API**: NTP management and time synchronization
- **Sentinel API**: User authentication and security monitoring
- **Gateway API**: Reverse proxy and traffic management

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

## 🧪 Testing & Development

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
./scripts/quick_start.sh docker-build [version]
```

**Examples:**
```bash
./scripts/quick_start.sh docker-build                    # Build with default version
./scripts/quick_start.sh docker-build 1.0.0             # Build with specific version
```

### Run Container

```bash
./scripts/quick_start.sh docker-run [version]
```

**Examples:**
```bash
./scripts/quick_start.sh docker-run                     # Run with default version
./scripts/quick_start.sh docker-run 1.0.0              # Run with specific version
```

## 🔍 Monitoring & Troubleshooting

### Check Service Status

```bash
# Container status
./scripts/quick_start.sh docker-stop && ./scripts/quick_start.sh docker-run

# View logs
docker logs el-brick-hub

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
**Last Updated**: July 2025 