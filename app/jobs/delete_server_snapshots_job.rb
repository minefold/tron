require 'aws-sdk'

class DeleteServerSnapshotsJob
  include Sidekiq::Worker

  def perform(legacy_server_id)
    Snapshots.collect_from_aws(legacy_server_id).each{|s| s.delete! }
  end
end
