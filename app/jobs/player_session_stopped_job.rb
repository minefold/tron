require 'securerandom'

class PlayerSessionStoppedJob

  # player_session_id
  # ts

  def work
    @player_session = PlayerSession[@player_session_id]
    @time = DateTime.rfc3339(@ts)

    @player_session.stopped = @time


    # TODO Rescue save failure
    @player_session.save
  end

end
