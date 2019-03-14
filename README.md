# Sinatra Rack App

This is base rack app using Sinatra. It's the sample used on heroku.

## Bootup the App

```
bundle install
bundle exec rackup -p 9292 config.ru &
curl http://localhost:9292
Hello World!
kill %1
```
