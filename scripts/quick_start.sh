#!/bin/bash

# Quick Start Script for Brick Webapp Service
# Build, run, and launch the web application by default
# Usage: ./quick_start.sh [action] [version] or ./quick_start.sh [version]
# Actions: build, run, test, clean, all (default)

set -e

# Source shared configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# If the first argument looks like a version, treat it as version and use default action 'all'
if [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+.*$ ]]; then
    ACTION=all
    VERSION_ARG=$1
else
    ACTION=${1:-all}
    VERSION_ARG=$2
fi

echo "🚀 Brick Webapp Quick Start Script"
echo "================================"

case $ACTION in
    "build")
        print_header "Build"
        "$SCRIPT_DIR/build.sh" $VERSION_ARG
        ;;
    
    "run")
        print_header "Run"
        "$SCRIPT_DIR/run.sh" $VERSION_ARG
        ;;
    
    "test")
        print_header "Test"
        print_info "For web applications, please test through the browser interface"
        print_info "Web App: http://localhost:$API_PORT"
        ;;
    
    "clean")
        print_header "Clean"
        "$SCRIPT_DIR/clean.sh" $2
        ;;
    
    "logs")
        print_info "Showing container logs..."
        docker logs -f $CONTAINER_NAME
        ;;
    
    "status")
        print_info "Container Status:"
        docker ps -a --filter name=$CONTAINER_NAME
        echo ""
        print_info "Web Application URL:"
        echo "   http://localhost:$API_PORT"
        ;;
    
    "all"|*)
        print_header "Full Cycle: Build → Run → Launch"
        
        # Build
        "$SCRIPT_DIR/build.sh" $VERSION_ARG
        echo ""
        
        # Run
        "$SCRIPT_DIR/run.sh" $VERSION_ARG
        echo ""
        
        # Wait for web app to be ready
        wait_for_api
        echo ""
        
        print_info "Web application is ready!"
        print_info "Please test through the browser interface"
        
        echo ""
        print_info "Quick start completed!"
        echo "   Web App: http://localhost:$API_PORT"
        echo "   Logs: ./scripts/quick_start.sh logs"
        echo "   Status: ./scripts/quick_start.sh status"
        ;;
esac