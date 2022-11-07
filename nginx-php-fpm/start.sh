#!/start.sh
set -e

php-fpm &
nginx -g 'daemon off;'