require 'sinatra'
require 'sinatra/sequel'
require 'sinatra/param'
require 'redis'
require 'connection_pool'

DB = Sequel.connect(ENV['DATABASE_URL'],
  encoding: 'utf-8',
  max_connections: 10
)

REDIS = ConnectionPool.new(size: 16, timeout: 5) do
  Redis.new(:driver => :hiredis)
end

configure do
  Sequel.default_timezone = :utc
  Sequel::Model.unrestrict_primary_key
  Sequel::Model.plugin :validation_helpers
  Sequel::Model.plugin :timestamps, :update_on_create => true,
                                    :create => :created,
                                    :update => :updated
end

configure :development do
  require 'logger'
  # DB.logger = Logger.new(STDOUT)
end

configure :production do
  require 'bugsnag'
  require 'librato/rack'
  require 'rack/ssl'

  Bugsnag.configure do |config|
    config.api_key = ENV['BUGSNAG_API_KEY']
  end

  enable :raise_errors

  use Bugsnag::Rack
  use Librato::Rack
  use Rack::SSL
end

require 'models'
require 'serializers'
require 'controllers'

use FunpacksController
use PlayersController
use SessionsController
use ServersController
use RegionsController

get '/' do
  content_type :text
  'Hello, World.'
end
