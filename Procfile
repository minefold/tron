web:     bundle exec thin -R config.ru start -p $PORT
worker:  bundle exec sidekiq --require ./worker.rb --verbose
console: bundle exec irb -Ilib -Iapp -r ./app.rb
