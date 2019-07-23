FROM php:7.1-fpm

LABEL maintainer="Derek Myers <arcticpro@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive

# Install packages
RUN apt-get update && apt-get install -y \
    build-essential \
    default-mysql-client \
    libpng-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libxml2-dev \
    libmemcached-dev \
    zlib1g-dev \
    libicu-dev \
    libbz2-dev \
    libmagickwand-dev \
    libmagickcore-dev \
    locales \
    zip \
    git \
    jpegoptim \
    optipng \
    pngquant \
    && pecl channel-update pecl.php.net

# Setup locale
RUN echo en_US.UTF-8 UTF-8 > /etc/locale.gen && locale-gen

# Install PECL extensions
RUN pecl install -o -f redis \
    xdebug \
    memcached \
    imagick \
    mailparse

# Enable PHP extensions
RUN docker-php-ext-enable redis \
    xdebug \
    memcached \
    imagick \
    mailparse

# Configure PHP extensions
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/

# Install PHP extensions
RUN docker-php-ext-install mysqli \
    mbstring \
    pdo \
    pdo_mysql \
    mcrypt \
    pcntl \
    gd \
    zip \
    soap \
    bz2 \
    exif \
    bcmath

# Update PHP config
RUN echo "max_execution_time=300" > $PHP_INI_DIR/conf.d/max-execution-time.ini && \
    echo "request_terminate_timeout=300" > $PHP_INI_DIR/conf.d/max-execution-time.ini && \
    echo "display_errors=stderr" > $PHP_INI_DIR/conf.d/display-errors.ini && \
    echo "expose_php=0" > $PHP_INI_DIR/conf.d/path-info.ini

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="./vendor/bin:$PATH"

# Clear caches
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

# Allow container to write on host
RUN usermod -u 1000 www-data

# Setup working directory
WORKDIR /var/www/html

CMD ["php-fpm"]

EXPOSE 9000
