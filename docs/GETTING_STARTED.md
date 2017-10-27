# Getting Started

This is the getting started guide for Somleng's REST API. If you want to get the full Somleng stack up and running see the [getting started guide for Somleng](https://github.com/somleng/somleng-project/blob/master/docs/GETTING_STARTED.md).

Follow the instructions below to get Somleng's REST API up and running on your local machine.

## Pull the latest image

```
$ docker-compose pull
```

## Setup the database

```
$ docker-compose run --rm twilreapi /bin/bash -c './bin/rails db:setup'
```

## Boot the server

```
$ docker-compose up
```

## Testing things out

Navigate to `http://localhost:3000` you should see Somleng :)
