# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails", "6.0.2.1"

gem "aasm"
gem "after_commit_everywhere"
gem "aws-sdk-s3"
gem "aws-sdk-sqs"
gem "doorkeeper"
gem "dry-validation"
gem "enumerize"
gem "lograge"
gem "okcomputer"
gem "pg"
gem "phony"
gem "puma"
gem "responders"
gem "sentry-raven"
gem "shoryuken"
gem "torasup"
gem "tzinfo-data"
gem "webpacker"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

group :development, :test do
  gem "pry"
  gem "rspec_api_documentation", github: "samnang/rspec_api_documentation"
  gem "rspec-rails"
  gem "rubocop"
  gem "rubocop-rspec"
end

group :development do
  gem "spring"
  gem "spring-commands-rspec"
  gem "squasher", require: false
end

group :test do
  gem "factory_bot_rails"
  gem "shoulda-matchers", github: "thoughtbot/shoulda-matchers"
  gem "simplecov", require: false
  gem "simplecov-lcov", require: false
  gem "webmock"
end
