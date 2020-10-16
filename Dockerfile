FROM nginx:1.19.1-alpine

# Labels
LABEL nangjogja.version="v1.0"
LABEL nangjogja.base.image="nginx:1.19.1-alpine"
LABEL nangjogja.webserver.version="apache2.4"
LABEL nangjogja.php.version="php7.4:fpm"
LABEL nangjogja.laravel.version="Laravel 8"

# Argument list
ARG ALPINE_VERSION=3.9
ARG PHP_VERSION=7.4
ARG CONFIG_DIR=/config
ARG WORK_DIR=/var/www/nangjogja
ARG VENDOR_DIR=/var/www/nangjogja/vendor/
ARG LARAVEL_DIR=/src/

# Instal requirement
RUN apk --update --no-cache add ca-certificates supervisor bash
ADD https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/community" >> /etc/apk/repositories && \
    echo "https://dl.bintray.com/php-alpine/v${ALPINE_VERSION}/php-${PHP_VERSION}" >> /etc/apk/repositories && \
    apk add --update --no-cache \
    php \
    php-fpm \
    apache2-proxy \
    php-apache2 \
    php-openssl \
    php-pdo \
    php-pdo_mysql \
    php-mbstring \
    php-intl \
    php-phar \
    php-session \
    php-dom \
    php-ctype \
    php-gd \
    php-zip \
    php-zlib \
    php-json \
    php-curl \
    php-iconv \
    php-xmlreader \
    php-sockets \
    php-xml \
    php-opcache \
    nodejs \
    npm \
    tzdata \
    htop && \
    ln -s /usr/bin/php7 /usr/bin/php

# Config Nginx
RUN rm -rf /etc/nginx/nginx.conf && \
    rm -rf /etc/nginx/conf.d/default.conf && \
    mkdir -p /etc/nginx/sites-available/ && \
    mkdir -p /etc/nginx/sites-enabled/ && \
    ln -s /etc/nginx/sites-available/site.conf /etc/nginx/sites-enabled/site.conf
COPY ${CONFIG_DIR}/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ${CONFIG_DIR}/nginx/conf.d/site.conf /etc/nginx/conf.d/site.conf
COPY ${CONFIG_DIR}/nginx/conf.d/site.conf /etc/nginx/sites-available/site.conf

# Config Apache
RUN rm -rf /etc/apache2/httpd.conf && \
    mkdir -p /etc/apache2/sites-available/ && \
    mkdir -p /etc/apache2/sites-enabled/ && \
    ln -s /etc/apache2/sites-available/site.conf /etc/apache2/sites-enabled/site.conf
COPY ${CONFIG_DIR}/apache/site.conf /etc/apache2/sites-enabled/site.conf
COPY ${CONFIG_DIR}/apache/httpd.conf /etc/apache2/httpd.conf

# Config PHP
RUN rm -rf /etc/php7/php.ini && \
    rm -rf /etc/php7/php-fpm.d/www.conf
COPY ${CONFIG_DIR}/php/php.ini /etc/php7/php.ini
COPY ${CONFIG_DIR}/php/www.conf /etc/php7/php-fpm.d/www.conf

# Config supervisord
COPY ${CONFIG_DIR}/supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Set Timezone
RUN cp /usr/share/zoneinfo/Asia/Jakarta /etc/localtime && \
	echo "Asia/Jakarta" > /etc/timezone

# Remove Cache
RUN rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apk/*

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Make working directory and vendor directory
RUN mkdir -p ${WORK_DIR}

# Set working directory
WORKDIR ${WORK_DIR}

# Add user for laravel application
RUN addgroup -g 1000 -S nangjogja && \
    adduser -S -D -H -u 1000 -h ${WORK_DIR} -s /bin/bash -G nangjogja -g nangjogja nangjogja

# Copy existing application directory
COPY ${LARAVEL_DIR} ${WORK_DIR}

# Create & set owner vendor directory
RUN mkdir -p ${VENDOR_DIR}

# Expose Port
EXPOSE 2901 5947 801

# Copy & start config
COPY /script/start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]
