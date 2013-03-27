require 'sinatra/base'
require 'models/server'
require 'serializers/server_serializer'
require 'serializers/list_serializer'
require 'securerandom'

class ServersController < Sinatra::Base

  error Sequel::DatabaseError do
    404
  end

  get '/servers/:id' do
    begin
      server = Server[params[:id]]
      content_type :json
      ServerSerializer.new(server).to_json
    rescue Sequel::DatabaseError => e
      raise Sinatra::NotFound
    end
  end

  post '/servers' do
    server = Server.new(
      id: SecureRandom.uuid,
      account_id: "76a9f77c-2c15-401a-a66f-a84bb422e9fc",
      funpack_id: "c2be5b9d-d218-420f-b993-de880e3e1838",
      name: params[:name],
      region: params[:region],
      state: 0,
      created: Time.now,
      updated: Time.now
    )

    server.save

    content_type :json
    ServerSerializer.new(server).to_json
  end

end
