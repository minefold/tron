require 'controller'
require 'securerandom'
require 'brain'

class SnapshotsController < Controller
  delete '/servers/:id/snapshots' do
    authenticate!
    param :id, String, required: true, is: ID_PATTERN, :coerce => :downcase

    server = Server.where(id: params[:id], account: account).first

    if server.nil?
      halt 404
    end

    DeleteServerSnapshots.perform_async(server.legacy_id)

    status 200
  end
end
