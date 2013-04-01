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
    if server.session
      halt 303, 'Location' => request.url
    end

    session = Session.new(
      id: SecureRandom.uuid,
      server: server
    )

    # TODO Rescue transaction failure
    DB.transaction do
      session.save
      server.start!
    end

    # wait for it to become playable

    server.started!

    status 201
    json SessionSerializer.new(session)
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
