require 'serializer'

class AccountSerializer < Serializer

  def payload
    o = super
    o[:email] = object.email
    o[:servers] = object.servers.count
    o[:up_servers] = object.up_servers.count
    o[:players] = 0
    o[:online_players] = 0
    o
  end

end
