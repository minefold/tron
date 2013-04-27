class Brain
  attr_reader :redis

  def initialize(redis)
    @redis = redis
  end

  def subscriber
    @subscriber ||= Redis.new(:driver => :hiredis)
  end

  def start_server(options={})
    # TODO validate options
    # Push start job

    redis.lpush "servers:requests:start", JSON.dump(options)

    # Wait for the session become playable
    subscriber.subscribe(
        "sessions:started:#{options[:session_id]}",
        "sessions:stopped:#{options[:session_id]}") do |on|
      on.message do |channel, msg|
        subscriber.unsubscribe

        return channel =~ /stopped/ ? 'crashed' : 'ok'
      end
    end
  end

  def stop_server(options)
    # Push stop job
    redis.lpush "servers:requests:stop", options[:server_id]

    # Wait for stop
    subscriber.subscribe("sessions:stopped:#{options[:session_id]}") do |on|
      on.message do |channel, exit_status|
        subscriber.unsubscribe
        return exit_status.to_i
      end
    end
  end
end