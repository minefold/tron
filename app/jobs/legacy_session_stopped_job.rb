class LegacySessionStoppedJob
  include Sidekiq::Worker
  
  def perform(server_id, ts)
    if server = Server.where(legacy_id: server_id).first
      if session = server.session
        SessionStoppedJob.perform_async session.id, DateTime.rfc3339(ts).rfc3339
      end
    end
  end

end
