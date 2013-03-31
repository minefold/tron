require 'sinatra'
require 'sinatra/sequel'
require 'sinatra/param'
require 'bugsnag'
require 'logger'

DB ||= Sequel.connect(ENV['DATABASE_URL'],
  encoding: 'utf-8',
  max_connections: 10
)

configure :development do
  DB.logger = Logger.new(STDOUT)
  DB.log_warn_duration = 0
end

configure :production do
  Bugsnag.configure do |config|
    config.api_key = ENV['BUGSNAG_API_KEY']
  end

  use Bugsnag::Rack

  enable :raise_errors
end

configure do
  Sequel::Model.unrestrict_primary_key
  Sequel::Model.plugin :validation_helpers
  Sequel::Model.plugin :timestamps, :update_on_create => true,
                                    :create => :created,
                                    :update => :updated
end

require 'models'
require 'serializers'
require 'controllers'

use SessionsController
use ServersController
use RegionsController
