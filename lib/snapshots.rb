require 'aws-sdk'

class Snapshots
  attr_reader :node, :server_id, :ts

  def self.collect_from_aws(server_id)
    snapshots = []
    [
      ['minefold-production', "worlds/#{server_id}"],
      ['minefold-production', "world-backups/#{server_id}"],
      ['minefold-production-worlds', server_id],
      ['party-cloud-production', "worlds/#{server_id}"],
      ['party-cloud-production', "world-backups/#{server_id}"],
    ].each do |bucket, prefix|
      s3.buckets[bucket].as_tree(prefix: prefix).children.each do |o|
        ts = nil
        if o.key =~ /\.(\d{10})\./
          ts = Time.at($1.to_i)
          puts "#{o.key} #{ts}"
          snapshots << new(o.member, server_id, ts)
        else
          puts "WARN: no timestamp for #{o.key}. Ignoring file"
        end
      end
    end
    snapshots.sort_by{|s| s.ts.to_i }
  end

  def initialize(node, server_id, ts)
    @node = node
    @server_id = server_id
    @ts = ts
  end

  def delete!
    puts "DEL #{node.key} #{ts}"
    node.delete
  end

  def self.s3
    @s3 ||= ::AWS::S3.new(
      access_key_id: ENV['AWS_ACCESS_KEY'],
      secret_access_key: ENV['AWS_SECRET_KEY']
    )
  end
end