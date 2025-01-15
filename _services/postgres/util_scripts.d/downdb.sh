#!/bin/sh

psql \
    -v ON_ERROR_STOP=1 \
    -U "$POSTGRES_USER" <<-EOSQL
REVOKE ALL PRIVILEGES ON * FROM ${POSTGRES_USER};
EOSQL
