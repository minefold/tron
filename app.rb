require 'bundler/setup'
require 'goliath'
require 'grape'

require './app/api'

class Application < Goliath::API

  def response(env)
    API.call(env)
  end

end
