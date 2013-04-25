class LegacyPlayerSessionStoppedJob
  include Sidekiq::Worker
  
  def perform(server_id, ts, distinct_id, username)
    if server = Server.where(legacy_id: server_id).first
      if session = server.session
        if player = Player.where(distinct_id: distinct_id).first
          if player_session = PlayerSession.where(session: session, player: player).first
            PlayerSessionStoppedJob.perform_async player_session.id, ts
          end
        end
      end
    end
  end
end