module Mixpannenkoek
  module Results
    def self.new(endpoint, response_data)
      klass =
        case endpoint
        when 'funnels'
          Mixpannenkoek::Results::Funnels
        else
          Mixpannenkoek::Results::Base
        end
      klass.new(response_data)
    end
  end
end
