require 'controller'
require 'securerandom'
require 'brain'

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
    
    result = Brain.new.start_server(
      server_id: server.legacy_id,
      funpack_id: server.funpack.legacy_id,
      reply_key: server.legacy_id,
      data: session.payload
    )
    
    puts "result:#{result.inspect}"
    
    if result.success?
      session.ip = result[:ip]
      session.port = result[:port]
      session.started = Time.at(result[:at].to_i)
      
      # TODO Catch transaction error
      DB.transaction do
        session.save
        server.started!
      end
    else

      session.stopped = Time.now
      session.exit_status = 1
      
      # TODO Catch transaction error
      DB.transaction do
        session.save
        server.crashed!
      end      
    end
    
    status 201
    content_type :json
    SessionSerializer.new(session).to_json
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
    
    Brain.new.stop_server(server.legacy_id)

    # TODO Rescue transaction failure
    DB.transaction do
      session.stopped = Time.now
      session.save
      server.stop!
    end

    halt 204
  end


end
