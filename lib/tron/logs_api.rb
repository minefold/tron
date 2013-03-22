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
      # auth = Rack::Auth::Basic::Request.new(env)
      # p env, auth
      
      # p auth.credentials
      # user = User.where(authentication_token: auth.credentials.first).first
      #
      # server = if user.admin?
      server = Server.where(id: @server_id).first!
      # else
      #   Server.where(id: @server_id, creator: user).first!
      # end

      EM.next_tick do
        EM::Mongo::Tail.collection(db, "logs_#{server.party_cloud_id}") do |doc|
          sorted = {}
          sorted['ts'] = doc.delete('ts') if doc['ts']
          sorted['event'] = doc.delete('event') if doc['event']
          sorted.merge!(doc)

          env.stream_send(sorted.to_json + "\n")
        end
      end

      streaming_response(202, {
        'Content-Type' => 'application/json',
        'Access-Control-Allow-Origin' => env['HTTP_ORIGIN'],
        'Access-Control-Allow-Credentials' => 'true',
      })
    end

    def db
      @db ||= Mongo::Connector.db
    end
  end
end
