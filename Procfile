web:     bundle exec puma -Iapp -Ilib --threads 0:16 --port $PORT ./config.ru
worker:  env TERM_CHILD=1 QUEUE=* bundle exec rake -I./app -I./lib resque:work
console: bundle exec irb -Ilib -Iapp -r ./web.rb
