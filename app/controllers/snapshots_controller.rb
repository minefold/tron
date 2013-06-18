require 'controller'
require 'securerandom'
require 'brain'

class SnapshotsController < Controller
  def find_server(id)
    if params[:id] =~ /legacy-([0-9a-f]+)/
      Server.where(legacy_id: $1, account: account).first
    else
      Server.where(id: params[:id], account: account).first
    end
  end

  post '/servers/:id/snapshots/compact' do
    authenticate!
    param :id, String, required: true, :coerce => :downcase

    server = find_server(params[:id])

    if server.nil?
      halt 404
    end

    CompactServerSnapshotsJob.perform_async(server.legacy_id)

    status 200
  end


  delete '/servers/:id/snapshots' do
    authenticate!
    param :id, String, required: true, :coerce => :downcase

    server = find_server(params[:id])

    if server.nil?
      halt 404
    end

    DeleteServerSnapshotsJob.perform_async(server.legacy_id)

    status 200
  end
end
