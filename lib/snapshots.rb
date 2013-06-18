require 'aws-sdk'

class Snapshots
  def initialize(server_id)
    @server_id = server_id
  end

  def delete_all!
    tree = s3.buckets[map_tiles_bucket].as_tree
    tree.children.each do |child|
      PlayerSessionStartedJob.perform_async session.id, ts, distinct_id, username, nil
      TestMapWorker.perform_async(child.prefix)
    end
  end

  def s3
    @s3 ||= ::AWS::S3.new(
      access_key_id: ENV['AWS_ACCESS_KEY'],
      secret_access_key: ENV['AWS_SECRET_KEY']
    )
  end
end