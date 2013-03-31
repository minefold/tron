require 'date'
require 'json'

class Serializer

  attr_reader :object

  def self.pipeline
    [:convert_keys_to_camel_case, :convert_timestamps_to_rfc3339]
  end

  def self.process_payload(payload)
    pipeline.inject(payload) {|p, method| send(method, p) }
  end

  def self.convert_keys_to_camel_case(payload)
    payload.each_with_object({}) do |(k,v), o|
      camel_key = k.to_s.gsub(/_([[:alnum:]])/) {|captures| captures[1].upcase }
      o[camel_key] = v
    end
  end

  def self.convert_timestamps_to_rfc3339(payload)
    payload.each_with_object({}) do |(k,v), o|
      o[k] = case v
             when DateTime
               v.rfc3339.to_s
             when Time
               v.to_date.rfc3339.to_s
             else
               v
             end
    end
  end

# --

  def initialize(object)
    @object = object
  end

  def payload
    { id: object.id.to_s, object: object.class.name.to_s.downcase }
  end

  def to_json(*args)
    self.class.process_payload(payload).to_json(*args)
  end

end
