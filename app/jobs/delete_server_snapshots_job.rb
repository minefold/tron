require 'aws-sdk'

class DeleteServerSnapshotsJob
  include Sidekiq::Worker

  def perform(legacy_server_id)
    bucket = s3.buckets['minefold-production']
    bucket.as_tree(prefix: "worlds/#{legacy_server_id}").children.each{|o| delete(o) }
    bucket.as_tree(prefix: "world-backups/#{legacy_server_id}").children.each{|o| delete(o) }
    s3.buckets['minefold-production-worlds'].as_tree(prefix: legacy_server_id).children.each{|o| delete(o) }
  end

  def delete(o)
    puts "DEL #{o.key}"
    o.member.delete
  end

  def s3
    @s3 ||= ::AWS::S3.new(
      access_key_id: ENV['AWS_ACCESS_KEY'],
      secret_access_key: ENV['AWS_SECRET_KEY']
    )
  end
end
