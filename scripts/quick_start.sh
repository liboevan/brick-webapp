#!/bin/bash
set -e

# Source shared configuration
source "$(dirname "$0")/config.sh"

# Parse command line arguments
ACTION=${1:-"default"}

case $ACTION in
    "dev")
        log_info "Starting development server..."
        check_node
        check_npm
        npm run dev
        ;;
    "build")
        log_info "Building $PROJECT_NAME..."
        check_node
        check_npm
        npm run build
        ;;
    "docker-build")
        log_info "Building Docker image..."
        check_docker
        VERSION=$(get_version)
        BUILD_DATETIME=$(get_build_datetime)
        docker build \
            --build-arg VERSION="$VERSION" \
            --build-arg BUILD_DATETIME="$BUILD_DATETIME" \
            -t "$DEFAULT_IMAGE_NAME:$VERSION" \
            -t "$DEFAULT_IMAGE_NAME:latest" \
            .
        log_success "Docker image built successfully"
        ;;
    "docker-run")
        log_info "Running Docker container..."
        check_docker
        VERSION=$(get_version)
        
        # Stop and remove existing container if running
        if container_running; then
            log_info "Stopping existing container..."
            docker stop "$DEFAULT_CONTAINER_NAME"
        fi

        if container_exists; then
            log_info "Removing existing container..."
            docker rm "$DEFAULT_CONTAINER_NAME"
        fi

        # Run the container
        docker run -d \
            --name "$DEFAULT_CONTAINER_NAME" \
            -p "$DEFAULT_PORT:$DEFAULT_PORT" \
            "$DEFAULT_IMAGE_NAME:$VERSION"

        log_success "$PROJECT_NAME v$VERSION started successfully"
        log_info "Container: $DEFAULT_CONTAINER_NAME"
        log_info "Port: $DEFAULT_PORT"
        log_info "URL: http://localhost:$DEFAULT_PORT"
        ;;
    "docker-stop")
        log_info "Stopping Docker container..."
        check_docker
        docker stop "$DEFAULT_CONTAINER_NAME" 2>/dev/null || true
        docker rm "$DEFAULT_CONTAINER_NAME" 2>/dev/null || true
        log_success "Container stopped and removed"
        ;;
    "clean")
        log_info "Cleaning $PROJECT_NAME..."
        # Clean npm artifacts
        rm -rf node_modules/.vite dist
        log_success "Build artifacts cleaned"
        ;;
    "docker-clean")
        log_info "Cleaning Docker artifacts..."
        check_docker
        if container_exists; then
            log_info "Found $DEFAULT_CONTAINER_NAME container, stopping and removing..."
            docker stop "$DEFAULT_CONTAINER_NAME" 2>/dev/null || true
            docker rm "$DEFAULT_CONTAINER_NAME" 2>/dev/null || true
            log_success "Container cleaned up successfully!"
        else
            log_warning "No $DEFAULT_CONTAINER_NAME container found."
        fi

        # Optional: Remove the image if requested
        if [ "$2" = "--image" ]; then
            log_info "Removing $DEFAULT_IMAGE_NAME image..."
            docker rmi "$DEFAULT_IMAGE_NAME" 2>/dev/null || true
            log_success "Image removed successfully!"
        fi

        log_success "Docker cleanup completed!"
        ;;
    "install")
        log_info "Installing dependencies..."
        check_node
        check_npm
        npm install
        log_success "Dependencies installed"
        ;;
    "test")
        log_info "Testing $PROJECT_NAME..."
        check_node
        check_npm
        npm run lint
        log_success "Linting completed"
        ;;
    "default"|*)
        log_info "Running full cycle: build, docker-build, docker-run"
        check_node
        check_npm
        npm run build
        ./scripts/quick_start.sh docker-build
        ./scripts/quick_start.sh docker-run
        log_success "Full cycle completed!"
        log_info "Access the application at: http://localhost:$DEFAULT_PORT"
        ;;
esac 