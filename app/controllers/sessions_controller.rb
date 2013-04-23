require 'controller'
require 'securerandom'

class SessionsController < Controller

  post '/servers/:id/session' do
    authenticate!
    param :id, String, required: true, is: ID_PATTERN, :coerce => :downcase

    server = Server.where(id: params[:id], account: account).first
    
    if server.nil?
      halt 404
    end

    # The session can't be started twice so direct clients instead to get the current session.
    if server.up?
      headers['Location'] = request.url
      halt 303
    end

    session = if server.starting?
      server.session
    else
      session = Session.new(id: SecureRandom.uuid, server: server, payload: request.body.read)

      # TODO Rescue transaction failure
      DB.transaction do
        session.save
        server.start!
      end
      
      session
    end
    
    # handle start failure
    
    # Push start job
    BRAIN.with do |redis|
      redis.lpush "servers:requests:start", JSON.dump(
        server_id: server.legacy_id,
        funpack_id: server.funpack.legacy_id,
        reply_key: server.legacy_id,
        data: session.payload
      )
    end

    # Wait for the session become playable
    BRAIN.with do |redis|
      redis.subscribe("servers:requests:start:#{server.legacy_id}") do |on|
        on.subscribe do |channel, subscriptions|
          # Send request to backend, must be able to handle multiple requests to the same server.
          puts "Listening " + channel
        end

        on.message do |channel, msg|
          # TODO Catch JSON parse error
          reply = JSON.parse(msg)

          p reply
          
          case 
          when reply['state'] == 'started'
            session.ip = reply['ip']
            session.port = reply['port']
            session.started = Time.at(reply['at'].to_i)
          
            # TODO Catch transaction error
            DB.transaction do
              session.save
              server.started!
            end
          
            redis.unsubscribe
          when reply['failed']
            session.stopped = Time.now
            session.exit_status = 1
            
            # TODO Catch transaction error
            DB.transaction do
              session.save
              server.crashed!
            end
          
            redis.unsubscribe
          end
        end

        on.unsubscribe do |channel, subscriptions|
          # session.reload
          status 201
          content_type :json
          return SessionSerializer.new(session).to_json
        end
      end
    end
  end

  get '/servers/:id/session' do
    authenticate!
    param :id, String, required: true, is: ID_PATTERN, :coerce => :downcase

    server = Server.where(id: params[:id], account: account).first

    if server.nil?
      halt 404
    end

    session = server.session

    if session.nil?
      halt 404
    end

    json SessionSerializer.new(session)
  end

  get '/sessions/:id' do
    authenticate!
    param :id, String, required: true, is: ID_PATTERN, :coerce => :downcase

    # TODO Check that this session belongs to a server from the account.
    session = Session[params[:id]]

    if session.nil?
      halt 404
    end

    json SessionSerializer.new(session)
  end

  delete '/servers/:id/session' do
    authenticate!
    param :id, String, required: true, is: ID_PATTERN, :coerce => :downcase

    server = Server.where(id: params[:id], account: account).first

    if server.nil?
      halt 404
    end

    session = server.session

    if session.nil?
      halt 404
    end

    # TODO Rescue transaction failure
    DB.transaction do
      session.stopped = Time.now
      session.save
      server.stop!
    end

    halt 204
  end


end
