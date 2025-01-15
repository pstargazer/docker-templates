#!/bin/sh

sequenceId=20
middlename=manual
schema=$1

if [ -z $schema ]; then
    schema="public"
    echo "NOTE: specify which schema to dump, revert to '${schema}'"
fi

pg_dump \
	--file=$EXPORT_PATH\/${sequenceId}_${PROJECT_DATABASE}_dump_${middlename}_$(date +%d-%h-%Y-%H:%M:%S).sql \
	--schema=${schema} \
	--no-owner \
	--if-exists --clean \
	--username=${POSTGRES_USER} \
	$PROJECT_DATABASE
