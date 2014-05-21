require "method_struct/version"
require "singleton"

module MethodStruct
  class Defaults
    include Singleton

    def self.set(options)
      instance.set(options)
    end

    def self.get
      instance.get
    end

    def initialize
      @defaults = {
        :method_name => :call,
        :allow_nil => true,
        :allow_missing => true
      }
    end

    def set(options)
      @defaults = @defaults.merge(options)
    end

    def get
      @defaults
    end
  end

  class ArgumentVerifier
    def initialize(fields, values, allow_missing, allow_nil)
      @fields, @values = fields, values
      @allow_missing, @allow_nil = allow_missing, allow_nil
    end

    def verify
      if fields.size > 1 && values.size == 1 && values.first.is_a?(Hash)
        verify_hash
      else
        verify_normal
      end
    end

    private
    attr_reader :fields, :values, :allow_missing, :allow_nil

    def verify_hash
      expected = fields.map(&:to_s).sort
      provided = values.first.keys.map(&:to_s).sort

      if !allow_missing && !(expected - provided).empty?
        raise ArgumentError.new("wrong arguments provided")
      end

      if !allow_nil && !expected.all? { |arg| values.first[arg] || values.first[arg.to_s] }
        raise ArgumentError.new("nil arguments provided")
      end
    end

    def verify_normal
      if !allow_missing && fields.count != values.count
        raise ArgumentError.new("wrong number of arguments (#{values.count} for #{fields.count})")
      end

      if !allow_nil && fields.count != values.compact.count
        raise ArgumentError.new("nil arguments provided")
      end
    end
  end

  def self.new(*fields, &block)
    if fields.last.is_a?(Hash)
      options = fields.last
      fields = fields.take(fields.size - 1)
    else
      options = {}
    end

    method_name = options.fetch(:method_name, Defaults.get[:method_name])
    allow_missing = options.fetch(:allow_missing, Defaults.get[:allow_missing])
    allow_nil = options.fetch(:allow_nil, Defaults.get[:allow_nil])

    Class.new do
      singleton_class = (class << self; self; end)

      singleton_class.instance_eval do
        define_method(method_name) do |*field_values, &blk|
          new(*field_values).send(method_name, &blk)
        end

        define_method(:[]) do |*args|
          send(method_name, *args)
        end
      end

      define_method(:[]) do |&blk|
        send(method_name, &blk)
      end

      define_method(:initialize) do |*values|
        ArgumentVerifier.new(fields, values, allow_missing, allow_nil).verify

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

      class_eval(&block) if block_given?

      protected
      fields.each do |field|
        attr_reader(field)
      end
    end
  end
end
