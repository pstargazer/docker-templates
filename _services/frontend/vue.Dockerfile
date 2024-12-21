ARG USERNAME=docker
ARG USERGROUP=users

FROM node:22-alpine3.19 AS node

FROM alpine:3.20 AS base
# Get NodeJS
COPY --from=node /usr/local/bin /usr/local/bin
# Get npm
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
# library prerequisite for node
RUN apk add libstdc++

FROM base AS dev
# util
RUN apk add lsof

# TODO: delete if everything alright
# prioritize ipv4 over ipv6,cause laravel runs v4
# not sure that neccessary
# RUN echo net.ipv4.ip_forward=1 | tee -a /etc/sysctl.conf && sysctl -p

# copy project
RUN mkdir /app
WORKDIR /app
ADD --chown=${USERNAME}:${USERGROUP} --chmod=775 ./app_frontend/ .
VOLUME ["/app/node_modules"]
RUN npm install

EXPOSE 80 5173 443

CMD npm run dev
