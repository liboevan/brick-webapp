# Multi-stage build for Vue.js application
FROM node:20.10-alpine as build-stage

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
RUN echo "{\"version\":\"$VERSION\",\"buildDateTime\":\"$BUILD_DATETIME\",\"buildTimestamp\":$(date +%s),\"environment\":\"production\",\"service\":\"brick-hub\",\"description\":\"Frontend Application\"}" > /app/build-info.json

# Production stage
FROM nginx:alpine as production-stage

# Copy built application
COPY --from=build-stage /app/dist /usr/share/nginx/html

# Copy VERSION and build-info.json from build stage
COPY --from=build-stage /app/VERSION /VERSION
COPY --from=build-stage /app/build-info.json /build-info.json

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 17002

# Start nginx
CMD ["nginx", "-g", "daemon off;"] 