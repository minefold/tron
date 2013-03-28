require 'securerandom'

class SessionsController < Sinatra::Base

  helpers do
    def json(obj)
      content_type :json
      obj.to_json
    end
  end

  get '/sessions/:id' do
    session = Session[params[:id]]
    json SessionSerializer.new(session)
  end

  post '/servers/:id/session' do
    server = Server[params[:id]]

    session = Session.new(
      id: SecureRandom.uuid,
      server: server
    )

    App.db.transaction do
      session.save
      server.start!
      # Send request to backend to start the server
    end

    json SessionSerializer.new(session)
  end

  get '/servers/:id/session' do
    server = Server[params[:id]]
    session = server.session

    not_found if session.nil?

    json SessionSerializer.new(session)
  end

  delete '/servers/:id/session' do
    server = Server[params[:id]]
    session = server.session

    not_found if session.nil?

    App.db.transaction do
      session.stopped = Time.now
      session.save
      server.stop!
    end

    204
  end


end
