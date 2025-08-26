FROM php:8.2-cli

# Instalar extensiones necesarias para Laravel
RUN apt-get update && apt-get install -y \
    libzip-dev unzip git curl libpng-dev libxml2-dev \
    && docker-php-ext-configure zip \
    && docker-php-ext-install pdo pdo_mysql zip bcmath mbstring exif pcntl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copiar composer.json y composer.lock primero (para cache de dependencias)
COPY composer.json composer.lock ./

RUN COMPOSER_MEMORY_LIMIT=-1 composer install \
    --no-dev \
    --optimize-autoloader \
    --prefer-dist \
    --no-interaction \
    --no-scripts

# Copiar el resto del proyecto
COPY . .

# Permisos
RUN chown -R www-data:www-data storage bootstrap/cache

EXPOSE 8080

# Iniciar Laravel con el servidor embebido en el puerto que Render asigna
CMD php artisan serve --host=0.0.0.0 --port=${PORT:-8080}







