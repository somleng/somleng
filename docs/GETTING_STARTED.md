# Getting Started

Follow instructions below to get Somleng's REST API up and running on your local machine.

## Setup the database

### Create the database

```
$ sudo docker-compose run web  /bin/bash -c './bin/rails db:create && ./bin/rails db:schema:load'
```

### Seed the database

Run the following command and note down the output.

```
$ sudo docker-compose run web /bin/bash -c './bin/rails db:seed'
```
