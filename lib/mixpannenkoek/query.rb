require 'rubygems'
require 'mixpanel_client'

module Mixpannenkoek
  class Query
    class MissingRange < Exception; end
    class MissingConfiguration < Exception; end

    attr_accessor :where, :group, :klass

    def initialize(klass, where = {}, vars = {}, group = nil)
      @where = where
      @vars  = vars
      @group = group
      @klass = klass
    end

    def where(condition)
      chain(where: @where.merge(condition))
    end

    def set(variable)
      chain(vars: @vars.merge(variable))
    end

    def group(field)
      chain(group: field)
    end

    def results
      Mixpannenkoek::Results.new(@klass.endpoint, response_data)
    end

    def request_parameters
      [@klass.endpoint, query_with_default_scopes]
    end

    def method_missing(*args, &block)
      results.send(*args, &block)
    end

    def query_with_default_scopes
      (@klass.default_scopes.map(&:query) + [query]).inject({}) do |final_query,query|
        where = [final_query[:where], query.delete(:where)].compact.reject(&:empty?).compact
        final_query[:where] =
          if where.count > 1
            "(#{where.join(' and ')})"
          else
            where.first
          end

        final_query.merge(query)
      end
    end

    def query
      query = @vars

      if @where && @where != {}
        if @where[:date]
          query[:from_date] = @where[:date].first.strftime('%Y-%m-%d')
          query[:to_date] = @where[:date].last.strftime('%Y-%m-%d')
        end

        query[:where] = @where.map do |key,value|
          next if key == :date

          case value
          when Array
            %Q((#{value.map { |val| %Q(properties["#{key}"] == "#{val}") }.join(' or ')}))
          else
            %Q(properties["#{key}"] == "#{value}")
          end
        end.compact

        query[:where] =
          if query[:where]
            query[:where].join(' and ')
          else
            nil
          end
      end

      query[:on] = %Q(properties["#{@group}"]) if @group

      query
    end

    private

    def chain(klass: @klass, where: @where, vars: @vars, group: @group)
      self.class.new(klass, where, vars, group)
    end

    def mixpanel_client
      Mixpanel::Client.new(
        api_key:    @klass.api_key,
        api_secret: @klass.api_secret
      )
    end

    def check_parameters
      raise MissingRange if query_with_default_scopes[:from_date].nil? && query_with_default_scopes[:to_date].nil?
      raise MissingConfiguration.new('The mixpanel api_key has not been configured') if @klass.api_key.nil?
      raise MissingConfiguration.new('The mixpanel api_secret has not been configured') if @klass.api_secret.nil?
    end

    def response_data
      check_parameters
      log do
        @mixpanel_request ||= mixpanel_client.request(*request_parameters)
      end
      @mixpanel_request
    end

    def log(&block)
      return block.call unless defined?(::Benchmark)
      time = ::Benchmark.ms(&block)
      Rails.logger.info "  Mixpanel (#{time.round(1)}ms) #{request_parameters.inspect}" if defined? Rails
    end
  end
end
