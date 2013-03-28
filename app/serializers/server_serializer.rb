require 'serializer'
require 'ipaddr'

class ServerSerializer < Serializer

  def payload
    o = super

    o[:name] = object.name

    o[:state] = object.state_name

    if object.owner
      o[:owner] = object.owner_id.to_s
    end

    o[:funpack] = object.funpack_id.to_s

    o[:created] = object.created
    o[:updated] = object.updated

    # o[:state] = object.state_name
    # o[:gameplay] = object.settings

    # o[:access] = object.access_policy.name

    # o[:players] = object.players.count

    # if object.up?
    #   o[:ip] = object.ip
    #   o[:port] = object.port
    # end

    o
  end

end
