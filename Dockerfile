FROM php:5.5-apache
RUN a2enmod rewrite

# Add www-data user
RUN usermod -u 33 www-data

RUN apt-get update
RUN apt-get install -y \
	vim \
	nano \
	ruby \
	ruby-full \
	git \
	net-tools \
	nodejs \
	npm \
	curl

# Install the PHP extensions we need (git for Composer, mysql-client for mysqldump)
RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev libpq-dev git mysql-client-5.5 wget drush \
	&& rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd mbstring opcache mysql mysqli pdo pdo_mysql pdo_pgsql zip

# Set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php

WORKDIR /root

# Configure PHP memory limit
RUN {  \
		echo "memory_limit = 256M"; \
	} >> /usr/local/etc/php/php.ini

RUN \
    apt-get update && \
    apt-get install libldap2-dev -y && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap

# Add composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Add user to group for volume sharing
RUN groupadd 1000
RUN usermod -a -G 1000 www-data
RUN usermod -a -G staff www-data

RUN a2enmod rewrite

WORKDIR /var/www/html