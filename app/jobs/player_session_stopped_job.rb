require 'securerandom'

class PlayerSessionStoppedJob
  include Sidekiq::Worker

  def perform(player_session_id, ts)
    @player_session_id = player_session_id
    @ts = ts

    work
  end

  def work
    @player_session = PlayerSession[@player_session_id]
    @time = DateTime.rfc3339(@ts)

    @player_session.stopped = @time

    # TODO Rescue save failure
    @player_session.save
  end

end
