require 'grape/api'

module Tron
  class User < Grape::API

    http_basic do |username, password|
      User.where(authentication_token: username).first
    end

    get '/' do
      UserSerializer.new(current_user)
    end

    get '/servers' do
      servers = current_user.created_servers
      Serializers::List.new(servers.map {|s| Serializers::Server.new(s) })
    end

  end
end
