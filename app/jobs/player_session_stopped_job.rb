require 'securerandom'

require 'job'
require 'models/player_session'

class PlayerSessionStoppedJob < Job

  def initialize(player_session_id, ts)
    @player_session_id = player_session_id
    @ts = ts
  end

  def work
    @player_session = PlayerSession[@player_session_id]
    @time = DateTime.rfc3339(@ts)

    @player_session.stopped = @time


    # TODO Rescue save failure
    @player_session.save
  end

end
