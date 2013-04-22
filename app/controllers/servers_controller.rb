require 'controller'
require 'securerandom'

class ServersController < Controller

  post '/servers' do
    authenticate!
    param :funpack, String, required: true, is: ID_PATTERN, :coerce => :downcase
    param :region, String, required: true, is: ID_PATTERN, :coerce => :downcase
    param :name, String

    legacy_id = BSON::ObjectId.new

    server = Server.new(
      id: SecureRandom.uuid,
      account: account,
      funpack: Funpack.where(id: params[:funpack], account: account).first,
      region: Region[params[:region]],
      name: params[:name],
      legacy_id: legacy_id.to_s
    )

    if not server.valid?
      halt 422, server.errors
    end

    # TODO Rescue save failure
    server.save

    # Legacy
    MONGO['production']['servers'].insert({
      '_id' => legacy_id,
      'created_at' => server.created,
      'updated_at' => server.updated
    })

    status 201
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
