require 'serializer'

class SessionSerializer < Serializer

  def payload
    o = super

    o[:end_on_empty] = true
    o[:created] = object.created
    o[:started] = object.started
    o[:stopped] = object.stopped

    o[:server] = object.server_id.to_s

    if object.started?
      o[:ip] = object.ip.to_s
      o[:ip] = object.port.to_s
    end

    o
  end

end
