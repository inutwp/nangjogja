# Dockerfile NangJogja
# Repository  : PHP
# version     : 7.4.x FPM:alpine

# Set master image
FROM php:7.4-fpm-alpine

LABEL maintainer="master.gloqi@gmail.com" \
      description="This image is used to setup NangJogja application" \
      version="1.0"

# Set working directory
WORKDIR /var/www/

# Install Additional dependencies
RUN apk update && apk add --no-cache \
    build-base shadow supervisor \
    php7-common \
    php7-pdo \
    php7-pdo_mysql \
    php7-mysqli \
    php7-mcrypt \
    php7-mbstring \
    php7-xml \
    php7-openssl \
    php7-json \
    php7-phar \
    php7-zip \
    php7-gd \
    php7-dom \
    php7-session \
    php7-zlib \
    bash \
    vim

# Add and Enable PHP-PDO Extenstions
RUN docker-php-ext-install pdo pdo_mysql && docker-php-ext-enable pdo_mysql opcache 

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Remove Cache
RUN rm -rf /var/lib/apt/lists/* && rm -rf /var/cache/apk/*

# Create vendor directory
RUN mkdir /var/www/vendor

# Add user for laravel application
RUN groupadd -g 1000 www && useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
COPY . /var/www

# Copy existing application directory permissions
COPY --chown=www:www . /var/www

# Set File & Folder permission
RUN chmod -R 0644 /var/www && find /var/www -type d -print0 | xargs -0 chmod 0755

# Change current user to www
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]