#!/bin/bash

# Build Information Generator
# Generates version and build date for the application

set -e

# Default version
DEFAULT_VERSION="0.1.0-dev"

# Get version from environment or use default
VERSION=${VERSION:-$DEFAULT_VERSION}

# Generate build date
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILD_TIMESTAMP=$(date +%s)

# Create build info object
BUILD_INFO=$(cat <<EOF
window.BUILD_INFO = {
  version: '$VERSION',
  buildDate: '$BUILD_DATE',
  buildTimestamp: $BUILD_TIMESTAMP,
  environment: '${NODE_ENV:-production}'
};
EOF
)

# Create build info file
echo "$BUILD_INFO" > public/build-info.js

echo "📦 Build Information Generated:"
echo "   Version: $VERSION"
echo "   Build Date: $BUILD_DATE"
echo "   Environment: ${NODE_ENV:-production}"
echo "   File: public/build-info.js" 