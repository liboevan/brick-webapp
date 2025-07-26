# Multi-stage build for Vue.js application
FROM node:20.10-alpine AS build-stage

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Set version and build datetime
ARG VERSION=0.1.0-dev
ARG BUILD_DATETIME
ENV VERSION=$VERSION
ENV BUILD_DATETIME=$BUILD_DATETIME

# Generate build info for frontend (creates build-info.json and build-info.js in public/)
RUN chmod +x scripts/build-info.sh && sh scripts/build-info.sh

# Build the application
RUN npm run build

# Create VERSION file in container (not in codebase)
RUN echo "$VERSION" > /app/VERSION

# Create build-info.json in container (not in codebase)
RUN echo "{\"version\":\"$VERSION\",\"buildDateTime\":\"$BUILD_DATETIME\",\"buildTimestamp\":$(date +%s),\"environment\":\"production\",\"service\":\"brick-webapp\",\"description\":\"Frontend Application\"}" > /app/build-info.json

# Production stage
FROM alpine:latest AS production-stage
RUN apk --no-cache add nginx curl

# Copy built application
COPY --from=build-stage /app/dist /usr/share/nginx/html

# Copy VERSION and build-info.json from build stage
COPY --from=build-stage /app/VERSION /VERSION
COPY --from=build-stage /app/build-info.json /build-info.json

# Remove default nginx configurations
RUN rm -rf /etc/nginx/conf.d/* /etc/nginx/sites-enabled/* /etc/nginx/sites-available/*

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Health check configuration
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:17002/health || exit 1

# Expose the application port
EXPOSE 17002

# Set the health check
# Add volume declaration
VOLUME ["/var/log/nginx"]

# Start nginx
CMD ["nginx", "-g", "daemon off;"]