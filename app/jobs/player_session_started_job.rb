require 'securerandom'

class PlayerSessionStartedJob
  include Sidekiq::Worker

  def perform(session_id, ts, distinct_id, username, email)
    @session_id = session_id
    @ts = ts
    @distinct_id = distinct_id
    @username = username
    @email = email

    work
  end

  def work
    @session = Session[@session_id]
    @time = DateTime.rfc3339(@ts)

    # Upsert Player data
    @player = Player.where(distinct_id: @distinct_id).first

    if @player.nil?
      @player = Player.new(
        id: SecureRandom.uuid,
        account_id: @session.server.account.id,
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
