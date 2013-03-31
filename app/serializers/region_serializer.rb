require 'serializer'

class RegionSerializer < Serializer

  def payload
    o = super
    o[:name] = object.name
    o
  end


end
