###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM php:8.2-apache AS development

# Set working directory
WORKDIR /var/www/html

# Copy composer files to the container image
COPY composer.json composer.lock ./

# Install PHP dependencies using Composer
RUN apt-get update && apt-get install -y zip unzip && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer install

# Copy the rest of the application code
COPY . .

###################
# BUILD FOR PRODUCTION
###################

FROM php:8.2-apache AS build

WORKDIR /var/www/html

# Copy composer files to the container image
COPY composer.json composer.lock ./

# Install PHP dependencies using Composer
RUN apt-get update && apt-get install -y zip unzip && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer install

COPY --from=development /var/www/html/vendor /var/www/html/vendor

# Set up production environment
ENV APP_ENV=production

# Build your Laravel application
RUN php artisan optimize

###################
# PRODUCTION
###################

FROM php:8.2-apache AS production

WORKDIR /var/www/html

# Copy the bundled code from the build stage to the production image
COPY --from=build /var/www/html /var/www/html

# Start the server using the production build
CMD ["php", "artisan", "serve", "--host=0.0.0.0"]
