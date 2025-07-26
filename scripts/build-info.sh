#!/bin/bash

# Build Info Script for Brick Hub
# Generates build metadata for the Vue.js application

set -e

# Get version from environment or use default
VERSION=${VERSION:-0.1.0-dev}
BUILD_DATETIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILD_TIMESTAMP=$(date +%s)

# Create build info JSON
cat > public/build-info.json << EOF
{
  "version": "$VERSION",
  "buildDateTime": "$BUILD_DATETIME",
  "buildTimestamp": $BUILD_TIMESTAMP,
  "environment": "production",
  "service": "brick-webapp",
  "description": "Frontend Application"
}
EOF

# Create build info JS for frontend consumption
cat > public/build-info.js << EOF
window.BUILD_INFO = {
  version: "$VERSION",
  buildDateTime: "$BUILD_DATETIME",
  buildTimestamp: $BUILD_TIMESTAMP,
  environment: "production",
  service: "brick-webapp",}]}}}
  description: "Frontend Application"
};
EOF

echo "Build info generated:"
echo "  Version: $VERSION"
echo "  Build DateTime: $BUILD_DATETIME"
echo "  Build Timestamp: $BUILD_TIMESTAMP"
echo "  Files: public/build-info.json, public/build-info.js"