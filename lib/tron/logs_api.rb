require 'em-synchrony/mongo'
require 'mongo/connector'
require 'eventmachine/mongo/tail'

module Tron
  class LogsAPI < Goliath::API
    def self.call(env)
      if env['REQUEST_PATH'] =~ /(\w+)\/logs$/
        new($1).call(env)
      end
    end

    def initialize(server_id)
      @server_id = server_id
    end

    def response(env)
      server = Server.where(id: @server_id).first!

      collection = db.collection("logs_#{server.party_cloud_id}")

      EM::Mongo::Tail.collection(collection) do |doc|
        env.chunked_stream_send(doc.to_json + "\n")
      end

      chunked_streaming_response(200, {
        'Content-Type' => 'text/plain',
        'X-Stream' => 'Goliath'
      })
    end

    def db
      @db ||= Mongo::Connector.db
    end
  end
end
