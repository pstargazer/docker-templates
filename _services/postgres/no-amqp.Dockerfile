
FROM postgres:latest AS base
LABEL maintainer=""

# Make sure to set in .env file beside this file
# and include in docker compose
# POSTGRES_USER=postgres
# POSTGRES_DATABASE
# POSTGRES_PASSWORD

ENV CONF_DIR=/etc/pgconf/

# COPY ./entrypoint.sh /tmp/
COPY ./initdb.d /docker-entrypoint-initdb.d/

# REMEMBER TO REDEFINE NAME IN docker-compose
VOLUME [ "/var/lib/postgresql/" ]
EXPOSE 5432

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD ["pg_isready", "-U", "postgres"]
# ========================================
# =========DEVELOPMENT VARIANT============
FROM base AS development
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
FROM base AS production
ENV MODE=prodiction

COPY ./conf_prod/ "${CONF_DIR}"
USER ${POSTGRES_USER}

CMD postgres --config-file=${CONF_DIR}
