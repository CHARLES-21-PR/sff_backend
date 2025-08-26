# ---- Stage 1: Composer ----
FROM composer:2 AS vendor

WORKDIR /app

COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --prefer-dist --no-interaction --no-progress

COPY . .
RUN composer dump-autoload --optimize


# ---- Stage 2: PHP-FPM + Nginx ----
FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    nginx \
    libzip-dev unzip git curl libpng-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql zip bcmath mbstring exif pcntl

COPY --from=vendor /app /var/www/html

# Configuración de Nginx (lo tomará de nginx.conf en raíz)
RUN rm /etc/nginx/sites-enabled/default || true
COPY nginx.conf /etc/nginx/conf.d/default.conf

RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

WORKDIR /var/www/html

EXPOSE 10000

CMD service nginx start && php-fpm





