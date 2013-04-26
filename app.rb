require 'sinatra'
require 'sinatra/sequel'
require 'sinatra/param'
require 'redis'
require 'connection_pool'
require 'sidekiq'
require 'mongo'

STDOUT.sync = true


# Postgres

configure do
  DB = Sequel.connect(ENV['DATABASE_URL'],
    encoding: 'utf-8',
    max_connections: 10
  )

  Sequel.default_timezone = :utc
  Sequel::Model.unrestrict_primary_key
  Sequel::Model.plugin :validation_helpers
  Sequel::Model.plugin :timestamps, :update_on_create => true,
                                    :create => :created,
                                    :update => :updated
end


# Redis

configure do
  REDIS = Redis.new(:driver => :hiredis)
end

# Brain Redis

configure do
  BRAIN = Redis.new(url: ENV['BRAIN_URL'], :driver => :hiredis)
end


# Legacy Mongo

configure do
  MONGO = Mongo::MongoClient.from_uri(ENV['MONGODB_URI'],
    pool_size: 16
  )
end


# Configure production, logging errors and security.

configure :production do
  require 'bugsnag'
  require 'librato/rack'
  require 'rack/ssl'

  Bugsnag.configure do |config|
    config.api_key = ENV['BUGSNAG_API_KEY']
    config.project_root = settings.root
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

before do
  headers['Access-Control-Allow-Origin'] = 'manage.partycloud.com'
end

get '/' do
  content_type :text
  'Hello, World.'
end

get '/ping' do
  content_type :text
  "pong\n"
end
