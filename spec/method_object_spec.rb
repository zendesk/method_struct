require "rubygems"
require "bundler/setup"
require "method_object"

describe MethodObject do
  describe ".new" do
    it "creates a class method which calls the declared instance method with the given context" do
      argument1 = double("argument1")
      argument2 = double("argument2")
      verifier = double("verifier")
      verifier.should_receive(:poke).with(argument1, argument2)

      Example = Class.new(MethodObject.new(:perform, :x, :y)) do
        define_method(:perform) do
          verifier.poke(x, y)
        end
      end

      Example.perform(argument1, argument2)
    end
  end
end
