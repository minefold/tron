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

  # DB.sql_log_level = :debug
  DB.logger = Logger.new($stdout)

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
  MONGO = begin
    extra_opts = { pool_size: 16 }
    uri = ENV['MONGODB_URI']

    parser = Mongo::URIParser.new(uri)

    conn = parser.connection(extra_opts)
    db = if auth = parser.auths.first
      conn.add_auth(auth[:db_name], auth[:username], auth[:password])
      conn[auth[:db_name]]
    else
      conn[uri.split('/').last]
    end
  end
end

# Configure production, logging errors and security.
configure :production do
  require 'bugsnag'
  require 'librato/rack'
  require 'rack/ssl'

  Bugsnag.configure do |config|
    config.api_key = ENV['BUGSNAG_API_KEY']
    config.project_root = settings.root
    config.logger.level = Logger::INFO
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

use AccountController
use FunpacksController
use PlayersController
use SessionsController
use ServersController
use RegionsController
use SnapshotsController

# CORS
before do
  if request.request_method == 'OPTIONS'
    halt 200
  end
end

get '/' do
  content_type :text
  'Hello, World.'
end

get '/ping' do
  content_type :text
  "pong\n"
end

get '/crash' do
  raise 'unsupported'
end
