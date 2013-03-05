require 'redis/connection/synchrony'
require 'sync-em/pg'

config['redis'] = EventMachine::Synchrony::ConnectionPool.new(size: 5) do
  Redis.new
end

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
