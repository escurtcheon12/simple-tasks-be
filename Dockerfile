# --- Build Stage ---
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

WORKDIR /app

# Install Composer
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

# Copy code and install dependencies
COPY . .
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Optimize Laravel (Optional but recommended)
RUN php artisan route:cache || true
RUN php artisan view:cache || true

# --- Production Stage ---
FROM php:8.2-fpm-alpine as app

# Install ONLY runtime dependencies (libraries, not -dev headers)
RUN apk add --no-cache \
    nginx \
    libzip \
    libpng \
    libjpeg-turbo \
    freetype \
    icu-libs \
    oniguruma \
    libxml2 \
    mysql-client

# Install PHP extensions for runtime
RUN docker-php-ext-install -j$(nproc) \
    pdo_mysql \
    zip \
    gd \
    intl \
    mbstring \
    xml

WORKDIR /var/www/html

# Copy from builder
COPY --from=builder /app /var/www/html

# Copy Nginx config
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# Permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80

# Start script to run both Nginx and PHP-FPM
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]