require 'redis'
require 'redis/connection/synchrony'

require 'active_record'
require 'sync-em/pg'

# Setup a new Redis connection pool
config[:redis] = EventMachine::Synchrony::ConnectionPool.new(size: 5) do
  Redis.new
end

# Initialize ActiveRecord
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
ActiveRecord::Base.logger = Logger.new(STDOUT)
