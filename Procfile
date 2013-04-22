web:     bundle exec puma -Iapp -Ilib --threads 0:16 --port $PORT ./config.ru
worker:  bundle exec sidekiq --require ./worker.rb
console: bundle exec irb -Ilib -Iapp -r ./app.rb
