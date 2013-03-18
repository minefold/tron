require 'grape/api'
require 'librato-rack'
require 'active_record'

require 'tron/games_api'
require 'tron/logs_api'
require 'tron/servers_api'
require 'tron/user_api'

module Tron
  class API < Grape::API
    use Librato::Rack

    version '0.0.1', :using => :header, :vendor => :minefold
    format :json

    helpers do
      def current_user
        @current_user ||= User.where(authentication_token: request.env['REMOTE_USER']).first
      end
    end

    namespace('servers') do
      mount Tron::ServersAPI
      mount Tron::LogsAPI
    end

    namespace('user') do
      mount Tron::UserAPI
    end

    namespace('games') do
      mount Tron::GamesAPI
    end
  end
end
