
FROM postgres:17-bookworm AS base
LABEL maintainer=""

ARG POSTGRES_USER
ENV POSTGRES_USER=${POSTGRES_USER}
ENV PG_COLOR=always

ENV _DOMAIN=dflat
ENV _PG_CONF=/etc/pgconf

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
# ======================================================================
# =========DEVELOPMENT VARIANT==========================================
FROM base AS development
# ENV MODE=development
# install util commands, and delete excess
RUN <<EOF
apt-get update
apt-get install -y \
    procps          \
    lsof             \
    gettext           \
    openssl
apt clean
rm -rf /var/lib/apt/lists/*
EOF

# generating ssl cert
WORKDIR /etc/ssl
COPY ./certs .
# RUN chmod 600 *.crt server.key
# RUN <<EOF
# openssl req -new -newkey rsa:4096 -days 365 -nodes -x509    \
#     -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.server.com"    \
#     -keyout server.key  -out server.cert
# EOF
RUN update-ca-certificates

RUN <<EOF
chmod 600 certs/root.pem server.key certs/server.crt
chown ${POSTGRES_USER}:postgres certs/root.pem server.key certs/server.crt
EOF

COPY ./initdb.d /docker-entrypoint-initdb.d/
RUN chmod 750 $PGDATA
RUN chown $POSTGRES_USER:users $PGDATA

COPY --chown=${POSTGRES_USER} --chmod=770 ./conf_dev/ /tmp/pgconf-old/
WORKDIR /tmp/pgconf-old/
RUN <<EOF
mkdir ${_PG_CONF}
envsubst < ./postgresql.conf | tee $_PG_CONF/postgresql.conf
envsubst < ./pg_hba.conf | tee $_PG_CONF/pg_hba.conf
envsubst < ./pg_ident.conf | tee $_PG_CONF/pg_ident.conf
EOF

WORKDIR /etc/pgconf
RUN <<EOF
chmod 775 *.conf
chown postgres:postgres *.conf
EOF

USER $POSTGRES_USER

CMD ["postgres", "--config_file=/etc/pgconf/postgresql.conf"]
# ======================================================================
# =========PRODUCTION VARIANT===========================================
FROM base AS production
ENV MODE=prodiction

COPY ./conf_prod/ "${_PG_CONF}"
USER ${POSTGRES_USER}

CMD postgres --config-file=${_PG_CONF}
