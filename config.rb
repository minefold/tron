require 'redis/connection/synchrony'
require 'sync-em/pg'

config['redis'] = EventMachine::Synchrony::ConnectionPool.new(size: 5) do
  Redis.new
end

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

# Should be root=false
# fixed in 96ce3105950fe92fbfdc288bbdab7037c08935e1
ActiveModel::Serializer.root(false)
