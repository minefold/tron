module Mongo
  class Connector
    def self.db
      @db ||= begin
        conn = URIParser.new(ENV['MONGODB_URI']).connection({})

        if conn.is_a? MongoReplicaSetClient
          # this should be in the damn ruby driver
          mongo_uri = URIParser.new(ENV['MONGODB_URI'])
          auth = mongo_uri.auths.first

          db = conn[auth['db_name']]
          db.authenticate auth['username'], auth['password']
          db
        else
          db_name = conn.auths.any? ? conn.auths.first['db_name'] : nil
          db_name ||= URI.parse(ENV['MONGODB_URI']).path[1..-1]
          conn[db_name]
        end
      end
    end
  end
end