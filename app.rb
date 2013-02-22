require 'bundler/setup'
require 'goliath'
require 'grape'
require 'redis'
require 'core'

require './app/apis/api'

class Application < Goliath::API

  def response(env)
    API.call(env)
  end

end
