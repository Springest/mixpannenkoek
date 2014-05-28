module Mixpannenkoek
  module ClassInheritableAttribute
    def class_inheritable_attribute(*attributes)
      attributes.map(&:to_sym).each do |attribute|
        create_setter(attribute)
        create_getter(attribute)
      end
    end

    def create_setter(attribute)
      define_singleton_method("#{attribute}=") do |value|
        @@class_inheritable_attributes ||= {}
        @@class_inheritable_attributes[attribute] ||= {}

        @@class_inheritable_attributes[attribute][self.name] = value
      end
    end

    def create_getter(attribute)
      define_singleton_method(attribute) do
        if @@class_inheritable_attributes[attribute] && @@class_inheritable_attributes[attribute].has_key?(self.name)
          @@class_inheritable_attributes[attribute][self.name]
        elsif superclass.respond_to?(attribute)
          superclass.send(attribute)
        else
          nil
        end
      end
    end
  end
end
