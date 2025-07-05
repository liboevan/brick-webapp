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

# Debug: List scripts directory
RUN ls -l scripts

# Make scripts executable and generate build info
ARG VERSION=0.1.0-dev
ENV VERSION=$VERSION
RUN chmod +x scripts/build-info.sh && sh scripts/build-info.sh

# Build the application
RUN npm run build

# Production stage
FROM nginx:alpine as production-stage

# Copy built application
COPY --from=build-stage /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 17002

# Start nginx
CMD ["nginx", "-g", "daemon off;"] 