# Imagen base PHP con extensiones necesarias
# Imagen base de PHP con extensiones necesarias
# Etapa 1: PHP con dependencias
FROM php:8.2-fpm

# Instalar extensiones requeridas por Laravel
RUN docker-php-ext-install pdo pdo_mysql

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copiar proyecto
WORKDIR /var/www/html
COPY . .

# Instalar dependencias
RUN composer install --no-dev --optimize-autoloader

# Dar permisos de escritura
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Etapa 2: Nginx
FROM nginx:alpine

# Copiar config de nginx
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# Copiar app desde la primera etapa
COPY --from=0 /var/www/html /var/www/html

WORKDIR /var/www/html

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]




