class SessionStartedJob

  # session_id
  # ts
  # ip
  # port

  def initialize(session_id, ts, ip, port)
    @session_id = session_id
    @ts = ts
    @ip = ip
    @port = port
  end

  def work
    @session = Session[@session_id]
    @time = DateTime.rfc3339(@ts)

    @session.started = @time
    @session.ip = @ip
    @session.port = @port

    # TODO Rescue transaction failure
    DB.transaction do
      @session.save
      @session.server.started!
    end

    Redis.new.publish("sessions:started:#{@session.id}", 'ok')
  end

end
