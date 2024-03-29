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

    # keep 2 secondies
    ingroup, outgroup = snaps.take_time_group(2, second)
    keep += ingroup
    delete += outgroup

    # keep 1 hourlies
    ingroup, outgroup = snaps.take_time_group(1, hour)
    keep += ingroup
    delete += outgroup

    # keep 1 dailies
    ingroup, outgroup = snaps.take_time_group(1, day)
    keep += ingroup
    delete += outgroup

    # keep 1 weeklies
    ingroup, outgroup = snaps.take_time_group(1, week)
    keep += ingroup
    delete += outgroup

    # delete the rest
    delete += snaps

    if keep.any? # only delete if we're keeping something. Safeguards against me fucking up
      delete.each do |snap|
        snap.delete!
      end
    end
  end
end
