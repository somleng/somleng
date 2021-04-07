# Twilreapi /twil-reap-i/ (Twilio Rest API)

[![GitHub Action](https://github.com/somleng/twilreapi/actions/workflows/build.yml/badge.svg)](https://github.com/somleng/twilreapi/actions)
[![codecov](https://codecov.io/gh/somleng/twilreapi/branch/develop/graph/badge.svg)](https://codecov.io/gh/somleng/twilreapi)

Twilreapi is an Open Source implementation of [Twilio's REST API](https://www.twilio.com/docs/api/rest) written in Rails. You can use Twilreapi as a drop-in replacement for Twilio and enqueue calls, send SMS etc.

## Installation

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Check the output of `bin/setup` and note down the Account SID and Auth Token.

## Usage

If you want to get the full Somleng stack up and running locally, please follow the [GETTING STARTED](https://github.com/somleng/somleng-project/blob/master/docs/GETTING_STARTED.md) guide to get started.

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
