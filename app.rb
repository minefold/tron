require 'sinatra'
require 'sinatra/sequel'
require 'sinatra/param'
require 'redis'
require 'connection_pool'
require 'resque'

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

configure do
  # Opens a persistant Redis connection for Resque
  Resque.redis = Redis.new(:driver => :hiredis)
end


# Legacy configuration

Bundler.setup(:legacy)
require 'mongo'

configure do
  set :mongo, begin
    uri = ENV['MONGO_URL'] || 'mongodb://localhost/tron_development'
    mongo = ::Mongo::Connection.from_uri(uri)

    if mongo.is_a? ::Mongo::MongoReplicaSetClient
      # this should be in the damn ruby driver
      mongo_uri = ::Mongo::URIParser.new(uri)
      auth = mongo_uri.auths.first

      db = mongo[auth['db_name']]
      db.authenticate auth['username'], auth['password']
      db
    else
      db_name = mongo.auths.any? ? mongo.auths.first['db_name'] : nil
      db_name ||= URI.parse(uri).path[1..-1]
      mongo[db_name]
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
