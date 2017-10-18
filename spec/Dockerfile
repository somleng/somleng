FROM ruby:latest
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

RUN mkdir /usr/src/app
WORKDIR /usr/src/app

ADD Gemfile /usr/src/app/Gemfile
ADD Gemfile.lock /usr/src/app/Gemfile.lock
RUN bundle install
ADD . /usr/src/app

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
