FROM nginx:1.19.1-alpine

# Argument list
ARG PHP_VERSION=7.4
ARG ALPINE_VERSION=3.9
ARG CONFIG_DIR=/config
ARG WORK_DIR=/var/www/
ARG LARAVEL_DIR=/src/

# Instal requirement
RUN apk --update --no-cache add ca-certificates supervisor bash 
ADD https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/community" >> /etc/apk/repositories && \
    echo "https://dl.bintray.com/php-alpine/v${ALPINE_VERSION}/php-${PHP_VERSION}" >> /etc/apk/repositories && \
    apk add --no-cache --update \
    php \
    php-fpm \
    argon2-dev \
    libargon2 \
    autoconf \
    automake \
    make \
    php-openssl \
    php-pdo \
    php-pdo_mysql \
    php-mbstring \
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
    php-redis \
    php-xml \
    php-opcache && \
    ln -s /usr/bin/php7 /usr/bin/php

# Remove Cache
RUN rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apk/*

# Config Nginx
RUN rm -rf /etc/nginx/nginx.conf && \
    rm -rf /etc/nginx/conf.d/default.conf && \
    mkdir -p /etc/nginx/sites-available/ && \
    mkdir -p /etc/nginx/sites-enabled/ && \
    ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf
COPY ${CONFIG_DIR}/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ${CONFIG_DIR}/nginx/conf.d/site.conf /etc/nginx/conf.d/site.conf
COPY ${CONFIG_DIR}/nginx/conf.d/site.conf /etc/nginx/sites-available/default.conf

# Config PHP
RUN rm -rf /etc/php7/php.ini && \
    rm -rf /etc/php7/php-fpm.d/www.conf
COPY ${CONFIG_DIR}/php/php.ini /etc/php7/php.ini
COPY ${CONFIG_DIR}/php/www.conf /etc/php7/php-fpm.d/www.conf

# Config supervisord
COPY ${CONFIG_DIR}/supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Make working directory and vendor directory
RUN mkdir -p ${WORK_DIR}

# Set working directory
WORKDIR ${WORK_DIR}

# Add user for laravel application
#RUN adduser -D -g 'nobody' www
RUN addgroup -g 1000 -S www && \
    adduser -S -D -H -u 1000 -h ${WORK_DIR} -s /bin/bash -G www -g www www

# Copy existing application directory permissions
COPY --chown=www:www ${LARAVEL_DIR} ${WORK_DIR}

# Set File & Folder permission
RUN chmod -R 0644 ${WORK_DIR} && \
    find ${WORK_DIR} -type d -print0 | xargs -0 chmod 0755

# Expose Port 80 & 9000
EXPOSE 80 9000

# Copy & start config
COPY /script/start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]