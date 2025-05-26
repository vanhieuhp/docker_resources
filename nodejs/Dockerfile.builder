FROM node:current-alpine3.19

WORKDIR /app

# RUN apk --no-cache add \
#     g++ make python git \
#     && yarn global add node-gyp \
#     && rm -rf /var/cache/apk/*

RUN yarn global add node-gyp

ONBUILD ADD package.json yarn.lock /app/
ONBUILD ADD yarn --pure-lockfile