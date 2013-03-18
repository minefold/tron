require 'mongo'

module EventMachine
  module Mongo
    class Tail
      def self.collection(collection, *a, &b)
        new(collection, EM::Callback(*a, &b))
      end

      def initialize(collection, cb)
        @tail ||= ::Mongo::Cursor.new(
          collection,
          tailable: true,
          order: [['$natural', 1]]
        )
        @cb = cb

        next_doc
      end

      def next_doc
        if @tail.has_next?
          doc = nil
          begin
            doc = @tail.next_document
            @cb.call(doc)
            EM.next_tick method(:next_doc)

          rescue ::Mongo::OperationFailure
            EM.add_timer(1, method(:next_doc))
          end

        else
          EM.add_timer(1, method(:next_doc))
        end
      end
    end
  end
end