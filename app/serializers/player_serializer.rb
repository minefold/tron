require 'serializer'

class PlayerSerializer < Serializer

  def payload
    o = super
    o[:distinct_id] = object.distinct_id
    o[:username] = object.username
    o[:email] = object.email
    o[:created] = object.created
    o
  end

end
