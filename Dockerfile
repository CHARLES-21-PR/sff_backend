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

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copiar composer.json y composer.lock primero (cache de dependencias)
COPY composer.json composer.lock ./

# Instalar dependencias con menos consumo de memoria
RUN COMPOSER_MEMORY_LIMIT=-1 composer install \
    --no-dev \
    --optimize-autoloader \
    --prefer-dist \
    --no-interaction \
    --no-scripts

# Copiar el resto del proyecto
COPY . .

# Copiar configuración de Nginx
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# Permisos
RUN chown -R www-data:www-data storage bootstrap/cache

EXPOSE 8080

CMD service nginx start && php-fpm






