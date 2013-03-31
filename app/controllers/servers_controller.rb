require 'controller'
require 'securerandom'

class ServersController < Controller

  post '/servers' do
    authenticate!
    param :funpack, String, required: true, is: ID_PATTERN, :coerce => :downcase
    param :region, String, required: true, is: ID_PATTERN, :coerce => :downcase
    param :name, String

    server = Server.new(
      id: SecureRandom.uuid,
      account: account,
      funpack: Funpack.where(id: params[:funpack], account: account).first,
      region: Region[params[:region]],
      name: params[:name]
    )

    if not server.valid?
      halt 422, server.errors
    end

    server.save
    json ServerSerializer.new(server)
  end

  get '/servers/:id' do
    authenticate!
    param :id, String, required: true, is: ID_PATTERN, :coerce => :downcase

    server = Server.where(id: params[:id], account: account).first

    if server.nil?
      halt 404
    end

    json ServerSerializer.new(server)
  end

  get '/servers' do
    authenticate!

    json ListSerializer.new(account.servers.map {|s|
      ServerSerializer.new(s)
    })
  end

end
