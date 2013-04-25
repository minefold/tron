class LegacyPlayerSessionStartedJob
  include Sidekiq::Worker
  
  def perform(server_id, ts, distinct_id, username)
    if server = Server.where(legacy_id: server_id).first
      if session = server.session
        PlayerSessionStartedJob.perform_async session.id, ts, distinct_id, username, nil
      end
    end
  end
end