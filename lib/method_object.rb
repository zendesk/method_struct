require "method_object/version"

module MethodObject
  def self.new(action, *fields)
    Class.new do
      define_singleton_method(action) do |*field_values|
        new(*field_values).perform
      end

      define_method(:initialize) do |*values|
        fields.zip(values).each do |field, value|
          instance_variable_set("@#{field}", value)
        end
      end

      private
      fields.each do |field|
        attr_reader(field)
      end
    end
  end
end
