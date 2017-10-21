# Getting Started

This is the getting started guide for Somleng's REST API. Follow instructions below to get Somleng's REST API up and running on your local machine. If you want to get the full Somleng stack up and running see the [getting started guide for Somleng](https://github.com/somleng/somleng-project/blob/master/docs/GETTING_STARTED.md).

## Pull the latest images

```
$ sudo docker-compose pull
```

## Setup the database

```
$ sudo docker-compose run twilreapi /bin/bash -c './bin/rails db:setup'
```

### Get an Account SID and Auth Token

```
$ IFS=: read ACCOUNT_SID AUTH_TOKEN <<< $(sudo docker-compose run -e FORMAT=basicauth twilreapi /bin/bash -c './bin/rails db:seed')
$ echo "Account SID: $ACCOUNT_SID" && echo "Auth Token: $AUTH_TOKEN"
```

## Boot the server

```
$ sudo docker-compose up
```

## Testing things out

Navigate to `http://localhost:3000` you should see Somleng :)

### Make a call

[Make a call](https://www.twilio.com/docs/api/voice/making-calls?code-sample=code-make-an-outbound-call&code-language=curl&code-sdk-version=json). Replace `{AccountSID}` and `{AuthToken}` with your User Account SID and Auth Token output when [seeding the database](#seed-the-database). Note this won't actually call anyone. In order to see

```
$ curl -XPOST http://localhost:3000/api/2010-04-01/Accounts/{AccountSID}/Calls.json \
    --data-urlencode "Method=GET" \
    --data-urlencode "Url=http://demo.twilio.com/docs/voice.xml" \
    --data-urlencode "To=+85512345678" \
    --data-urlencode "From=+85512345679" \
    -u '{AccountSID}:{AuthToken}'
```

