# Getting Started

Follow instructions below to get Somleng's REST API up and running on your local machine.

## Setup the database

### Create the database

```
$ sudo docker-compose run web  /bin/bash -c './bin/rails db:create && ./bin/rails db:schema:load'
```

### Seed the database

Run the following command and note down the output. This will create a user account and an admin account with all possible permissions. For a production environment it's recommended that you create individual Admin users for each specific task.

```
$ sudo docker-compose run -e CREATE_ADMIN_ACCOUNT=1 -e ADMIN_ACCOUNT_PERMISSIONS=all web /bin/bash -c './bin/rails db:seed'
```
