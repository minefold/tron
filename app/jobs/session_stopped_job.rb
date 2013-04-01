class SessionStoppedJob

  # session_id
  # ts

  def work
    @session = Session[@session_id]
    @time = DateTime.rfc3339(@ts)

    @session.stopped = @time

    # TODO Rescue transaction failure
    DB.transaction do
      @session.save
      @session.server.stopped!
    end
  end

end
