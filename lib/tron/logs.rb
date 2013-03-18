require 'em-synchrony/mongo'
require 'mongo/connector'
require 'eventmachine/mongo/tail'

module Tron
  class Logs < Goliath::API
    def self.call(env)
      if env['REQUEST_PATH'] =~ /(\w+)\/logs$/
        new($1).call(env)
      end
    end

    def initialize(server_id)
      @server_id = server_id
    end

    def response(env)
      collection = db.collection("logs_#{@server_id}")

      EM::Mongo::Tail.collection(collection) do |doc|
        env.chunked_stream_send(doc.to_json + "\n")
      end

      headers = { 'Content-Type' => 'text/plain', 'X-Stream' => 'Goliath' }
      chunked_streaming_response(200, headers)
    end

    def db
      @db ||= Mongo::Connector.db
    end
  end
end
