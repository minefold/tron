require 'redis'
require 'redis/connection/synchrony'

config['redis'] = EventMachine::Synchrony::ConnectionPool.new(size: 10) do
  Redis.new
end

require 'sync-em/pg/sequel'
require 'sequel'

config['pg'] = Sequel.connect(ENV['DATABASE_URL'],
  pool_class: Sync::EM::PG::Sequel::ConnectionPool
)
