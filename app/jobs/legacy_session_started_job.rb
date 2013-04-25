class LegacySessionStartedJob
  include Sidekiq::Worker
  
  def perform(server_id, ts, ip, port)
    if server = Server.where(legacy_id: server_id).first
      if session = server.session
        SessionStartedJob.perform_async session.id, DateTime.rfc3339(ts).rfc3339, ip, port
      end
    end
  end
end