# Use a PHP image with Composer for the build stage
FROM php:8.2-fpm-alpine as builder

# Install system dependencies
RUN apk add --no-cache \
    git \
    curl \
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
    xml

# Set working directory
WORKDIR /app

# Install Composer
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

# Copy the entire application code
COPY . .

# Copy composer files and install dependencies
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Optimize Laravel
RUN php artisan route:cache
RUN php artisan view:cache

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

# Install PHP extensions (runtime only)
RUN docker-php-ext-install -j$(nproc) \
    pdo_mysql \
    zip \
    gd \
    intl \
    mbstring \
    xml

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

# Start PHP-FPM in background and Nginx in foreground
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]
