require 'securerandom'

require 'job'
require 'models/session'
require 'models/player'
require 'models/player_session'

class PlayerSessionStartedJob < Job

  def initialize(session_id, ts, distinct_id, username, email)
    @session_id = session_id
    @ts = ts
    @distinct_id = distinct_id
    @username = username
    @email = email
  end

  def work
    @session = Session[@session_id]
    @time = DateTime.rfc3339(@ts)

    # Upsert Player data
    @player = Player.where(distinct_id: @distinct_id).first

    if @player.nil?
      @player = Player.new(
        id: SecureRandom.uuid,
        distinct_id: @distinct_id,
        username: @username,
        email: @email
      )
    else
      @player.username = @username || @player.username
      @player.email = @email || @player.email
    end

    # TODO Rescue save failure
    @player.save

    @player_session = PlayerSession.new(
      id: SecureRandom.uuid,
      session: @session,
      player: @player,
      started: @time
    )

    # TODO Rescue save failure
    @player_session.save
  end

end
