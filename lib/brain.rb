class Brain
  def start_server(options={})
    # TODO validate options
    # Push start job
    BRAIN.with do |redis|
      redis.lpush "servers:requests:start", JSON.dump(options)
    end
    
    # Wait for the session become playable
    BRAIN.with do |redis|
      redis.subscribe(
          "sessions:started:#{options[:session_id]}", 
          "sessions:stopped:#{options[:session_id]}") do |on|
        on.message do |channel, msg|
          redis.unsubscribe
          
          return channel =~ /stopped/ ? 'crashed' : 'ok'
        end
      end
    end
  end
  
  def stop_server(options)
    # Push stop job
    BRAIN.with do |redis|
      redis.lpush "servers:requests:stop", options[:server_id]
    end
    
    # Wait for stop
    BRAIN.with do |redis|
      redis.subscribe("sessions:stopped:#{options[:session_id]}") do |on|
        on.message do |channel, exit_status|
          redis.unsubscribe
          return exit_status.to_i
        end
      end
    end
  end
end