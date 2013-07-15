require "rubygems"
require "bundler/setup"
require "method_struct"

describe MethodStruct do
  describe ".new" do
    let(:argument1) { double("argument1") }
    let(:argument2) { double("argument2") }
    let(:verifier) { double("verifier") }

    def create_poker(method_name, verifier)
      Class.new(MethodStruct.new(:x, :y)) do
        define_method(method_name) do
          verifier.poke(x, y)
        end
      end
    end

    before { verifier.should_receive(:poke).with(argument1, argument2) }

    it "creates a class method which calls the declared instance method with the given context" do
      create_poker(:call, verifier).call(argument1, argument2)
    end

    it "creates a hash version of the call method" do
      create_poker(:call, verifier).call(:x => argument1, :y => argument2)
    end
  end
end
