require 'serializer'

class ServerSerializer < Serializer

  def payload
    o = super

    o[:name] = object.name

    o[:state] = object.state_name.to_s

    if object.owner
      o[:owner] = object.owner_id.to_s
    end

    o[:funpack] = object.funpack_id.to_s

    o[:created] = object.created

    if object.up?
      o[:ip] = object.session.ip
      o[:port] = object.session.port
    end

    o
  end

end
