# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails", "~> 7.0.7"

gem "administrate"
gem "administrate-field-active_storage"
gem "image_processing"

# Use Redis adapter to run Action Cable in production
gem "redis"

gem "aasm"
gem "active_storage_validations"
gem "addressable"
gem "after_commit_everywhere"
gem "aws-sdk-cloudwatch"
gem "aws-sdk-ec2"
gem "aws-sdk-rails"
gem "aws-sdk-s3"
gem "aws-sdk-sesv2"
gem "aws-sdk-sqs"
gem "bootstrap-email", "1.4.0"
gem "connection_pool"
gem "country_select"
gem "cssbundling-rails"
gem "cursor_paginator"
gem "devise"
gem "devise_invitable"
gem "devise-two-factor"
gem "doorkeeper"
gem "dry-validation"
gem "enumerize"
gem "faraday"
gem "haikunator"
gem "http"
gem "jsbundling-rails"
gem "jsonapi-serializer"
gem "jwt"
gem "kaminari"
gem "lograge"
gem "money"
gem "okcomputer"
gem "pg"
gem "pghero"
gem "pg_query"
gem "phony"
gem "puma"
gem "pundit"
gem "recaptcha"
gem "redis-namespace"
gem "redis-objects"
gem "responders"
gem "rqrcode"
gem "sassc-rails"
gem "sentry-rails"
gem "sentry-ruby"
gem "shoryuken"
gem "show_for"
gem "simple_form"
gem "skylight"
gem "smstools"
gem "stimulus-rails"
gem "turbo-rails"
gem "twilio-ruby"
gem "tzinfo-data"
gem "with_advisory_lock"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

group :development, :test do
  gem "pry"
  gem "rspec_api_documentation", github: "zipmark/rspec_api_documentation"
  gem "rspec-rails"
  gem "rubocop"
  gem "rubocop-performance"
  gem "rubocop-rails"
  gem "rubocop-rspec"
end

group :development do
  gem "foreman", require: false
  gem "squasher", require: false
end

group :test do
  gem "capybara"
  gem "email_spec"
  gem "factory_bot_rails"
  gem "mock_redis"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem "simplecov-lcov", require: false
  gem "webmock"
end
