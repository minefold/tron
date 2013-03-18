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

      EM.next_tick do
        EM::Mongo::Tail.collection(collection) do |doc|
          sorted = {}
          sorted['ts'] = doc.delete('ts') if doc['ts']
          sorted['event'] = doc.delete('event') if doc['event']
          sorted.merge!(doc)
          
          env.stream_send(sorted.to_json + "\n")
        end
      end

      streaming_response(202, {
        'Content-Type' => 'application/json'
      })
    end

    def db
      @db ||= Mongo::Connector.db
    end
  end
end
