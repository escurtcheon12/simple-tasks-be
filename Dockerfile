# Trigger new build to resolve deployment conflict

# Use a PHP image with Composer for the build stage
FROM php:8.2-fpm-alpine as builder

# Install system dependencies
RUN apk add --no-cache \
    git \
    curl \
    pkgconf \
    libzip \
    libzip-dev \
    zlib-dev \
    libpng-dev \
    jpeg-dev \
    freetype-dev \
    icu-dev \
    postgresql-dev \
    mysql-client \
    oniguruma-dev \
    libxml2-dev

# Install PHP extensions
RUN docker-php-ext-install -j$(nproc) \
    pdo_mysql \
    zip \
    gd \
    intl \
    mbstring \
    xml \
    bcmath

# Set working directory
WORKDIR /app

# Install Composer
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

# Copy the entire application code
COPY . .

# Copy composer files and install dependencies
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Optimize Laravel (Build-time)
RUN php artisan config:cache
RUN php artisan route:cache

# --- Production Stage ---
FROM php:8.2-fpm-alpine as app

# Install system dependencies for runtime
RUN apk add --no-cache \
    nginx \
    curl \
    libzip \
    libpng \
    jpeg \
    freetype \
    icu \
    oniguruma \
    libxml2

# Copy pre-built PHP extensions from builder stage
COPY --from=builder /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=builder /usr/local/etc/php/conf.d /usr/local/etc/php/conf.d

# Set working directory
WORKDIR /var/www/html

# Copy application code from builder stage
COPY --from=builder /app .

# Remove the frontend directory as it's served separately
RUN rm -rf frontend

# Copy Nginx configuration to the main location
COPY docker/nginx.conf /etc/nginx/nginx.conf

# Create necessary directories and set permissions
RUN mkdir -p /run/nginx /var/log/nginx /var/lib/nginx/tmp && \
    chown -R www-data:www-data /run/nginx /var/log/nginx /var/lib/nginx /var/www/html/storage /var/www/html/bootstrap/cache

# Set permissions for Laravel storage and cache
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port 80 for Nginx
EXPOSE 80

# Start PHP-FPM in background and Nginx in foreground (Runtime)
# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
