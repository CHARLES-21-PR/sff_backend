# Etapa 1: Dependencias con Composer
FROM composer:2 AS vendor
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist
COPY . .

# Etapa 2: Imagen final con PHP + Nginx
FROM php:8.2-fpm

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    nginx \
    libzip-dev \
    unzip \
    git \
    curl \
    libpng-dev \
    libxml2-dev \
    && docker-php-ext-configure zip \
    && docker-php-ext-install pdo pdo_mysql zip bcmath mbstring exif pcntl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# Copiar dependencias de vendor
COPY --from=vendor /app/vendor ./vendor

# Copiar código fuente
COPY . .

# Copiar configuración de Nginx
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# Permisos para Laravel
RUN chown -R www-data:www-data storage bootstrap/cache

EXPOSE 8080

# Iniciar PHP-FPM y Nginx
CMD service nginx start && php-fpm





