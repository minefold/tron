require 'core'

class API < Grape::API
  version 'v1', :using => :header, :vendor => :minefold
  format :json

  helpers do
    def redis
      env.config['redis']
    end

    def pg
      env.config['pg']
    end
  end

  resource :games do

    get '/:slug'

  end

  resource :funpacks do

    get ':id' do
      funpack = Funpack.find(params[:id])
      FunpackSerializer.new(funpack)
    end

  end

  resource :servers do

    post '/'

    params do
      requires :id, type: Integer
    end
    get ':id' do
      server = Server.find(params[:id])
      ServerSerializer.new(server, redis: redis)
    end

    put ':id'
    delete ':id'

    post ':id/start'
    post ':id/stop'

    resource :snapshots

  end

  resource :users do

    get '/:slug' do
      user = User.find(params[:slug])
      UserSerializer.new(user)
    end

    resource :accounts do

      get '/'

    end

  end

end
