require 'bundler/setup'
require 'goliath'
require 'grape'
require 'redis'

require './api'

class Application < Goliath::API

  def response(env)
    API.call(env)
  end

end
