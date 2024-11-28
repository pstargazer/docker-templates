set -e

psql \
    -v ON_ERROR_STOP=1 \
    -U $POSTGRES_USER \
    -d $dbname  <<-EOSQL
\$\$
REVOKE CONNECT ON DATABASE $POSTGRES_DATABASE FROM PUBLIC;

-- while connected to another DB - like the default maintenance DB "postgres"
SELECT pg_terminate_backend(pid)
FROM   pg_stat_activity
WHERE  datname = $POSTGRES_DATABASE                    -- name of prospective template db
AND    pid <>  pg_backend_pid();            -- don't kill your own session

CREATE DATABASE $POSTGRES_DATABASE'_test' TEMPLATE $POSTGRES_DATABASE;

GRANT CONNECT ON DATABASE $POSTGRES_DATABASE TO PUBLIC;  -- only if they had it before
\$\$
EOSQL
