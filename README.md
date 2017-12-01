# Twilreapi /twil-reap-i/ (Twilio Rest API)

[![Build Status](https://travis-ci.org/somleng/twilreapi.svg?branch=master)](https://travis-ci.org/somleng/twilreapi)
[![Test Coverage](https://api.codeclimate.com/v1/badges/1f6fa565944f2311832d/test_coverage)](https://codeclimate.com/github/somleng/twilreapi/test_coverage)
[![Maintainability](https://api.codeclimate.com/v1/badges/1f6fa565944f2311832d/maintainability)](https://codeclimate.com/github/somleng/twilreapi/maintainability)

Twilreapi is an Open Source implementation of [Twilio's REST API](https://www.twilio.com/docs/api/rest) written in Rails. You can use Twilreapi as a drop-in replacement for Twilio and enqueue calls, send SMS etc.

## Installation

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Check the output of `bin/setup` and note down the Account SID and Auth Token.

### Seeding the Database

To seed the database run `./bin/rails db:seed`. To create an admin account specify the admin account permissions with `ADMIN_ACCOUNT_PERMISSIONS`. E.g.

```
$ ADMIN_ACCOUNT_PERMISSIONS=comma_separated_list_of_permissions ./bin/rails db:seed
```

## Usage

### Configuration

Configuration is done using environment variables. See [.env](https://github.com/somleng/twilreapi/blob/master/.env)

### Running Locally

Start the web server using foreman. Note this will read the environment variables from [.env](https://github.com/somleng/twilreapi/blob/master/.env)

```
$ bundle exec foreman start web
```

### Background Processing

Twilreapi is queue agnostic. By default it will enqueue jobs using ActiveJob. The following background processing libraries are also supported and can be configured using [environment variables.](https://github.com/somleng/twilreapi/blob/master/.env)

* [active-elastic-job](https://github.com/tawan/active-elastic-job) (Default. Recommended for AWS deployment)
* [twilreapi-sidekiq](https://github.com/somleng/twilreapi-sidekiq) (Recommended for Heroku deployment)
* [shoryuken](https://github.com/phstc/shoryuken)

### Outbound Calls

In order to trigger outbound calls you can connect Twilreapi to [Somleng](https://github.com/somleng/somleng).

## Deployment

See [DEPLOYMENT](https://github.com/somleng/twilreapi/blob/master/docs/DEPLOYMENT.md)

## REST API Reference

### Calls

#### Make a Call

```
$ curl -XPOST https://your-host-name/api/2010-04-01/Accounts/{AccountSID}/Calls.json \
    -d "Method=GET" \
    -d "Url=http://demo.twilio.com/docs/voice.xml" \
    -d "To=%2B85512345678" \
    -d "From=%2B85512345679" \
    -u 'your_account_sid:your_auth_token'
```

#### Retrieve a Call

```
$ curl https://your-host-name/api/2010-04-01/Accounts/{AccountSID}/Calls/{CallSID}.json \
    -u 'your_account_sid:your_auth_token'
```

### Incoming Phone Numbers

#### Retrieve an Incoming Phone Number

```
$ curl https://your-host-name/api/2010-04-01/Accounts/{AccountSID}/IncomingPhoneNumbers/{IncomingPhoneNumberSID}.json \
    -u 'your_account_sid:your_auth_token'
```

## License

The software is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
