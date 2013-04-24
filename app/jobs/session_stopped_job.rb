class SessionStoppedJob
  include Sidekiq::Worker

  def perform(session_id, ts)
    @session_id = session_id
    @ts = ts

    work
  end

  def work
    @session = Session[@session_id]
    @time = DateTime.rfc3339(@ts)

    @session.stopped = @time

    # TODO Rescue transaction failure
    DB.transaction do
      @session.save
      @session.server.stop!
    end
  end

end
