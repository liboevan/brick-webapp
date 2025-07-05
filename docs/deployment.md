# Brick Deployment Guide

## Prerequisites

- Docker and Docker Compose installed
- Git for version control
- At least 2GB RAM available
- Ports 80, 443, 8001, 8002 available

## Quick Start

### 1. Clone the Repository
```bash
git clone <your-blueprint-repo-url>
cd brick-blueprint
```

### 2. Set Up Environment
```bash
# Copy environment template
cp env.example .env

# Edit environment variables
nano .env
```

### 3. Deploy
```bash
# Development deployment
./scripts/deploy.sh dev

# Production deployment
./scripts/deploy.sh prod
```

## Detailed Deployment Steps

### Development Environment

1. **Prepare Environment**
   ```bash
   # Create necessary directories
   mkdir -p logs/nginx logs/chrony logs/watchdog
   mkdir -p data/watchdog config/chrony certs backups
   
   # Set up environment
   cp env.example .env
   # Edit .env with your settings
   ```

2. **Deploy Services**
   ```bash
   # Build and start all services
   docker-compose -f docker-compose.yml:docker-compose.dev.yml up -d
   
   # Or use the deployment script
   ./scripts/deploy.sh dev
   ```

3. **Verify Deployment**
   ```bash
   # Check service status
   docker-compose ps
   
   # Run health checks
   ./scripts/health-check.sh
   
   # View logs
   docker-compose logs -f
   ```

### Production Environment

1. **SSL Certificate Setup**
   ```bash
   # Place your SSL certificates in the certs directory
   cp your-cert.pem certs/cert.pem
   cp your-key.pem certs/key.pem
   ```

2. **Environment Configuration**
   ```bash
   # Edit production environment
   nano .env
   # Set APP_ENV=production
   # Configure domain names
   # Set secure passwords
   ```

3. **Deploy Production**
   ```bash
   # Production deployment with resource limits
   ./scripts/deploy.sh prod
   ```

## Service Management

### Start Services
```bash
docker-compose up -d
```

### Stop Services
```bash
docker-compose down
```

### Restart Services
```bash
docker-compose restart
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f nginx-proxy
docker-compose logs -f vue-gate
docker-compose logs -f chrony-suite
docker-compose logs -f nginx-watchdog
```

### Update Services
```bash
# Pull latest changes from service repos
git pull origin main

# Rebuild and restart
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Backup and Recovery

### Create Backup
```bash
./scripts/backup.sh
```

### Restore from Backup
```bash
# Extract backup files
tar -xzf backups/data_<timestamp>.tar.gz
tar -xzf backups/config_<timestamp>.tar.gz
tar -xzf backups/compose_<timestamp>.tar.gz

# Restore environment
cp backups/env_<timestamp> .env

# Restart services
docker-compose up -d
```

## Monitoring

### Health Checks
```bash
# Manual health check
./scripts/health-check.sh

# Check specific endpoints
curl http://localhost
curl http://localhost:8001
curl http://localhost:8002
```

### Resource Monitoring
```bash
# View container resource usage
docker stats

# View disk usage
docker system df
```

## Troubleshooting

### Common Issues

1. **Port Already in Use**
   ```bash
   # Check what's using the port
   sudo netstat -tulpn | grep :80
   
   # Stop conflicting service
   sudo systemctl stop nginx
   ```

2. **Container Won't Start**
   ```bash
   # Check container logs
   docker-compose logs <service-name>
   
   # Check container status
   docker ps -a
   ```

3. **Build Failures**
   ```bash
   # Clean Docker cache
   docker system prune -a
   
   # Rebuild without cache
   docker-compose build --no-cache
   ```

### Log Locations
- **Nginx Proxy**: `./logs/nginx/`
- **Chrony Suite**: `./logs/chrony/`
- **Watchdog**: `./logs/watchdog/`

## Security Considerations

1. **Environment Variables**
   - Never commit `.env` files
   - Use strong passwords
   - Rotate secrets regularly

2. **SSL/TLS**
   - Use valid certificates
   - Configure proper cipher suites
   - Enable HSTS headers

3. **Network Security**
   - Use firewall rules
   - Limit port exposure
   - Monitor network traffic

## Performance Tuning

### Resource Limits
```yaml
# In docker-compose.prod.yml
deploy:
  resources:
    limits:
      memory: 512M
      cpus: '0.5'
```

### Scaling
```bash
# Scale specific service
docker-compose up -d --scale chrony-suite=3
```

## Maintenance

### Regular Tasks
- Weekly backups
- Monthly security updates
- Quarterly performance reviews
- Annual certificate renewal

### Updates
```bash
# Update all services
git pull origin main
docker-compose pull
docker-compose up -d
``` 