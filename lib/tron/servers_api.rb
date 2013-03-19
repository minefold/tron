require 'grape/api'
require 'em-synchrony/em-http'

module Tron
  class ServersAPI < Grape::API

    http_basic do |username, password|
      User.where(authentication_token: username).first
    end

    params do
      requires :name, type: String
      requires :funpack_id, type: String
      optional :gameplay, type: Hash
    end
    post '/' do
      # Grab the party-cloud-id from, uh, the Party Cloud
      url = ENV['GRAYSKULL_URL'] + '/servers'

      req = EventMachine::HttpRequest.new(url).post head: {
        'authorization' => ENV['PARTY_CLOUD_TOKEN'].split(':')
      }

      if req.error
        raise 'Party Cloud call failed'
      end

      party_cloud_id = JSON.parse(req.response)['id']

      # TODO Validate gameplay settings with Brock

      server = Server.create!(
        name: params[:name],
        creator: current_user,
        settings: params[:gameplay] || {},
        funpack_id: params[:funpack_id],
        party_cloud_id: party_cloud_id
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
      sub = Redis.new
      sub.subscribe("servers:requests:start:#{server.party_cloud_id}") do |on|
        on.message do |chan, raw|
          msg = JSON.parse(raw, symbolize_names: true)

          # TODO handle failed
          if msg[:state] == 'started'
            # Update session information
            session[:started_at] = Time.at(msg[:at])
            session[:ip] = msg[:ip]
            session[:port] = msg[:port]
            session.save!

            # Mark server as up
            server.start!

            # Wait for response on server key
            # The `return` is *magic*
            return Serializers::Server.new(server)
          end
        end

        on.subscribe do
          # Start the server in the PartyCloud
          env.config[:redis].lpush(
            "servers:requests:start",
            {
              server_id: server.party_cloud_id,
              funpack_id: server.funpack.party_cloud_id,
              reply_key:  server.party_cloud_id,
              data: server.attributes_for_party_cloud.to_json
            }.to_json
          )
        end
      end
    end


    params do
      requires :id, type: String
    end
    put '/:id/stop' do
      server = Server.where(id: params[:id]).first!

      session = server.current_session

      if server.up?
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
      end

      Serializers::Server.new(server)
    end

  end
end
