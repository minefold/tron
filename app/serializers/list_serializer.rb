require 'serializer'

class ListSerializer < Serializer

  def data
    object.map do |obj|
      if obj.is_a?(Serializer)
        obj.payload
      else
        obj
      end
    end
  end

  def payload
    { object: 'list', count: object.length, data: data }
  end

end
