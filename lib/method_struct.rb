require "method_struct/version"
require "method_struct/defaults"
require "method_struct/argument_verifier"
require "method_struct/argument_parser"

module MethodStruct
  def self.new(*fields, &block)
    if fields.last.is_a?(Hash)
      options = fields.last
      fields = fields.take(fields.size - 1)
    else
      options = {}
    end

    unless fields.all?{ |f| f.is_a?(Symbol) }
      invalid_fields = fields.select{ |f| !f.is_a?(Symbol) }
      raise ArgumentError, "only symbol fields allowed: #{invalid_fields.inspect}"
    end

    method_name = options.fetch(:method_name, Defaults.get[:method_name])
    require_all = options.fetch(:require_all, Defaults.get[:require_all])
    require_presence = options.fetch(:require_presence, Defaults.get[:require_presence])

    Class.new do
      singleton_class = (class << self; self; end)

      singleton_class.instance_eval do
        define_method(method_name) do |*field_values, &blk|
          new(*field_values).send(method_name, &blk)
        end

        define_method(:[]) do |*args|
          send(method_name, *args)
        end

        define_method(:to_proc) do
          Proc.new { |*args| send(method_name, *args) }
        end
      end

      define_method(:[]) do |&blk|
        send(method_name, &blk)
      end

      define_method(:initialize) do |*values|
        arguments = ArgumentParser.new(
          :fields => fields,
          :raw_arguments => values,
          :require_all => require_all,
          :require_presence => require_presence
        ).call

        arguments.each do |field, value|
          instance_variable_set("@#{field}", value)
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

      fields.each do |field|
        attr_reader(field)
        protected field
      end

      class_eval(&block) if block_given?
    end
  end
end
