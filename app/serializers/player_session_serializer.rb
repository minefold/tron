require 'serializer'

class PlayerSessionSerializer < Serializer

  def payload
    o = super
    o[:started] = object.started
    o[:stopped] = object.stopped
    o
  end

end
