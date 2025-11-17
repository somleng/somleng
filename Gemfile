# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails", "~> 8.1.1"

# For Administrate
gem "administrate", github: "thoughtbot/administrate"
gem "administrate-field-active_storage"
gem "image_processing"

gem "aasm"
gem "active_storage_validations"
gem "addressable"
gem "anycable-rails"
gem "after_commit_everywhere"
gem "aws-actionmailer-ses"
gem "aws-sdk-cloudwatch"
gem "aws-sdk-ec2"
gem "aws-sdk-polly"
gem "aws-sdk-rails"
gem "aws-sdk-s3"
gem "aws-sdk-sesv2"
gem "aws-sdk-sqs"
gem "bootstrap-email", "1.7.0"
gem "connection_pool"
gem "country_select"
gem "cssbundling-rails"
gem "cursor_paginator"
gem "csv"
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
gem "money-rails"
gem "okcomputer"
gem "openssl"
gem "pg"
gem "pghero"
gem "pg_query"
gem "phony"
gem "propshaft"
gem "puma"
gem "pundit"
gem "recaptcha"
gem "redis"
gem "responders"
gem "rqrcode"
gem "sentry-rails"
gem "sentry-ruby"
gem "shoryuken"
gem "show_for"
gem "simple_form"
gem "skylight"
gem "smstools"
gem "stimulus-rails"
gem "tts_voices", github: "somleng/tts_voices"
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
end

group :development do
  gem "foreman", require: false
  gem "squasher", require: false
  gem "rubocop-capybara", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rubocop-rspec", require: false
end

group :test do
  gem "capybara"
  gem "email_spec"
  gem "factory_bot_rails"
  gem "mock_redis"
  gem "selenium-webdriver"
  gem "simplecov", require: false
  gem "simplecov-lcov", require: false
  gem "webmock"
end
