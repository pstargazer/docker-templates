
FROM postgres:latest as base
LABEL maintainer=""

ARG POSTGRES_USER=postgres
# ARG POSTGRES_DATABASE
# ARG POSTGRES_PASSWORD

ENV CONF_DIR=/etc/pgconf/

# COPY ./entrypoint.sh /tmp/
COPY ./initdb.d /docker-entrypoint-initdb.d/
# parent dir of datadir
# REMEMBER TO REDEFINE NAME IN docker-compose
VOLUME [ "/var/lib/postgresql/" ]
EXPOSE 5432
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD ["CMD-SHELL", "pg_isready -U $POSTGRES_USER} || exit 1"]
# ========================================
# =========DEVELOPMENT VARIANT============
FROM base as development
ENV MODE=development

# install util commands, and delete excess
RUN <<EOF
apt-get update
apt-get install -y
    procps
    lsof
apt clean
rm -rf /var/lib/apt/lists/*
EOF

COPY ./conf_dev/ "${CONF_DIR}"

# RUN mkdir /usr/bin/entrypoint.d
# WORKDIR /usr/bin/entrypoint.d/
# COPY --chmod=755 ./util_scripts.d/ .
# COPY --chmod=755 ./entrypoint.sh .

# ========================================
# =========PRODUCTION VARIANT=============
FROM base as production
ENV MODE=prodiction

COPY ./conf_prod/ "${CONF_DIR}"
USER ${POSTGRES_USER}
# ENTRYPOINT [ "/usr/bin/entrypoint.sh" ]
# ENTRYPOINT [ "postgres" ]
# append custom args
CMD postgres --config-file=${CONF_DIR}
