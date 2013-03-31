require 'securerandom'

class ServersController < Sinatra::Base

  helpers do
    def json(obj)
      content_type :json
      obj.to_json
    end
  end

  get '/servers/:id' do
    server = Server[params[:id]]
    json ServerSerializer.new(server)
  end

  post '/servers' do
    server = Server.create(
      id: SecureRandom.uuid,
      account: Account.first,
      funpack: Funpack.first,
      name: params[:name],
      region: params[:region],
      state: 0,
      created: Time.now,
      updated: Time.now
    )

    json ServerSerializer.new(server)
  end

  get '/servers' do
    servers = Server.all
    json ListSerializer.new(servers.map {|s| ServerSerializer.new(s) })
  end

end
