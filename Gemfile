source 'https://rubygems.org'
ruby '2.0.0'

gem 'puma', '2.0.1'
gem 'rack'
gem 'sinatra'
gem 'rack-ssl'
gem 'pg'
gem 'sequel'
gem 'sinatra-sequel'
gem 'sinatra-param'
gem 'sinatra-contrib'
gem 'state_machine'
gem 'redis'
gem 'hiredis'
gem 'connection_pool'
gem 'bcrypt-ruby'

#
gem 'rack-protection', github: 'rkh/rack-protection'

# Legacy
gem 'bson_ext'
gem 'mongo'

group :worker do
  gem 'sidekiq'
end

group :production do
  gem 'bugsnag'
  gem 'librato-rack'
end
