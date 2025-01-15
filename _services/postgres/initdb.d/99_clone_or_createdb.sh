#!/bin/bash

#
# this script decidated to ensure that if database is not present it would be created,
# else it will be cloned in another db for testing purposes
#
set -e

tablename() {
    psql -lqt | cut -d '|' -f 1 | grep -o "${PROJECT_DATABASE}"
}

table=$(tablename)
# exit
if [ $table == $PROJECT_DATABASE ]; then
    # database exists,cloning
    psql \
        -v ON_ERROR_STOP=1 \
        -U "$POSTGRES_USER" <<-EOSQL
    REVOKE CONNECT ON DATABASE "${PROJECT_DATABASE}" FROM PUBLIC;

    CREATE DATABASE "${PROJECT_DATABASE}_test" WITH TEMPLATE "${PROJECT_DATABASE}";

    GRANT CONNECT ON DATABASE "${PROJECT_DATABASE}" TO PUBLIC;  -- only if they had it before
    GRANT CONNECT ON DATABASE "${PROJECT_DATABASE}_test" TO PUBLIC;  -- only if they had it before

EOSQL
# NOTE: HEREDOC END SHOULD NOT BE PREPENDED WITH SPACES/TABS
else
    echo "    DATABASE DUMP DOES NOT EXISTS OR EMPTY, RUN YOUR MIGRATIONS AND PUT DUMP INTO initdb.d"
    createdb $PROJECT_DATABASE
    createdb ${PROJECT_DATABASE}_test
fi
