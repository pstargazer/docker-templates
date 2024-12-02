#!/bin/ash
start-web() {
    php artisan serve &
    # only in laravel web mode
    npm run dev &
    # WS
    php artisan reverb:start --debug &
    # queue worker
    php artisan queue:listen &
    # CRON
    cd /var/log/ && busybox crond -f -l 0 -d 8 &
    # nginx
    nginx -g 'daemon off;' &
    wait -n
}

start-api() {
    php artisan serve &
    # WS
    php artisan reverb:start --debug &
    # queue worker
    php artisan queue:listen &
    # CRON
    cd /var/log/ && busybox crond -f -l 0 -d 8 &
    # nginx
    nginx -g 'daemon off;' &
    wait -n
}

start-api
