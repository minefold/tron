class Brain
  def start_server(options={})
    # TODO validate options
    # Push start job
    BRAIN.with do |redis|
      redis.lpush "servers:requests:start", JSON.dump(options)
    end
    
    # Wait for the session become playable
    BRAIN.with do |redis|
      redis.subscribe("sessions:started:#{options[:session_id]}") do |on|
        on.message do |channel, msg|
          redis.unsubscribe
          return msg == 'ok'
        end
      end
    end
  end
  
  def stop_server(server_id)
    # Push stop job
    BRAIN.with do |redis|
      redis.lpush "servers:requests:stop", server_id
    end
    
    # Wait for stop
    BRAIN.with do |redis|
      redis.subscribe("servers:requests:stop:#{server_id}") do |on|
        on.message do |channel, msg|
          redis.unsubscribe
          return StopResult.new
        end
      end
    end
  end
end

class StopResult < Hash
  def success?
    true
  end
end
