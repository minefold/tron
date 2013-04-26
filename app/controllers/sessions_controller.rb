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

    if account.server_limit_remaining < 1
      halt 400
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

    status 201
    content_type :json

    stream do |out|
      timer = nil
      EM.next_tick do
        timer = EM.add_periodic_timer(15) {
          begin
            out.print ' '
            out.flush
          rescue IOError
            timer.cancel
          end
        }
      end

      succeeded = Brain.new(BRAIN).start_server(
        session_id: session.id,
        server_id: server.legacy_id,
        funpack_id: server.funpack.legacy_id,
        reply_key: server.legacy_id,
        data: session.payload
      )

      session.reload

      if succeeded
        # reply good
      else
        # reply bad
      end
      timer.cancel
      begin
        out << SessionSerializer.new(session).to_json
      rescue IOError
        # client is gone, no need to write response
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

    Brain.new(BRAIN).stop_server(
      session_id: session.id,
      server_id: server.legacy_id,
    )
    session.reload

    status 201
    content_type :json
    SessionSerializer.new(session).to_json
  end
end
