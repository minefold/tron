require 'grape/api'

module Tron
  class ServersAPI < Grape::API

    http_basic do |username, password|
      ::User.where(authentication_token: username).first
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

      # Create a session or find an old one
      session = server.sessions.active.first_or_create(
        user_id: current_user.id
      )
      session.save!

      # Start the server in the PartyCloud
      s = PartyCloud.start_server_session(
        server.id,
        session.id,
        server.attributes_for_party_cloud
      )

      # Update session information
      session[:started_at] = s[:at]
      session[:ip] = s[:ip]
      session[:port] = s[:port]
      session.save!

      # Mark server as up
      server.start!

      # Wait for response on server key
      Serializers::Server.new(server)
    end


    params do
      requires :id, type: String
    end
    put '/:id/stop' do
      server = Server.where(id: params[:id]).first!

      session = server.current_session

      # TODO Return if there's no current session

      # Stop server session
      s = PartyCloud.stop_server_session(
        server.id,
        session.id
      )

      # Mark session as over
      session.ended_at = s[:at]
      session.save!

      # Mark server as stopped
      server.stop!

      Serializers::Server.new(server)
    end

  end
end
