require 'serializer'
require 'serializers/player_session_serializer'

class SessionSerializer < Serializer

  def payload
    o = super

    o[:end_on_empty] = true
    o[:created] = object.created
    o[:started] = object.started
    o[:stopped] = object.stopped

    o[:server] = object.server_id.to_s

    o[:players] = object.player_sessions.map do |session|
      PlayerSessionSerializer.new(session)
    end

    if object.started?
      o[:ip] = object.ip.to_s
      o[:port] = object.port.to_i
    end
    
    if object.stopped?
      o[:exit_status] = object.exit_status
    end
    
    o
  end

end
