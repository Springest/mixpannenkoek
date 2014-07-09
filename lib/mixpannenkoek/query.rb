require 'rubygems'
require 'mixpanel_client'

module Mixpannenkoek
  class Query
    class MissingRange < Exception; end
    class MissingConfiguration < Exception; end

    attr_accessor :where, :group, :klass

    def initialize(klass, where = {}, where_not = {}, vars = {}, group = nil)
      @where = where
      @where_not = where_not
      @vars  = vars
      @group = group
      @klass = klass
    end

    def where(condition = nil)
      return self if condition.nil?
      chain(where: @where.merge(condition))
    end

    def not(condition)
      chain(where_not: @where_not.merge(condition))
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

      if (@where && @where != {}) || (@where_not && @where_not != {})
        query[:where] = []

        extract_dates(query, @where)

        query[:where] += @where.map do |key,value|
          where_clause(key, value)
        end

        query[:where] += @where_not.map do |key,value|
          where_not_clause(key, value)
        end

        if query[:where].compact != []
          query[:where] = query[:where].compact.join(' and ')
        else
          query.delete(:where)
        end
      end

      query[:on] = %Q(properties["#{@group}"]) if @group

      query
    end

    private

    def chain(klass: @klass, where: @where, where_not: @where_not, vars: @vars, group: @group)
      self.class.new(klass, where, where_not, vars, group)
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

    def extract_dates(query, where)
      return unless where[:date]

      query[:from_date] = where[:date].first
      query[:to_date] = where[:date].last

      query[:from_date] = query[:from_date].strftime('%Y-%m-%d') if query[:from_date].respond_to? :strftime
      query[:to_date] = query[:to_date].strftime('%Y-%m-%d') if query[:to_date].respond_to? :strftime
    end

    def where_clause(key, value, operator = '==', join = 'or')
      return nil if key == :date

      case value
      when Array
        %Q((#{value.map { |val| %Q(properties["#{key}"] #{operator} "#{val}") }.join(" #{join} ")}))
      else
        %Q(properties["#{key}"] #{operator} "#{value}")
      end
    end

    def where_not_clause(key, value)
      where_clause(key, value, '!=', 'and')
    end
  end
end
