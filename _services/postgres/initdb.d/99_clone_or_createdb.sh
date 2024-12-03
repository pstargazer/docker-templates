#!/bin/bash

#
# this script decidated to ensure that if database is not present it would be created,
# else it will be cloned in another db for testing purposes
#
set -e

if psql -lqt | cut -d \| -f 1 | grep -qw "${POSTGRES_DATABASE}"; then
    # database exists,cloning
    psql \
        -v ON_ERROR_STOP=1 \
        -U "${POSTGRES_USER}" <<-EOSQL
    REVOKE CONNECT ON DATABASE "${POSTGRES_DATABASE}" FROM PUBLIC;

    -- while connected to another DB - like the default maintenance DB "postgres"
    SELECT pg_terminate_backend(pid)
    FROM   pg_stat_activity
    WHERE  datname = '${POSTGRES_DATABASE}'         -- name of prospective template db
    AND    pid <>  pg_backend_pid();            -- don't kill your own session

    CREATE DATABASE "${POSTGRES_DATABASE}_test" WITH TEMPLATE "${POSTGRES_DATABASE}";

    GRANT CONNECT ON DATABASE "${POSTGRES_DATABASE}" TO PUBLIC;  -- only if they had it before
EOSQL
# NOTE: HEREDOC END SHOULD NOT BE PREPENDED WITH SPACES/TABS
else
    echo "    DATABASE DUMP DOES NOT EXISTS OR EMPTY, RUN YOUR MIGRATIONS AND PUT DUMP INTO initdb.d"
    psql \
        -v ON_ERROR_STOP=1 \
        -U $POSTGRES_USER <<-EOSQL
    CREATE DATABASE $POSTGRES_DATABASE;
EOSQL
fi
