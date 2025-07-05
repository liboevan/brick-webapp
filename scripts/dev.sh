#!/bin/bash

# Frontend Development Script
# For frontend developers only

set -e

ACTION=${1:-help}

case $ACTION in
    "start")
        echo "🚀 Starting development server..."
        npm run dev
        ;;
    
    "build")
        echo "🔨 Building for production..."
        npm run build
        ;;
    
    "build:dev")
        echo "🔨 Building for development..."
        npm run build:dev
        ;;
    
    "build:prod")
        echo "🔨 Building for production..."
        npm run build:prod
        ;;
    
    "preview")
        echo "👀 Previewing production build..."
        npm run preview
        ;;
    
    "docker")
        echo "🐳 Starting Docker development environment..."
        docker-compose up --build
        ;;
    
    "docker-stop")
        echo "🛑 Stopping Docker environment..."
        docker-compose down
        ;;
    
    "lint")
        echo "🔍 Running linter..."
        npm run lint
        ;;
    
    "install")
        echo "📦 Installing dependencies..."
        npm install
        ;;
    
    "clean")
        echo "🧹 Cleaning build artifacts..."
        rm -rf dist node_modules/.vite
        ;;
    
    "help"|*)
        echo "Frontend Development Script"
        echo ""
        echo "Usage: ./scripts/dev.sh [action]"
        echo ""
        echo "Actions:"
        echo "  start        - Start development server"
        echo "  build        - Build for production"
        echo "  build:dev    - Build for development"
        echo "  build:prod   - Build for production"
        echo "  preview      - Preview production build"
        echo "  docker       - Start Docker environment"
        echo "  docker-stop  - Stop Docker environment"
        echo "  lint         - Run linter"
        echo "  install      - Install dependencies"
        echo "  clean        - Clean build artifacts"
        echo "  help         - Show this help"
        echo ""
        echo "Examples:"
        echo "  ./scripts/dev.sh start"
        echo "  ./scripts/dev.sh docker"
        ;;
esac 