class SessionStoppedJob
  include Sidekiq::Worker

  def perform(session_id, ts, exit_status)
    @session_id = session_id
    @ts = ts
    @exit_status = exit_status

    work
  end

  def work
    @session = Session[@session_id]
    @time = DateTime.rfc3339(@ts)

    @session.stopped = @time
    @session.exit_status = @exit_status

    # TODO Rescue transaction failure
    DB.transaction do
      @session.save
      @session.server.stop!
    end
    
    Redis.new.publish("sessions:stopped:#{@session.id}", @exit_status)
  end
end
