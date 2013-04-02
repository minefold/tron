web:     bundle exec puma -Iapp -Ilib --threads 0:16 --port $PORT ./config.ru
worker:  bundle exec rake -I./app -I./lib resque:work TERM_CHILD=1 QUEUE=*
console: bundle exec irb -Ilib -Iapp -r ./app.rb
