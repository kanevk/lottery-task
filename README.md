# lottery-task
Lottery game

## Assumptions
 - Having a possible load of millions tickets

## Setup

### API

You need Ruby 2.5.1

Install gem dependencies
```
$ bundle
```

Setup PostgreSQL and create user `lottery`
```
$ createuser -P -s -e lottery
```

Setup the DB which will create the databases, load the schema and seed the dev database
```
$ bundle exec rails db:setup
```

You can use `LOTTERY_TICKETS_COUNT` for increasing the seeded tickets
```
$ LOTTERY_TICKETS_COUNT='1000000' bundle exec rails db:setup # It passes for ~ 1 minute
```

Start server
```
bundle exec rails s
```

### Client

Recommended Node version: >10.9.0

Install dependencies
```
$ npm install
```

Start server

```
$ npm start
```

## Run tests

```
cd api
bundle exec rspec
```










