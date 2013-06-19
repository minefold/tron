require 'aws-sdk'
require 'snapshots'

class Array
  def take_time_group(count, seconds)
    ingroup = []
    outgroup = []

    ts = nil
    while ingroup.size < count && item = pop
      diff = ts - item.ts if ts
      # puts "#{ts} - #{item.ts} = #{diff} >= #{seconds} #{diff >= seconds if ts}"
      if ts.nil? || diff >= seconds
        ts = item.ts
        ingroup << item
      else
        outgroup << item
      end
    end
    [ingroup, outgroup]
  end
end

class CompactServerSnapshotsJob
  include Sidekiq::Worker

  def perform(legacy_server_id)
    snaps = Snapshots.collect_from_aws(legacy_server_id)

    keep = []
    delete = []

    second = 1
    minute = second * 60
    hour   = minute * 60
    day    = hour * 24
    week   = day * 7

    # keep 6 hourlies
    ingroup, outgroup = snaps.take_time_group(6, hour)
    keep += ingroup
    delete += outgroup

    # keep 7 dailies
    ingroup, outgroup = snaps.take_time_group(7, day)
    keep += ingroup
    delete += outgroup

    # keep 4 weeklies
    ingroup, outgroup = snaps.take_time_group(4, week)
    keep += ingroup
    delete += outgroup

    # delete the rest
    delete += snaps

    # keep 7 dailies
    puts "#{legacy_server_id}: KEEP #{keep.map(&:ts)}"
    delete.each do |snap|
      snap.delete!
    end
  end
end
