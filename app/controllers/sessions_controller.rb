require 'securerandom'

class SessionsController < Sinatra::Base

  helpers do
    def json(obj)
      content_type :json
      obj.to_json
    end
    def see_other(resource)
      halt 303, {'Location' => resource}
    end
    def no_content
      halt 204
    end
  end

  get '/sessions/:id' do
    session = Session[params[:id]]
    json SessionSerializer.new(session)
  end

  post '/servers/:id/session' do
    server = Server[params[:id]]

    if server.session
      see_other(request.url)
    end

    session = Session.create(
      id: SecureRandom.uuid,
      server: server
    )

    subscription = Redis.new
    subscription.subscription("servers:requests:start:#{server.id}") do |on|
      on.subscribe do
        payload = {
          server_id: server.id,
          funpack_id: server.funpack.id,
          reply_key: server.id,
          data:
        }
        App.redis.lpush("servers:requests:start", {

        }

        )
      end

      on.message do |chan, raw|

      end

    # App.redis.lpush "servers:requests:start",
    # {
    #   server_id: server.party_cloud_id,
    #   funpack_id: server.funpack.party_cloud_id,
    #   reply_key:  server.party_cloud_id,
    #   data: server.attributes_for_party_cloud.to_json
    # }.to_json

    server.start!

    json SessionSerializer.new(session)
  end

  get '/servers/:id/session' do
    server = Server[params[:id]]
    session = server.session

    if session.nil?
      not_found
    else
      json SessionSerializer.new(session)
    end
  end

  delete '/servers/:id/session' do
    server = Server[params[:id]]
    session = server.session

    if session.nil?
      not_found
    end

    App.db.transaction do
      session.stopped = Time.now
      session.save
      server.stop!
    end

    no_content
  end


end
