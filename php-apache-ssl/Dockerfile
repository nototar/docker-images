FROM php:8.1-apache

ENV TZ=Asia/Jakarta

RUN apt-get update 
RUN apt-get upgrade -y

RUN apt-get install -y git curl zip vim unzip nmap wget ffmpeg net-tools iputils-ping

RUN docker-php-ext-install opcache
RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/php-opocache-cfg.ini

RUN apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev
# utk php 7.2/7.3 -----------------------------------------------------------------
# RUN docker-php-ext-configure gd --with-freetype-dir --with-jpeg-dir=/usr/include/
# ---------------------------------------------------------------------------------
# utk php 7.4/8.1 -----------------------------------------------------------------------
RUN docker-php-ext-configure gd --with-jpeg=/usr/include/ --with-freetype=/usr/include/
# ---------------------------------------------------------------------------------------
RUN docker-php-ext-install gd

RUN apt-get install -y libpq-dev
RUN docker-php-ext-install pdo pdo_pgsql pgsql
RUN docker-php-ext-install pdo_mysql

RUN apt-get install libldb-dev libldap2-dev -y
RUN docker-php-ext-install ldap

RUN apt-get install -y libicu-dev
RUN docker-php-ext-install intl

RUN apt-get install -y libmagickwand-dev --no-install-recommends
RUN pecl install imagick
RUN docker-php-ext-enable imagick

RUN apt-get install -y libmemcached-dev
RUN pecl install memcached
RUN docker-php-ext-enable memcached

RUN docker-php-ext-install mysqli
RUN docker-php-ext-enable mysqli

RUN apt-get install -y libzip-dev
# utk php 7.3 ----------------------------------
# RUN docker-php-ext-configure zip --with-libzip
# ----------------------------------------------
RUN docker-php-ext-install zip

RUN apt-get install -y libgmp-dev
RUN docker-php-ext-install gmp

RUN apt-get install -y libmcrypt-dev
RUN pecl install mcrypt
RUN docker-php-ext-enable mcrypt

# hanya untuk php 7.2 ------------------------------
# RUN apt-get install -y libedit-dev libreadline-dev
# RUN docker-php-ext-install readline
# --------------------------------------------------

RUN docker-php-ext-install gettext

RUN a2enmod rewrite

RUN a2enmod ssl

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

ENV PHP_TIMEZONE=Asia/Jakarta
ENV PHP_MEMORY_LIMIT="512M"
ENV PHP_MAX_UPLOAD="50M"
ENV PHP_MAX_FILE_UPLOAD="200"
ENV PHP_MAX_POST="100M"
ENV PHP_DISPLAY_ERRORS="On"
ENV PHP_DISPLAY_STARTUP_ERRORS="On"
ENV PHP_ERROR_REPORTING="E_COMPILE_ERROR\|E_RECOVERABLE_ERROR\|E_ERROR\|E_CORE_ERROR"
ENV PHP_CGI_FIX_PATHINFO=0
ENV PHP_MAX_EXECUTION_TIME=60
ENV PHP_SESSION_MAXLIFETIME=3600

# replace some of configuration on php.ini
RUN sed -i 's!;*date.timezone.*!date.timezone = ${PHP_TIMEZONE}!g' $PHP_INI_DIR/php.ini
RUN sed -i "s|display_errors\s*=\s*Off|display_errors = ${PHP_DISPLAY_ERRORS}|i" $PHP_INI_DIR/php.ini
RUN sed -i "s|display_startup_errors\s*=\s*Off|display_startup_errors = ${PHP_DISPLAY_STARTUP_ERRORS}|i" $PHP_INI_DIR/php.ini
RUN sed -i "s|error_reporting\s*=\s*E_ALL & ~E_DEPRECATED & ~E_STRICT|error_reporting = ${PHP_ERROR_REPORTING}|i" $PHP_INI_DIR/php.ini
RUN sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" $PHP_INI_DIR/php.ini
RUN sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${PHP_MAX_UPLOAD}|i" $PHP_INI_DIR/php.ini
RUN sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" $PHP_INI_DIR/php.ini
RUN sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" $PHP_INI_DIR/php.ini
RUN sed -i "s|;*cgi.fix_pathinfo=.*|cgi.fix_pathinfo= ${PHP_CGI_FIX_PATHINFO}|i" $PHP_INI_DIR/php.ini
RUN sed -i "s|expose_php.*|expose_php = Off|i" $PHP_INI_DIR/php.ini
RUN sed -i 's!max_execution_time.*!max_execution_time = ${PHP_MAX_EXECUTION_TIME}!g' $PHP_INI_DIR/php.ini
RUN sed -i 's!session.gc_maxlifetime.*!session.gc_maxlifetime = ${PHP_SESSION_MAXLIFETIME}!g' $PHP_INI_DIR/php.ini

ENV APACHE_DOCUMENT_ROOT=/var/www/public
ENV APACHE_CERT_FILE=/var/www/star_mkri_id.crt
ENV APACHE_CERT_KEY=/var/www/star_mkri_id.key
ENV APACHE_CERT_ROOT=/var/www/DigiCertCA.crt

RUN rm -f /etc/apache2/sites-enabled/*
COPY ./default.conf /etc/apache2/sites-enabled/

RUN sed -ri -e 's!ServerTokens OS!ServerTokens Prod!g' /etc/apache2/conf-enabled/*.conf
RUN sed -ri -e 's!ServerSignature On!ServerSignature Off!g' /etc/apache2/conf-enabled/*.conf

RUN mkdir /var/www/public
RUN touch /var/www/public/index.php
RUN echo '<?php phpinfo(); ?>' > /var/www/public/index.php

RUN echo "Mutex posixsem" >> /etc/apache2/apache2.conf
RUN sed -i '/Options Indexes FollowSymLinks/ {n; s/AllowOverride None/AllowOverride All/}' /etc/apache2/apache2.conf
RUN sed -i 's!Options Indexes FollowSymLinks!Options -Indexes +FollowSymLinks!g' /etc/apache2/apache2.conf
RUN sed -i 's!"%h!"%h \\"%{X-Forwarded-For}i\\"!g' /etc/apache2/apache2.conf

WORKDIR /var/www
