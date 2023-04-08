FROM alpine:3.17.1 as base
RUN sed -i -e 's|^\(.*\)v[0-9.]*/main|@edge-testing \1edge/testing\n&|' /etc/apk/repositories
RUN sed -i -e 's|^\(.*\)v[0-9.]*/main|@edge-community \1edge/community\n&|' /etc/apk/repositories

RUN apk add --no-cache --virtual ruby-dependencies curl libcurl libffi gdbm \
      icu ncurses readline openssl libxml2 libxslt yaml zlib \
      imagemagick \
      tzdata \
      sqlite sqlite-libs postgresql-client libpq \
      \
      ruby-dev ruby-bundler \
      \
 && apk add --no-cache \
      yarn \
      esbuild@edge-community \
      caddy nss-tools \
      supercronic \
      goreman@edge-testing

ARG APP_UID=1000
ENV APP_UID=$APP_UID
RUN adduser -D -g app -u $APP_UID app

ENV RUBY_VERSION=3.1.3 \
    APP_PATH=/srv/app

###
FROM base as ruby

RUN apk add --no-cache --virtual build-dependencies build-base gcc wget git \
 && apk add --no-cache --virtual ruby-build-dependencies build-dependencies \
      autoconf bison curl-dev libffi-dev gdbm-dev icu-dev ncurses-dev \
      readline-dev openssl-dev libxml2-dev libxslt-dev yaml-dev zlib-dev git \
      sqlite-dev postgresql14-dev

ENV RY_PREFIX=/usr/local
RUN mkdir $RY_PREFIX/lib/ry

RUN mkdir $APP_PATH \
 && chown app $APP_PATH

USER app

ENV GEM_HOME="/home/app/.gem/ruby/$RUBY_VERSION" \
    PATH="/home/app/.gem/ruby/$RUBY_VERSION/bin:$RY_PREFIX/lib/ry/current/bin:$PATH"
RUN gem install bundler

WORKDIR $APP_PATH

###
FROM ruby as build

# Install Gems
COPY --chown=app Gemfile Gemfile.lock $APP_PATH/
# Set bundler local config in /app/.bundle folder
RUN bundle config --local jobs 2 \
 # Do not allow changes in Gemfile.lock
 && bundle config --local frozen 'true' \
 # Install gems in specified path
 && bundle config --local path 'vendor/bundle' \
 # Do not install development gems
 && bundle config --local without 'development,test' \
 && bundle install

# Install js dependencies
COPY --chown=app package.json yarn.lock $APP_PATH/
RUN yarn install --check-files

# Copy minimal content for assets precompilation
COPY --chown=app app/api $APP_PATH/app/api
COPY --chown=app app/assets $APP_PATH/app/assets
COPY --chown=app app/javascript $APP_PATH/app/javascript
COPY --chown=app bin $APP_PATH/bin
COPY --chown=app config $APP_PATH/config
COPY --chown=app Rakefile \
     $APP_PATH/

RUN bundle exec rake RAILS_ENV=production DATABASE_URL=sqlite3:///:memory: SECRET_KEY_BASE=dummy assets:clean assets:precompile \
 && bundle exec rake RAILS_ENV=production tmp:cache:clear \
 && rm -f vendor/bundle/ruby/*/cache/*.gem \
 && find vendor/bundle/ruby/*/gems/ -name "*.c" -delete \
 && find vendor/bundle/ruby/*/gems/ -name "*.o" -delete

# Copy full application
COPY --chown=app . $APP_PATH

###
FROM build as test

RUN bundle config --local without 'development' \
 && bundle install
RUN yarn install --production=false

###
FROM ruby as local

USER root
RUN apk add --no-cache sudo coreutils procps graphviz ttf-liberation \
  font-noto-symbols font-noto-emoji font-noto
RUN echo "app ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER app

###
FROM base

COPY --from=build /usr/local/lib/ry /usr/local/lib/ry
COPY --from=build /home/app/.gem /home/app/.gem
COPY --from=build $APP_PATH $APP_PATH

USER app
ENV PATH="/home/app/.gem/ruby/$RUBY_VERSION/bin:/usr/local/lib/ry/current/bin:$PATH"

WORKDIR $APP_PATH

EXPOSE 3000
CMD ["/srv/app/entrypoint.sh"]
