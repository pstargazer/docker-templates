
FROM postgres:17-bookworm AS base
LABEL maintainer=""

ARG POSTGRES_USER
ENV POSTGRES_USER=${POSTGRES_USER}
ENV PG_COLOR=always

ENV CONF_DIR=/etc/pgconf

# RUN groupadd --gid=999 postgres
# -D means no password
# RUN adduser -D ${POSTGRES_USER}
RUN adduser --disabled-password $POSTGRES_USER

# parent dir of datadir
# REMEMBER TO REDEFINE NAME IN docker-compose
VOLUME [ "/var/lib/postgresql/" ]
EXPOSE 5432

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD pg_isready -U ${POSTGRES_USER}
# ========================================
# =========DEVELOPMENT VARIANT============
FROM base AS development
# ENV MODE=development
# install util commands, and delete excess
RUN <<EOF
apt-get update
apt-get install -y
    procps
    lsof
apt clean
rm -rf /var/lib/apt/lists/*
EOF

COPY ./initdb.d /docker-entrypoint-initdb.d/
COPY --chown=${POSTGRES_USER} --chmod=700 ./conf_dev/ "${CONF_DIR}"
RUN chmod 750 $PGDATA
RUN chown $POSTGRES_USER:users $PGDATA
USER $POSTGRES_USER

# CMD ls -ld /etc/pgconf
# CMD echo $(whoami) && ls $PGDATA -dl
# CMD ls -l /var/lib/postgresql/data

CMD ["postgres", "--config_file=/etc/pgconf/postgresql.conf"]
# CMD postgres --config_file=/etc/pgconf/postgresql.conf
# CMD postgres
# ========================================
# =========PRODUCTION VARIANT=============
FROM base AS production
ENV MODE=prodiction

COPY ./conf_prod/ "${CONF_DIR}"
USER ${POSTGRES_USER}

CMD postgres --config-file=${CONF_DIR}
