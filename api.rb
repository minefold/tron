require 'core'
require 'librato-rack'

class API < Grape::API
  use Librato::Rack

  version 'v1', :using => :header, :vendor => :minefold
  format :json

  resource :servers do

    params do
      requires :id, type: Integer
    end
    get ':id' do
      server = Server.find(params[:id])
      ServerSerializer.new(server)
    end

  end

  resource :users do

    params do
      requires :id, type: String
    end
    get ':id' do
      user = User.find(params[:id])
      UserSerializer.new(user)
    end

  end

end
