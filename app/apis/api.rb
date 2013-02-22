require 'minefold'

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

  resource :servers do

    get '/:id' do
      $redis = redis
      server = Minefold::Server.where(id: params[:id]).first
      Minefold::Serializers::ServerSerializer.new(server)
    end

  end

end
