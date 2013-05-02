require 'serializer'

class ServerSerializer < Serializer

  def payload
    o = super
    o[:legacy_id] = object.legacy_id

    o[:name] = object.name

    o[:state] = object.state_name.to_s

    if object.owner
      o[:owner] = PlayerSerializer.new(object.owner)
    end

    o[:funpack] = FunpackSerializer.new(object.funpack)
    o[:region] = RegionSerializer.new(object.region)

    o[:created] = object.created

    if object.up?
      o[:ip] = object.session.ip
      o[:port] = object.session.port
    end

    o
  end

end
