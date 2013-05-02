class LegacySessionStartedJob
  include Sidekiq::Worker

  def perform(server_id, ts, ip, port)
    if server = Server.where(legacy_id: server_id).first
      if server.up? || server.starting?
        return
      end

      session = Session.new(id: SecureRandom.uuid, server: server)

      # TODO Rescue transaction failure
      DB.transaction do
        session.save
        server.start!
      end

      SessionStartedJob.perform_async session.id, DateTime.rfc3339(ts).rfc3339, ip, port
    end
  end
end
