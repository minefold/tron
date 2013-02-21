require 'redis'
require 'redis/connection/synchrony'

config['redis'] = EventMachine::Synchrony::ConnectionPool.new(size: 10) do
  Redis.new
end
