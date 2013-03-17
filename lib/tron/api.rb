require 'grape/api'
require 'librato-rack'
require 'active_record'

require 'tron/games'
require 'tron/servers'
require 'tron/user'

module Tron
  class API < Grape::API
   use Librato::Rack

   version '0.0.1', :using => :header, :vendor => :minefold
   format :json

   helpers do
     def current_user
       @current_user = User.where(authentication_token: request.env['REMOTE_USER']).first
     end
   end

   namespace('servers') do
     mount Tron::Servers
   end

   namespace('user') do
     mount Tron::User
   end

   namespace('games') do
     mount Tron::Games
   end

  end
end
