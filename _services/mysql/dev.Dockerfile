FROM mysql:latest

COPY ./initdb.d /docker-entrypoint-initdb.d
VOLUME [ "/var/lib/mysql/" ]
EXPOSE 3306
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD [ "mysql --user=$USER -e \"status\" " ]
