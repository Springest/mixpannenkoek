require 'mixpannenkoek/class_inheritable_attribute'

module Mixpannenkoek
  class Base
    extend ::Mixpannenkoek::ClassInheritableAttribute
    class_inheritable_attribute :_api_key, :_api_secret, :_endpoint, :_default_scope

    # Public: the mixpanel api key
    def self.set_api_key(api_key = nil, &block)
      raise ArgumentError if !api_key.nil? && !block.nil?
      self._api_key = api_key || block
    end

    def self.api_key
      self._api_key.respond_to?(:call) ? self._api_key.call : self._api_key
    end

    # Public: the mixpanel api secret
    def self.set_api_secret(api_secret = nil, &block)
      raise ArgumentError if !api_secret.nil? && !block.nil?
      self._api_secret = api_secret || block
    end

    def self.api_secret
      self._api_secret.respond_to?(:call) ? self._api_secret.call : self._api_secret
    end

    def self.set_endpoint(endpoint = nil, &block)
      raise ArgumentError if !endpoint.nil? && !block.nil?
      self._endpoint = endpoint || block
    end

    def self.endpoint
      self._endpoint.respond_to?(:call) ? self._endpoint.call : self._endpoint
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
  end
end
