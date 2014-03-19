require "method_struct/version"

module MethodStruct
  def self.new(*fields)
    if fields.last.is_a?(Hash)
      method_name = fields.last[:method_name]
      fields = fields.take(fields.size - 1)
    else
      method_name = :call
    end

    Class.new do
      singleton_class = (class << self; self; end)

      singleton_class.instance_eval do
        define_method(method_name) do |*field_values|
          new(*field_values).send(method_name)
        end
      end

      define_method(:initialize) do |*values|
        if fields.size > 1 && values.size == 1 && values.first.is_a?(Hash)
          fields.each do |field|
            instance_variable_set("@#{field}", values.first[field])
          end
        else
          fields.zip(values).each do |field, value|
            instance_variable_set("@#{field}", value)
          end
        end
      end

      define_method(:==) do |other|
        self.class == other.class && fields.all? do |field|
          send(field) == other.send(field)
        end
      end
      alias_method :eql?, :==

      define_method(:hash) do
        fields.map { |field| send(field).hash }.inject(&:^)
      end

      protected
      fields.each do |field|
        attr_reader(field)
      end
    end
  end
end
