FROM php:8.3-apache-bookworm

# Install system dependenciesdocker
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    libonig-dev \
    libxml2-dev \
    libicu-dev \
    libxslt-dev \
    libmcrypt-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        gd \
        pdo \
        pdo_mysql \
        mysqli \
        zip \
        mbstring \
        exif \
        intl \
        xml \
        bcmath \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy CI3 project into container (assumes current dir is your app root)
COPY . /var/www/html

# Set appropriate permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Set up Apache config for CI3 clean URLs
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html|' /etc/apache2/sites-available/000-default.conf
RUN echo '<Directory /var/www/html>\n\tOptions Indexes FollowSymLinks\n\tAllowOverride All\n\tRequire all granted\n</Directory>' >> /etc/apache2/apache2.conf

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
