module MethodStruct
  class ArgumentVerifier
    def initialize(options)
      @options = options
    end

    def call
      verify_require_all
      verify_require_presence
    end

    private
    attr_reader :options

    def verify_require_all
      if options.fetch(:require_all)
        missing_arguments = fields - arguments.keys
        raise ArgumentError.new("missing arguments: #{missing_arguments.sort.inspect}") unless missing_arguments.empty?
      end
    end

    def verify_require_presence
      if options.fetch(:require_presence)
        nil_arguments = arguments.map{ |k, v| k if v.nil? }.compact
        raise ArgumentError.new("nil arguments: #{nil_arguments.sort.inspect}") unless nil_arguments.empty?
      end
    end

    def fields
      options.fetch(:fields)
    end

    def arguments
      options.fetch(:arguments)
    end
  end
end
