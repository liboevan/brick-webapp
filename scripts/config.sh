#!/bin/bash

# Shared Configuration for Brick Hub Scripts
# This file contains common variables and functions used by all scripts

# Project Configuration
PROJECT_NAME="brick-webapp"
IMAGE_NAME="brick-webapp"
CONTAINER_NAME="brick-webapp"
API_PORT="17002"
DEFAULT_VERSION="0.1.0-dev"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}======================================"
    echo -e "Brick Webapp - $1"
    echo -e "======================================${NC}"
}

# Common Docker operations
cleanup_container() {
    print_info "Cleaning up existing container..."
    docker stop $CONTAINER_NAME 2>/dev/null || true
    docker rm $CONTAINER_NAME 2>/dev/null || true
}

run_container() {
    local version_arg="$1"
    if [ -n "$version_arg" ]; then
        VERSION="$version_arg"
    else
        VERSION="$DEFAULT_VERSION"
    fi
    print_info "Running $CONTAINER_NAME (version: $VERSION)..."
    docker run -d --name $CONTAINER_NAME \
      --network el-brick-network \
      -e NODE_ENV=production \
      -p $API_PORT:$API_PORT \
      $IMAGE_NAME:$VERSION
    print_info "Container started!"
    echo "   Web App: http://localhost:$API_PORT"
    echo "   Version: $VERSION"
}

wait_for_api() {
    print_info "Waiting for web application to be ready..."
    for i in {1..30}; do
        if curl -s http://localhost:$API_PORT > /dev/null 2>&1; then
            print_info "Web application is ready!"
            return 0
        fi
        if [ $i -eq 30 ]; then
            print_error "Web application failed to start within 30 seconds"
            return 1
        fi
        sleep 1
    done
}

 