#!/bin/bash

# Docker Production Testing Script
# For frontend developers who want to test production build

set -e

ACTION=${1:-help}

case $ACTION in
    "build")
        echo "🔨 Building Docker image..."
        VERSION=${VERSION:-0.1.0-dev}
        docker build --build-arg VERSION=$VERSION -t el/brick-hub .
        echo "✅ Docker image built successfully!"
        ;;
    
    "run")
        echo "🚀 Running Docker container..."
        docker run -d --name el-brick-hub -p 17002:17002 el/brick-hub
        echo "✅ Container started at http://localhost:17002 (internal: 17002)"
        ;;
    
    "stop")
        echo "🛑 Stopping Docker container..."
        docker stop el-brick-hub
        docker rm el-brick-hub
        echo "✅ Container stopped and removed"
        ;;
    
    "restart")
        echo "🔄 Restarting Docker container..."
        docker stop el-brick-hub 2>/dev/null || true
        docker rm el-brick-hub 2>/dev/null || true
        docker run -d --name el-brick-hub -p 17002:17002 el/brick-hub
        echo "✅ Container restarted at http://localhost:17002 (internal: 17002)"
        ;;
    
    "logs")
        echo "📊 Showing container logs..."
        docker logs -f el-brick-hub
        ;;
    
    "clean")
        echo "🧹 Cleaning up..."
        docker stop el-brick-hub 2>/dev/null || true
        docker rm el-brick-hub 2>/dev/null || true
        docker rmi el/brick-hub 2>/dev/null || true
        echo "✅ Cleanup completed"
        ;;
    
    "build-and-run")
        echo "🔨 Building and running..."
        VERSION=${VERSION:-0.1.0-dev}
        docker build --build-arg VERSION=$VERSION -t el/brick-hub .
        docker stop el-brick-hub 2>/dev/null || true
        docker rm el-brick-hub 2>/dev/null || true
        docker run -d --name el-brick-hub -p 17002:17002 el/brick-hub
        echo "✅ Container running at http://localhost:17002"
        ;;
    
            "help"|*)
        echo "Docker Production Testing Script"
        echo ""
        echo "Usage: ./scripts/docker.sh [action]"
        echo ""
        echo "Actions:"
        echo "  build         - Build Docker image"
        echo "  run           - Run container"
        echo "  stop          - Stop container"
        echo "  restart       - Restart container"
        echo "  logs          - Show container logs"
        echo "  clean         - Clean up everything"
        echo "  build-and-run - Build and run in one command"
        echo "  help          - Show this help"
        echo ""
        echo "Examples:"
        echo "  ./scripts/docker.sh build-and-run"
        echo "  ./scripts/docker.sh logs"
        ;;
esac 