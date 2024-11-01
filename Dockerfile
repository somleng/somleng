# syntax = docker/dockerfile:1

# Define Ruby version
ARG RUBY_VERSION=3.3
FROM public.ecr.aws/docker/library/ruby:$RUBY_VERSION-alpine AS base

# Set working directory
WORKDIR /rails

# Configure environment variables
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test" \
    BUNDLE_FORCE_RUBY_PLATFORM="1" \
    RUBY_YJIT_ENABLE="true"

# Stage to download the gRPC health probe
FROM public.ecr.aws/docker/library/alpine:latest AS binaries

# Install packages to download the gRPC health probe
RUN apk add --no-cache wget curl jq

# Download and configure the gRPC health probe
RUN ARCH=$(uname -m) && \
    [ "$ARCH" = "x86_64" ] && ARCH="amd64" || ARCH="$ARCH" && \
    wget -q -O /usr/local/bin/grpc-health-probe \
      $(curl -s https://api.github.com/repos/grpc-ecosystem/grpc-health-probe/releases/latest \
      | jq -r ".assets[] | select(.name | test(\"linux-$ARCH\")) | .browser_download_url") && \
    chmod +x /usr/local/bin/grpc-health-probe

# Build stage
FROM base as build

# Install build packages and temporary dependencies
RUN apk add --no-cache --virtual .build-deps build-base git gcompat postgresql-dev nodejs yarn

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    find "${BUNDLE_PATH}" -name "*.o" -delete && \
    find "${BUNDLE_PATH}" -name "*.c" -delete

# Install Node.js packages and dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy and precompile application code
COPY . .
RUN bundle exec bootsnap precompile --gemfile && \
    SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Final production stage
FROM base

# Install only runtime dependencies
RUN apk add --no-cache postgresql-libs vips-dev ffmpeg

# Copy dependencies and application code from build stage
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails
COPY --from=binaries /usr/local/bin/grpc-health-probe /usr/local/bin

# Configure non-root user for secure execution
RUN addgroup -S -g 1000 rails && \
    adduser -u 1000 -D -G rails rails && \
    chown -R rails:rails db storage log tmp

USER rails
EXPOSE 3000

# Default command to start the server
CMD ["./bin/rails", "server"]
