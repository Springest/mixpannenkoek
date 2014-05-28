require 'mixpannenkoek/class_inheritable_attribute'

module Mixpannenkoek
  class Base
    extend ::Mixpannenkoek::ClassInheritableAttribute
    class_inheritable_attribute :_api_key, :_api_secret, :_endpoint, :_default_scope

    def self.set_api_key(api_key = nil, &block)
      self._api_key = value_or_block(api_key, &block)
    end

    def self.set_api_secret(api_secret = nil, &block)
      self._api_secret = value_or_block(api_secret, &block)
    end

    def self.set_endpoint(endpoint = nil, &block)
      self._endpoint = value_or_block(endpoint, &block)
    end

    def self.api_key
      value_from_block(self._api_key)
    end

    def self.api_secret
      value_from_block(self._api_secret)
    end

    def self.endpoint
      value_from_block(self._endpoint)
    end

    ### Class methods (for convenience)
    #
    # these methods enable this type of usage:
    # Mixpanel::Query.where(training_name: 'Training XYZ').group('subject_name').results
    #
    ###
    def self.where(condition)
      Mixpannenkoek::Query.new(self).where(condition)
    end

    def self.set(variable)
      Mixpannenkoek::Query.new(self).set(variable)
    end

    def self.group(field)
      Mixpannenkoek::Query.new(self).group(field)
    end
    ###
    ### End class methods

    def self.default_scope(&proc_or_lambda)
      self._default_scope ||= []
      self._default_scope += [proc_or_lambda]
    end

    def self.default_scopes
      self._default_scope ||= []
      self._default_scope.map{ |p| p.call }
    end

    private
    def self.value_or_block(value, &block)
      raise ArgumentError unless !!value ^ !!block
      value || block
    end

    def self.value_from_block(value_or_proc)
      value_or_proc.respond_to?(:call) ? value_or_proc.call : value_or_proc
    end
  end
end
