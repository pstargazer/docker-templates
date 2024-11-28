ARG USERNAME=docker
ARG USERGROUP=users

FROM node:22-alpine3.19 AS node

# ENV USERNAME docker
# ENV USERGROUP process
# path for entrypoint
ENV ENTRY_PREFIX /usr/bin/
# path for app
ENV CMD_PATH /app

FROM alpine:3.20


# Get NodeJS
COPY --from=node /usr/local/bin /usr/local/bin
# Get npm
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules

# copy system alpine conf (DNS settings, etc)
# COPY ./_docker/frontend/conf /etc/
# library prerequisite for node
RUN apk add libstdc++

# util
RUN apk add lsof

# prioritize ipv4 over ipv6,cause laravel runs v4
# not sure that neccessary
RUN echo net.ipv4.ip_forward=1 | tee -a /etc/sysctl.conf && sysctl -p

# WORKDIR "${CMD_PATH}"
# copy project
ADD --chown=${USERNAME}:${USERGROUP} --chmod=775 ./frontend/ ${CMD_PATH}
# copy app entrypoint
ADD --chown=users --chmod=775 _docker/frontend/entrypoint.sh ${ENTRY_PREFIX}/

EXPOSE 80 5173 443
ENTRYPOINT /bin/ash "${ENTRY_PREFIX}/entrypoint.sh"
