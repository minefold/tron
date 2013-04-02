require 'sinatra'
require 'sinatra/sequel'
require 'sinatra/param'
require 'redis'
require 'connection_pool'

STDOUT.sync = true

# Initiate connections to outside services.
# NB. These can to be accessed from multiple threads.

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

# Configure production, logging errors and security.

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

# Initialize application code

require 'models'
require 'serializers'
require 'controllers'
require 'jobs'

use FunpacksController
use PlayersController
use SessionsController
use ServersController
use RegionsController

get '/' do
  content_type :text
  'Hello, World.'
end
