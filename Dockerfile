# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .tool-versions
ARG RUBY_VERSION=3.4
FROM public.ecr.aws/docker/library/ruby:$RUBY_VERSION-alpine AS base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test" \
    BUNDLE_FORCE_RUBY_PLATFORM="1"

FROM public.ecr.aws/docker/library/alpine:latest AS binaries

# Install packages needed to build binaries
RUN apk update --no-cache && \
    apk upgrade --no-cache && \
    apk add --update --no-cache wget curl jq

RUN [[ "$(arch)" = "aarch64" ]] && arch="arm64" || arch="$(arch)" && \
  curl -s https://api.github.com/repos/grpc-ecosystem/grpc-health-probe/releases/latest \
  | jq ".assets[].browser_download_url" \
  | grep "grpc_health_probe-linux-$arch" \
  | tr -d '"' \
  | wget -qi - -O grpc-health-probe && \
  chmod +x grpc-health-probe && \
  mv grpc-health-probe /usr/local/bin

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems
RUN apk update --no-cache && \
    apk upgrade --no-cache && \
    apk add --update --no-cache build-base git gcompat postgresql-dev nodejs yarn yaml-dev libffi-dev

# Install application gems
COPY Gemfile Gemfile.lock ./

RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    find "${BUNDLE_PATH}" -name "*.o" -delete && find "${BUNDLE_PATH}" -name "*.c" -delete && \
    mkdir -p tmp/pids && \
    mkdir -p storage && \
    bundle exec bootsnap precompile --gemfile

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Final stage for app image
FROM base

# Install packages needed for deployment
RUN apk update --no-cache && \
    apk upgrade --no-cache && \
    apk add --update --no-cache build-base gcompat postgresql-dev vips-dev ffmpeg

# Copy built artifacts: gems, application
# Note the trailing slashes are important here
COPY --from=build --link /usr/local/bundle/ /usr/local/bundle/
COPY --from=build --link /rails/ /rails/
COPY --from=binaries --link /usr/local/bin/grpc-health-probe /usr/local/bin/

# Run and own only the runtime files as a non-root user for security
RUN addgroup -S -g 1000 rails && \
    adduser -u 1000 -D -G rails rails && \
    chown -R rails:rails db storage log tmp

USER 1000:1000
ENV RUBY_YJIT_ENABLE=true

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
