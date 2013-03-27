require 'serializer'

module Serializers
  class User < Serializer

    attribute :id
    attribute :username

    def payload
      o = super
      o[:url] = "https://api.minefold.com/users/#{object.id}"

      o[:created] = object.created_at
      o[:updated] = object.updated_at

      o
    end

  end
end
