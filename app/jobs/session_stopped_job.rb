require 'job'

class SessionStoppedJob < Job
  @queue = :high

  def initialize(session_id, ts)
    @session_id = session_id
    @ts = ts
  end

  def work
    @session = Session[@session_id]
    @time = Time.at(@ts)

    @session.stopped = @time

    # TODO Rescue transaction failure
    DB.transaction do
      @session.save
      @session.server.stop!
    end
  end

end
