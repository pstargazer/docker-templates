set -eu

prepare_firstrun() {
    # if env not exists
    if [ ! -f .env ]; then
        echo "creating new config"
        touch .env
        envsubst < .env.example | tee .env
    fi

    # check if APP_KEY IS SET
    if [ -z $(awk -F '=' '/^APP_KEY/{print $2}' ".env") ]; then
        php artisan key:generate
        # php artisan migrate
    else
        echo ""
        echo "Proceeding startup, APP_KEY is OK"
        echo ""
    fi
}

prepare() {
    # TODO: try jq at parsing jsons
    platform_check() {
        EXITCODE=$(composer check --quiet | echo $?)
        # return $EXITCODE
        echo $EXITCODE
    }

    grant_access() {
        echo "granting access on app code"
        # f for silent
        chown $USERNAME:$USERGROUP -fR .
        chmod 775 -fR .
    }

    grant_access
    checkExitCode=$(platform_check)
    if [ $checkExitCode != 0 ]; then
        printf "composer check exited with code: %s" "${checkExitCode}"
        exit 1;
    fi
    echo "composer check OK"

    composer update --quiet
    composer install --quiet
    echo "composer update && install OK"
    # dont even try that, it leads to lot of deprecation logs
    php artisan test # --ansi --drop-databases --env=".env.testing"
}

start_web() {
    php artisan serve &
    # only in laravel web mode
    npm run dev &
    # WS
    # php artisan reverb:start --debug &
    # queue worker
    # php artisan queue:listen &
    # CRON
    cd /var/log/ && busybox crond -f -l 0 -d 8 &
    # nginx
    nginx -g 'daemon off;' &
    wait -n
}

start_api() {
    php artisan serve &
    # WS
    # php artisan reverb:start --debug &
    # queue worker
    # php artisan queue:listen &
    # CRON
    cd /var/log/ && busybox crond -f -l 0 -d 8 &
    # nginx
    nginx -g 'daemon off;' &
    wait -n
}

# exit
cd $CMD_PATH

prepare_firstrun
prepare
start_api
