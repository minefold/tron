require 'grape/api'

module Tron
  class Servers < Grape::API

    http_basic do |username, password|
      User.where(authentication_token: username).first
    end

    params do
      requires :name, type: String
      requires :funpack_id, type: String
      optional :gameplay, type: Hash
    end
    post '/' do
      # TODO Validate gameplay settings with Brock
      server = Server.create!(
        name: params[:name],
        creator: current_user,
        settings: params[:gameplay] || {},
        funpack_id: params[:funpack_id],
        party_cloud_id: "dummy-party-cloud-id-#{rand(10000)}"
      )

      Serializers::Server.new(server)
    end


    params do
      requires :id, type: String
    end
    get '/:id' do
      server = Server.where(id: params[:id]).first!
      Serializers::Server.new(server)
    end


    params do
      requires :id, type: String
      requires :name, type: String
    end
    put '/:id' do
      server = Server.find(params[:id])
      server.name = params[:name]
      server.save!
      Serializers::Server.new(server)
    end


    params do
      requires :id, type: String
      requires :gameplay, type: Hash
    end
    put '/:id/gameplay' do
      server = Server.where(id: params[:id]).first!
      server.settings.merge! params[:gameplay]
      server.save!
      Serializers::Server.new(server)
    end


    params do
      requires :id, type: String
    end
    put '/:id/start' do
      server = Server.where(id: params[:id]).first!
      server.start!
    end


    params do
      requires :id, type: String
    end
    put '/:id/stop' do
      server = Server.where(id: params[:id]).first!
      server.stop!
    end


    params do
    end
    put '/:id/restart' do
      server = Server.where(id: params[:id]).first!
      server.restart!
    end

  end
end
