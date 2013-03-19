require 'mongo'

module EventMachine
  module Mongo
    class Tail
      def self.collection(db, collection_name, *a, &b)
        new(db, collection_name, EM::Callback(*a, &b))
      end

      def initialize(db, collection_name, cb)
        @db = db
        @collection_name = collection_name

        @cb = cb

        next_doc
      end

      def tail
        @tail ||= begin
          ::Mongo::Cursor.new(
            @db.collection(@collection_name),
            tailable: true,
            order: [['$natural', 1]]
          )
        end
      end

      def next_doc
        if tail.has_next?
          doc = nil
          begin
            doc = tail.next_document
            @cb.call(doc)
            EM.next_tick method(:next_doc)

          rescue ::Mongo::OperationFailure => e
            @tail = nil
            EM.add_timer(1, method(:next_doc))
          end

        else
          EM.add_timer(1, method(:next_doc))
        end
      end
    end
  end
end
