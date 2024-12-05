# Builder stage
FROM node:lts-alpine AS builder

# Add non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set working directory and change ownership
WORKDIR /app
RUN chown appuser:appgroup /app

# Switch to non-root user
USER appuser

# Copy package files first to leverage layer caching
COPY --chown=appuser:appgroup package*.json ./

# Install all dependencies including devDependencies for building
RUN npm ci && \
    npm cache clean --force

# Copy source code
COPY --chown=appuser:appgroup . .

# Define build arguments
ARG API_KEY
ARG CONFIGURATION=production
ENV API_KEY=$API_KEY
ENV CONFIGURATION=$CONFIGURATION

# Build the application
RUN npm run build -- --configuration=$CONFIGURATION --define apiKey=\"$API_KEY\" --define configuration=\"$CONFIGURATION\"

# Production stage
FROM nginx:1.25-alpine

# Add non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy built assets from builder stage
COPY --from=builder --chown=appuser:appgroup /app/dist/ng-env-docker-demo/browser /usr/share/nginx/html

# Copy nginx configuration
COPY --chown=appuser:appgroup nginx.conf /etc/nginx/conf.d/default.conf

# Update permissions for nginx
RUN chown -R appuser:appgroup /var/cache/nginx && \
    chown -R appuser:appgroup /var/log/nginx && \
    chown -R appuser:appgroup /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R appuser:appgroup /var/run/nginx.pid

USER appuser

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
