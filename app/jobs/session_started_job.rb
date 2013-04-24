class SessionStartedJob
  include Sidekiq::Worker

  def perform(session_id, ts, ip, port)
    @session_id = session_id
    @ts = ts
    @ip = ip
    @port = port

    work
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
    
    puts "publishing sessions:started:#{@session.id}"

    Redis.new.publish("sessions:started:#{@session.id}", 'ok')
  end

end
