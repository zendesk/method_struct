module MethodStruct
  class ArgumentParser
    def initialize(options)
      @options = options
    end

    def call
      parsed_arguments.tap do |args|
        ArgumentVerifier.new(options.merge(:arguments => args)).call
      end
    end

    private
    attr_reader :options

    def fields
      options.fetch(:fields)
    end

    def raw_arguments
      options.fetch(:raw_arguments)
    end

    def parsed_arguments
      {}.tap do |h|
        fields.each do |field|
          h[field] = raw_arguments_hash[field] if raw_arguments_hash.key?(field)
        end
      end
    end

    def raw_arguments_hash
      @raw_arguments_hash ||= if fields.size > 1 && raw_arguments.size == 1 && raw_arguments.first.is_a?(Hash)
        raw_arguments.first
      else
        zipped_fields = fields.take(raw_arguments.count)
        Hash[*zipped_fields.zip(raw_arguments).flatten(1)]
      end
    end
  end
end
