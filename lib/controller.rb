require 'sinatra/base'
require 'rack/auth/basic'

# AbstractController class. It's a leaky abstraction, really this is just shared code that I want in all the controlllers.
class Controller < Sinatra::Base

  ID_PATTERN = /[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/

  helpers Sinatra::Param

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

end

