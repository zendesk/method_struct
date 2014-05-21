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
end
