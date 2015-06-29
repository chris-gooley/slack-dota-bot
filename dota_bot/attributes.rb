module DotaBot
  module Attributes
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def attribute(*attributes)
        @_attributes = attributes.map(&:to_s)

        attributes.each do |attribute|
          attr_accessor attribute
        end
      end
    end

    def initialize(attrs={})
      self.attributes = attrs
    end

    def attributes=(attrs={})
      attrs.each { |k,v| send("#{k}=", v) if self.class.method_defined?("#{k}=") }
    end

    def inspect
      inspection = if self.class.instance_variable_get("@_attributes")
        self.class.instance_variable_get("@_attributes").map do |name|
          "#{name}: #{send(name) || 'nil'}"
        end.compact.join(', ')
      else
        'not initialized'
      end

      "#<#{self.class} #{inspection}>"
    end
  end
end
