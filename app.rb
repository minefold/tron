require 'sinatra/base'
require 'sinatra/sequel'
require 'logger'

class App < Sinatra::Base

  def self.db
    @db ||= Sequel.connect(ENV['DATABASE_URL'],
       encoding: 'utf-8',
       max_connections: 10
     )
  end

  configure :development do
    db.loggers << Logger.new(STDOUT)
  end

  configure do
    # TODO Replace with something a little less noisy
    db.loggers << Logger.new(STDOUT)

    Sequel::Model.unrestrict_primary_key
    Sequel::Model.plugin :timestamps, :update_on_create => true,
                                      :create => :created,
                                      :update => :updated

    require 'models'
    require 'serializers'
    require 'controllers'
  end

  use SessionsController
  use ServersController
  use RegionsController

  get '/' do
    'hello'
  end

end
