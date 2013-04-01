require 'serializer'

class FunpackSerializer < Serializer

  def payload
    o = super
    o[:name] = object.name
    o[:servers] = object.server_count
    o
  end

end
