source 'https://rubygems.org'

ruby(File.read(".ruby-version").strip) if File.exist?(".ruby-version")

gem 'rails', '4.2.6'
gem 'pg'
gem "responders"
gem 'doorkeeper'
gem 'puma'
gem 'aasm'
gem 'phony_rails'
gem 'phony'

group :development, :test do
  gem 'pry'
  gem 'rspec-rails'
end

group :development do
  gem 'foreman'
end

group :test do
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
end

