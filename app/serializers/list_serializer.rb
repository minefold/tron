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

class PaginatedListSerializer < ListSerializer
  def initialize(total, limit, offset, object)
    @total = total
    @limit = limit
    @offset = offset
    super(object)
  end

  def payload
    { object: 'list', count: object.length, data: data, total: @total, offset: @offset }
  end

end
