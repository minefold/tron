require 'json'

class Serializer

  attr_reader :object

  def initialize(object)
    @object = object
  end

  def payload
    { id: object.id, object: object.class.name.to_s.downcase }
  end

  def to_json(*args)
    payload.to_json(*args)
  end

end
