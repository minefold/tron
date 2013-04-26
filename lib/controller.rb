require 'sinatra/base'
require 'sinatra/streaming'
require 'rack/auth/basic'

# AbstractController class. It's a leaky abstraction, really this is just shared code that I want in all the controlllers.
class Controller < Sinatra::Base

  ID_PATTERN = /[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/

  helpers Sinatra::Param
  helpers Sinatra::Streaming

  helpers do
    attr_reader :account

    # TODO Not happy with this, but it works.
    def authenticate!
      @auth = Rack::Auth::Basic::Request.new(env)

      unless @auth.provided?
        halt 401 # unauthorized
      end

      unless @auth.basic?
        halt 400 # bad request
      end

      @account = Account.find_from_auth(@auth)
      session[:account] = @account

      if @account
        env['REMOTE_USER'] = @account
      else
        halt 401 # unauthorized
      end
    end

    def json(obj)
      content_type :json
      obj.to_json
    end
  end

  after do
    if account = session[:account]
      headers['X-ServerLimit-Limit'] = account.server_limit.to_s
      headers['X-ServerLimit-Remaining'] = account.server_limit_remaining.to_s
    end
  end
end

