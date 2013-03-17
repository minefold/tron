require 'core'
require 'librato-rack'

class API < Grape::API
  use Librato::Rack

  version '0.0.1', :using => :header, :vendor => :minefold
  format :json

  rescue_from ActiveRecord::RecordNotFound do |e|
    Rack::Response.new([], 404)
  end

  helpers do
    def current_user
      @current_user = User.where(authentication_token: request.env['REMOTE_USER']).first
    end
  end

  resource :servers do

    http_basic do |username, password|
      User.where(authentication_token: username).first
    end

    params do
      requires :name, type: String
      requires :funpack_id, type: String
      optional :gameplay, type: Hash
    end
    post '/' do
      # TODO Validate gameplay settings with Brock

      server = Server.create!(
        name: params[:name],
        creator: current_user,
        settings: params[:gameplay] || {},
        funpack_id: params[:funpack_id],
        party_cloud_id: "dummy-party-cloud-id-#{rand(10000)}"
      )

      Serializers::Server.new(server)
    end


    params do
      requires :id, type: String
    end
    get '/:id' do
      server = Server.where(id: params[:id]).first!
      Serializers::Server.new(server)
    end


    params do
      requires :id, type: String
      requires :name, type: String
    end
    put '/:id' do
      server = Server.find(params[:id])
      server.name = params[:name]
      server.save!
      Serializers::Server.new(server)
    end


    params do
      requires :id, type: String
      requires :gameplay, type: Hash
    end
    put '/:id/gameplay' do
      server = Server.where(id: params[:id]).first!
      server.settings.merge! params[:gameplay]
      server.save!
      Serializers::Server.new(server)
    end


    params do
      requires :id, type: String
    end
    put '/:id/start' do
      server = Server.where(id: params[:id]).first!
      server.start!
    end


    params do
      requires :id, type: String
    end
    put '/:id/stop' do
      server = Server.where(id: params[:id]).first!
      server.stop!
    end


    params do
    end
    put '/:id/restart' do
      server = Server.where(id: params[:id]).first!
      server.restart!
    end

  end

  resource :user do

    http_basic do |username, password|
      User.where(authentication_token: username).first
    end

    get '/' do
      UserSerializer.new(current_user)
    end

    get '/servers' do
      servers = current_user.created_servers
      Serializers::List.new(servers.map {|s| Serializers::Server.new(s) })
    end

  end

  resource :games do

    params do
      requires :slug, type: String
    end
    get '/:slug' do
      game = Core::GAMES.find(params[:slug])
    end

    params do
      requires :slug, type: String
      requires :state, type: String, regexp: /up|idle|starting|stopping|crashed/
    end
    get '/:slug/servers/:state' do
      game = Core::GAMES.find(params[:slug])
      servers = Server.where(funpack_id: game.funpack_id)
            .where(state: Server::States[params[:state].to_sym])

      Serializers::List.new(servers.map {|s| Serializers::Server.new(s) })
    end

    params do
      requires :slug, type: String
    end
    get '/:slug/servers' do
      game = Core::GAMES.find(params[:slug])
      servers = Server.where(funpack_id: game.funpack_id)

      Serializers::List.new(servers.map {|s| Serializers::Server.new(s) })
    end

  end

end
