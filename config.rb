require 'redis'
require 'redis/connection/synchrony'

require 'tron/party_cloud'

require 'active_record'
require 'sync-em/pg'

# Setup a new Redis connection pool
config['redis'] = EventMachine::Synchrony::ConnectionPool.new(size: 5) do
  Redis.new
end

# Connect to the PartyCloud redis instance
PartyCloud.redis = config['redis']

# Initialize ActiveRecord
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
ActiveRecord::Base.logger = Logger.new(STDOUT)
