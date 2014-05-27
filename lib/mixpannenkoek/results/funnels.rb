require 'mixpannenkoek/results/base'

module Mixpannenkoek
  module Results
    class Funnels < Base
      def initialize(response_data)
        @response_data = response_data
      end

      def to_hash
        super['data']
      end
    end
  end
end
