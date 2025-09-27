# Dockerfile
FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl unzip zip libzip-dev libonig-dev libpng-dev libjpeg-dev libfreetype6-dev \
    libxml2-dev libicu-dev pkg-config libssl-dev ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Configure GD
RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# Install PHP extensions required by Laravel & packages
RUN docker-php-ext-install -j$(nproc) pdo_mysql zip gd intl mbstring bcmath xml pcntl

# Install composer (copy from official composer image)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy entrypoint script (will run composer install if vendor missing)
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

# Expose php-fpm port for nginx
EXPOSE 9000

# Default command
CMD ["docker-entrypoint"]
