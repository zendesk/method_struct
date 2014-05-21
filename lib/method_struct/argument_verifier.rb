module MethodStruct
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
end
