# Multi-stage build for React app
FROM node:20-alpine as build

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy built app to nginx (Vite uses 'dist' directory)
COPY --from=build /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Create entrypoint script to inject runtime config
RUN echo '#!/bin/sh' > /docker-entrypoint.sh && \
    echo 'echo "window.APP_CONFIG = { API_BASE_URL: \"${VITE_API_BASE_URL:-http://localhost:8080}\" };" > /usr/share/nginx/html/config.js' >> /docker-entrypoint.sh && \
    echo 'nginx -g "daemon off;"' >> /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

# Start with entrypoint script
ENTRYPOINT ["/docker-entrypoint.sh"]