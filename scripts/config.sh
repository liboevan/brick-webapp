#!/bin/bash

# Common configuration for brick-hub
PROJECT_NAME="brick-hub"
SERVICE_NAME="hub"
DEFAULT_VERSION="0.1.0-dev"
DEFAULT_IMAGE_NAME="el/brick-hub"
DEFAULT_CONTAINER_NAME="el-brick-hub"
DEFAULT_PORT="17002"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get version from package.json or use default
get_version() {
    if [ -f "package.json" ]; then
        node -p "require('./package.json').version" 2>/dev/null || echo "$DEFAULT_VERSION"
    else
        echo "$DEFAULT_VERSION"
    fi
}

# Get current datetime for build info
get_build_datetime() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker is not running or not accessible"
        exit 1
    fi
}

# Check if container exists
container_exists() {
    docker ps -a --format "table {{.Names}}" | grep -q "^$DEFAULT_CONTAINER_NAME$"
}

# Check if container is running
container_running() {
    docker ps --format "table {{.Names}}" | grep -q "^$DEFAULT_CONTAINER_NAME$"
}

# Check if Node.js is installed
check_node() {
    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed or not in PATH"
        exit 1
    fi
}

# Check if npm is installed
check_npm() {
    if ! command -v npm &> /dev/null; then
        log_error "npm is not installed or not in PATH"
        exit 1
    fi
} 