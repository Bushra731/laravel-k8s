FROM composer:2 AS vendor
WORKDIR /app
COPY . .
RUN for i in 1 2 3 4 5 6 7 8; do \
      composer install --no-dev --no-scripts --no-interaction --prefer-dist --ignore-platform-reqs && break; \
      echo "retry $i"; sleep 5; \
    done

FROM php:8.4-apache
RUN docker-php-ext-install pdo pdo_mysql && a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
WORKDIR /var/www/html
COPY . .
COPY --from=vendor /app/vendor ./vendor
RUN mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache \
 && chown -R www-data:www-data storage bootstrap/cache
EXPOSE 80
