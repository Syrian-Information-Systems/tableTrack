#!/bin/sh
set -e

# Ensure working dir
cd /var/www/html

# If .env doesn't exist but .env.example does, copy it
if [ ! -f .env ] && [ -f .env.example ]; then
  cp .env.example .env
fi

# Install composer dependencies if vendor missing (dev/test friendly)
if [ ! -f vendor/autoload.php ]; then
  composer install --prefer-dist --no-interaction --no-progress
fi

# Set permissions (so storage is writable)
chown -R www-data:www-data storage bootstrap/cache || true
chmod -R 775 storage bootstrap/cache || true

# Generate app key if missing
if [ -f artisan ] && ! php artisan key:generate --force >/dev/null 2>&1; then
  php artisan key:generate --force || true
fi

# Start php-fpm
exec php-fpm
