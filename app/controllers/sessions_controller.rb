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
