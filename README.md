# Twireapi /twi-reap-i/ (Twilio Rest API)

[![Build Status](https://travis-ci.org/dwilkie/twilreapi.svg?branch=master)](https://travis-ci.org/dwilkie/twilreapi)

Twireapi is an Open Source implementation of [Twilio's REST API](https://www.twilio.com/docs/api/rest) written in Rails. You can use Twireapi to swap out Twilio from your application and enqueue calls, send SMS etc using [Adhearsion](http://adhearsion.com/), [FreeSwitch](https://freeswitch.org/) or [Asterisk](http://www.asterisk.org/).

## Installation

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Note check the output of `bin/setup` and note down the Account SID and Auth Token. To reseed the database run `bin/rails db:seed`

## Running Locally

Start the web server using foreman. Note this will read the environment variables from [.env](https://github.com/dwilkie/twilreapi-sidekiq/blob/master/.env)

```
$ bundle exec foreman start web
```

## Deployment

To get started quickly we recommend deploying to Heroku.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

After deployment seed the database to generate an `Account SID` and `Auth Token` and note down the values.

```
  $ heroku run rake db:seed
```

You can seed the database multiple times without generating multiple accounts.

## Supported Resources

### Calls

#### Make a Call

```
$ curl -XPOST https://your-app-name.herokuapp.com/api/2010-04-01/Accounts/{AccountSID}/Calls.json \
    -d "Url=http://demo.twilio.com/docs/voice.xml" \
    -d "To=%2B85512345678" \
    -d "From=%2B85512345679" \
    -u 'your_account_sid:your_auth_token'
```

#### Retrieve a Call

```
$ curl https://your-app-name.herokuapp.com/api/2010-04-01/Accounts/{AccountSID}/Calls/{CallSID}.json \
    -u 'your_account_sid:your_auth_token'
```
