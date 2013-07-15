require "method_struct/version"

module MethodStruct
  def self.new(*fields)
    Class.new do
      define_singleton_method(:call) do |*field_values|
        new(*field_values).call
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
