$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))

require 'bundler/setup'
require 'goliath'
require 'grape'

require 'tron'

$stdout.sync = true

class Application < Goliath::API
  def response(env)
    Tron::API.call(env)
  end
end

