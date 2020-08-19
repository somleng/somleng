# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails", "6.0.2.1"

gem "aasm"
gem "after_commit_everywhere"
gem "aws-sdk-sqs"
gem "doorkeeper"
gem "dry-validation"
gem "enumerize"
gem "lograge"
gem "money-rails"
gem "okcomputer"
gem "pg"
gem "phony"
gem "phony_rails"
gem "puma"
gem "refile", github: "refile/refile", require: "refile/rails"
gem "refile-s3", github: "dwilkie/refile-s3"
gem "responders"
gem "sentry-raven"
gem "shoryuken"
gem "sinatra", github: "sinatra/sinatra"
gem "somleng-twilio_http_client", github: "somleng/somleng-twilio_http_client"
gem "torasup"
gem "validate_url", github: "perfectline/validates_url"
gem "webpacker"
gem "wisper", github: "krisleech/wisper"

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
  gem "wisper-rspec"
end
