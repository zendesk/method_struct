module MethodStruct
  class ArgumentVerifier
    def initialize(fields, values, require_all, require_presence)
      @fields, @values = fields, values
      @require_all, @require_presence = require_all, require_presence
    end

    def verify
      if fields.size > 1 && values.size == 1 && values.first.is_a?(Hash)
        verify_hash
      else
        verify_normal
      end
    end

    private
    attr_reader :fields, :values, :require_all, :require_presence

    def verify_hash
      expected = fields.map(&:to_s).sort
      provided = values.first.keys.map(&:to_s).sort

      if require_all && !(expected - provided).empty?
        raise ArgumentError.new("wrong arguments provided")
      end

      if require_presence && !expected.all? { |arg| values.first[arg] || values.first[arg.to_s] }
        raise ArgumentError.new("nil arguments provided")
      end
    end

    def verify_normal
      if require_all && fields.count != values.count
        raise ArgumentError.new("wrong number of arguments (#{values.count} for #{fields.count})")
      end

      if require_presence && fields.count != values.compact.count
        raise ArgumentError.new("nil arguments provided")
      end
    end
  end
end
