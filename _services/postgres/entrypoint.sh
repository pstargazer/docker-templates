

dumpdb() {
    # stopdb
    startdb
    # su postgres -c "pg_ctl start"
    # ARG 1 - middle dump name (onstart|onstop)
    middlename=$1
    local dumpname=$EXPORT_PATH\/${sequenceId}_bs_dump_${middlename}_$(date +%d-%h-%Y-%H:%M:%S).sql

    echo $middlename
    while ! /usr/lib/postgresql/16/bin/pg_isready; do
        # wait until db is up
        echo "not ready"
    done

    echo "DUMPDB: dump the database"
    local EXPORT_PATH=/opt/dumps/
    local sequenceId=20
    cd $EXPORT_PATH
    # get the dump of database

    FILENAME=$EXPORT_PATH\/${sequenceId}_bs_dump_${middlename}_$(date +%d-%h-%Y-%H:%M:%S).sql
    FILENAME_ed=$EXPORT_PATH\/${sequenceId}_bs_dump_${middlename}_$(date +%d-%h-%Y-%H:%M:%S)_ed.sql

    pg_dump \
            --file=$FILENAME \
            --schema=public \
            --create \
            --no-owner \
            --superuser=$PROCESS_USER \
            --username=$POSTGRES_USER \
            $POSTGRES_DATABASE
    # rewrite the CREATE SCHEMA with IF EXISTS
    # and exclude CREATE DATABASE due crashes
    # REMEMBER TO SET $POSTGRES_DB
    cat $FILENAME | awk '/CREATE SCHEMA / { sub(/CREATE SCHEMA /, "CREATE SCHEMA IF NOT EXISTS "); } 1'  | awk '! /^CREATE DATABASE/' > $FILENAME_ed

    chown 1000:users $EXPORT_PATH
    echo "DUMPDB: database dump complete"
    stopdb
}


# current process pid
dpid=$!
# wait for script to halt
# and backup the db dump
su "postgres" -c "postgres" & wait $dpid
