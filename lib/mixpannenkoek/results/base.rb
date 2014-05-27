module Mixpannenkoek
  module Results
    class Base
      def initialize(response_data)
        @response_data = response_data
      end

      def response_data
        @response_data
      end

      def to_hash
        @response_data
      end

      def method_missing(*args, &block)
        to_hash.send(*args, &block)
      end
    end
  end
end
