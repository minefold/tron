class SessionStartedJob

  # session_id
  # ts
  # ip
  # port

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

    # TODO Publish to web
  end

end
