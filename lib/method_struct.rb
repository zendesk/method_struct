require "method_struct/version"

module MethodStruct
  def self.new(*fields)
    Class.new do
      class << self
        define_method(:call) do |*field_values|
          new(*field_values).call
        end
      end

      define_method(:initialize) do |*values|
        if fields.size > 1 && values.first.is_a?(Hash)
          fields.each do |field|
            instance_variable_set("@#{field}", values.first[field])
          end
        else
          fields.zip(values).each do |field, value|
            instance_variable_set("@#{field}", value)
          end
        end
      end

      private
      fields.each do |field|
        attr_reader(field)
      end
    end
  end
end
