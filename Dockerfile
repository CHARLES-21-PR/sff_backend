# Imagen base oficial de PHP con Composer incluido
FROM composer:2 AS build

WORKDIR /app

# Copiar composer y dependencias primero (para aprovechar la cache de Docker)
COPY composer.json composer.lock ./

# Instalar dependencias de PHP de Laravel
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist --no-scripts


# Copiar el resto del proyecto
COPY . .

# Etapa final
FROM php:8.2-cli

WORKDIR /app

# Instalar extensiones mínimas necesarias
RUN docker-php-ext-install pdo pdo_mysql

# Copiar archivos desde la etapa de build
COPY --from=build /app /app

# Exponer el puerto
EXPOSE 8000

# Comando para iniciar Laravel
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]







