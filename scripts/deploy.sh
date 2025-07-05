#!/bin/bash

# Hub Deployment Script
# For same-server deployment

set -e

# Load environment variables
if [ -f .env ]; then
    echo "📋 Loading environment variables..."
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "⚠️  No .env file found. Using defaults..."
    export VITE_SERVER_PORT=17002
    export HUB_CONTAINER_NAME=el-brick-hub
fi

ACTION=${1:-help}

case $ACTION in
    "build")
        echo "🔨 Building Hub container..."
        docker build -t el/brick-hub .
        echo "✅ Build completed!"
        ;;
    
    "deploy")
        echo "🚀 Deploying Hub..."
        
        # Stop existing container
        echo "🛑 Stopping existing container..."
        docker stop el-brick-hub 2>/dev/null || true
        docker rm el-brick-hub 2>/dev/null || true
        
        # Build and run
        echo "🔨 Building container..."
        docker build -t el/brick-hub .
        
        echo "🚀 Starting container on port $VITE_SERVER_PORT..."
        docker run -d \
            --name el-brick-hub \
            --restart unless-stopped \
            -p $VITE_SERVER_PORT:17002 \
            el/brick-hub
        
        echo "✅ Hub deployed successfully!"
        echo "📍 Access at: http://localhost:$VITE_SERVER_PORT (internal: 80)"
        echo "🔗 Gateway proxy: http://localhost (via brick-gateway)"
        ;;
    
    "stop")
        echo "🛑 Stopping Hub..."
        docker stop el-brick-hub
        docker rm el-brick-hub
        echo "✅ Hub stopped!"
        ;;
    
    "restart")
        echo "🔄 Restarting Hub..."
        ./scripts/deploy.sh stop
        ./scripts/deploy.sh deploy
        ;;
    
    "logs")
        echo "📊 Showing Hub logs..."
        docker logs -f el-brick-hub
        ;;
    
    "status")
        echo "📊 Hub Status:"
        docker ps -a --filter name=el-brick-hub
        echo ""
        echo "🔗 Port: $VITE_SERVER_PORT"
        echo "🌐 URL: http://localhost:$VITE_SERVER_PORT"
        ;;
    
    "clean")
        echo "🧹 Cleaning up..."
        docker stop el-brick-hub 2>/dev/null || true
        docker rm el-brick-hub 2>/dev/null || true
        docker rmi el/brick-hub 2>/dev/null || true
        echo "✅ Cleanup completed!"
        ;;
    
    "help"|*)
        echo "Hub Deployment Script"
        echo ""
        echo "Usage: ./scripts/deploy.sh [action]"
        echo ""
        echo "Actions:"
        echo "  build     - Build container"
        echo "  deploy    - Build and deploy"
        echo "  stop      - Stop container"
        echo "  restart   - Restart container"
        echo "  logs      - Show container logs"
        echo "  status    - Show container status"
        echo "  clean     - Clean up everything"
        echo "  help      - Show this help"
        echo ""
        echo "Environment:"
        echo "  Create .env from env.example"
        echo "  Configure ports and settings"
        echo ""
        echo "Examples:"
        echo "  ./scripts/deploy.sh deploy"
        echo "  ./scripts/deploy.sh status"
        ;;
esac 