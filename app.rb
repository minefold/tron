require 'sinatra/base'
require 'sinatra/sequel'

DB = Sequel.connect(ENV['DATABASE_URL'],
       encoding: 'utf-8',
       max_connections: 10
     )

require 'controllers/regions_controller'
require 'controllers/servers_controller'

class App < Sinatra::Base
  configure do
    set :database, DB
  end

  use ServersController
  use RegionsController

  get '/' do
    'hello'
  end

end
