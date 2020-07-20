# Dockerfile NangJogja
# Repository  : PHP
# version     : 7.4.x FPM

FROM php:7.4-fpm

LABEL maintainer="master.gloqi@gmail.com"
LABEL description="This image is used to setup NangJogja application"
LABEL version="1.0"

# Install dependencies
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    build-essential \
    libc-dev \
    libjpeg62-turbo-dev \
    libjpeg-dev \
    libpng-dev \
    libzip-dev \
    libonig-dev \
    libfreetype6-dev \
    jpegoptim optipng pngquant gifsicle \
    locales \
    zip \
    unzip \
    vim \
    curl \
    bash \
    git \
    nodejs \
    npm \
    rsync

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Configure php extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# Install extensions
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    mbstring \
    zip \
    exif \
    pcntl \
    bcmath \
    opcache \
    gd \
    calendar 

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www

# Add user for laravel application
RUN groupadd -g 1000 www && useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
#COPY . /var/www

# Copy existing application directory permissions
#COPY --chown=www:www . /var/www

# Change current user to www
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
