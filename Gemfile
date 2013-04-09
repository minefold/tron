source 'https://rubygems.org'
ruby '2.0.0'

gem 'puma', '2.0.0.b7'
gem 'rack'
gem 'sinatra'
gem 'rack-ssl'
gem 'pg'
gem 'sequel'
gem 'sinatra-sequel'
gem 'sinatra-param'
gem 'state_machine'
gem 'redis'
gem 'hiredis'
gem 'connection_pool'

# Legacy
gem 'bson_ext'
gem 'mongo'

group :worker do
  gem 'resque'
  gem 'rake'
end

group :production do
  gem 'bugsnag'
  gem 'librato-rack'
end
