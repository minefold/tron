require 'job'

class LegacySessionStoppedJob < Job
  def initialize(server_id, ts)
    @server_id = server_id
    @ts = ts
  end

  def work    
    if server = Server.where(legacy_id: @server_id).first
      if session = server.session
        Resque.enqueue SessionStoppedJob, session.id, @ts
      end
    end
  end

end
