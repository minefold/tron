require 'json'

class Serializer

  attr_reader :object

  def self.camel_case_keys(obj)
    obj.each_with_object({}) do |(k,v), o|
      camel_key = k.to_s.gsub(/_([[:alnum:]])/) {|captures| captures[1].upcase }
      o[camel_key] = v
    end
  end

  def initialize(object)
    @object = object
  end

  def payload
    { id: object.id.to_s, object: object.class.name.to_s.downcase }
  end

  def to_json(*args)
    self.class.camel_case_keys(payload).to_json(*args)
  end

end
