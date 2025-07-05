# Brick System Architecture

## Overview

The Brick system is a microservices-based application consisting of four main components:

1. **Vue Frontend** (`brick-gate-ui`) - User interface
2. **Nginx Reverse Proxy** (`brick-gateway`) - Load balancer and SSL termination
3. **Chrony Suite Backend** (`brick-chrony-suite`) - Time synchronization API
4. **Nginx Watchdog Backend** (`brick-nginx-watchdog`) - Monitoring and health checking

## Architecture Diagram

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Internet      │    │   Nginx Proxy   │    │   Vue Frontend  │
│   (Port 80/443) │───▶│   (Port 80/443) │───▶│   (Container)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ├─▶ Chrony Suite API (Port 8001)
                                └─▶ Watchdog API (Port 8002)
```

## Service Details

### 1. Nginx Reverse Proxy (`brick-gateway`)
- **Purpose**: Load balancer, SSL termination, and request routing
- **Ports**: 80 (HTTP), 443 (HTTPS)
- **Container**: `nginx-proxy`
- **Features**:
  - SSL/TLS termination
  - Request routing to backend services
  - Static file serving
  - Health check endpoints

### 2. Vue Frontend (`brick-gate-ui`)
- **Purpose**: User interface and client-side application
- **Technology**: Vue.js with Vite
- **Container**: `vue-gate-app`
- **Features**:
  - Modern SPA interface
  - API integration
  - Responsive design
  - Development hot-reload (dev mode)

### 3. Chrony Suite Backend (`brick-chrony-suite`)
- **Purpose**: Time synchronization and NTP server management
- **Technology**: Go/Python
- **Port**: 8001
- **Container**: `chrony-suite`
- **Features**:
  - NTP server configuration
  - Time synchronization monitoring
  - REST API for management
  - Logging and metrics

### 4. Nginx Watchdog Backend (`brick-nginx-watchdog`)
- **Purpose**: Monitoring and health checking of Nginx servers
- **Technology**: Go
- **Port**: 8002
- **Container**: `nginx-watchdog`
- **Features**:
  - Nginx server monitoring
  - Health check aggregation
  - Alert system
  - Database storage for metrics

## Network Architecture

### Docker Network
All services run on a custom bridge network called `app-network`:
- **Type**: Bridge network
- **Driver**: bridge
- **Purpose**: Isolated communication between services

### Port Mapping
- **80/443**: Nginx proxy (external access)
- **8001**: Chrony API (direct access for debugging)
- **8002**: Watchdog API (direct access for debugging)

## Data Flow

1. **External Request**: Client makes request to domain
2. **Nginx Proxy**: Receives request and routes based on path
3. **Service Routing**:
   - `/` → Vue Frontend
   - `/api/chrony/*` → Chrony Suite Backend
   - `/api/watchdog/*` → Watchdog Backend
4. **Response**: Service responds through Nginx proxy

## Environment Configurations

### Development
- Hot-reload enabled for frontend
- Debug logging enabled
- Source code mounted as volumes
- Local development URLs

### Production
- Optimized builds
- Resource limits configured
- SSL certificates required
- Monitoring and alerting enabled

## Security Considerations

- SSL/TLS termination at proxy level
- Container isolation
- Environment variable management
- Regular security updates
- Backup and recovery procedures

## Monitoring and Logging

- Centralized logging through Docker
- Health check endpoints
- Metrics collection
- Alert system integration
- Backup automation 