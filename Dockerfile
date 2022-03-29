FROM ruby:3.1-alpine AS build-env

ARG APP_ROOT="/app"
ENV BUNDLE_APP_CONFIG="/app/.bundle"

RUN apk update && \
    apk upgrade && \
    apk add --update --no-cache build-base git postgresql-dev imagemagick nodejs yarn

RUN gem install bundler

RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT

COPY Gemfile Gemfile.lock package.json yarn.lock $APP_ROOT/

RUN bundle config --local deployment true && \
    bundle config --local path "vendor/bundle" && \
    bundle config --local without 'development test'

RUN bundle install --jobs 20 --retry 5
RUN yarn install --frozen-lockfile

COPY . .

RUN bundle exec rails assets:precompile

RUN mkdir -p tmp/pids
RUN rm -rf vendor/bundle/ruby/*/cache/ && find vendor/ -name "*.o" -delete && find vendor/ -name "*.c"


FROM ruby:3.1-alpine

ARG APP_ROOT="/app"
ENV BUNDLE_APP_CONFIG="/app/.bundle"

WORKDIR $APP_ROOT

RUN apk update && \
    apk upgrade && \
    apk add --update --no-cache build-base postgresql-dev imagemagick ffmpeg && \
    gem install bundler

COPY --from=build-env $APP_ROOT $APP_ROOT

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
