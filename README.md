# Yaroute

Yaroute is a quiz game. Create best quiz and invite friends to play.

## Usage

The easiest way to start application is to use docker image (not yet published).

## Contributing

You want to contribute ? Great idea !

Install the following tools :
- docker
- docker-compose
- make (GNU Make)
- pv

Then create default environment file required to start application locally.

```
$ make generate-env
```

A file called `default.env` has been created, containing environment variables.
Now start local environment and enter development console.

```
$ make local-start
$ make local-console
```

From development console, you may start rails application

```
# For arm (mac m1) users
$ bundle config set force_ruby_platform true
```

```
$ bundle install
$ bundle exec rake db:migrate db:seed
$ bin/dev
```

And browse to http://127.0.0.1:3000, default password is `admin`/`admin`

If you want to test multiple players on the same browser, use something like
Firefox's
[temporary-containers](https://addons.mozilla.org/en-US/firefox/addon/temporary-containers/).
