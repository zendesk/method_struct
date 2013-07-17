require "rubygems"
require "bundler/setup"
require "method_struct"

describe MethodStruct do
  describe ".new" do
    let(:argument1) { double("argument1") }
    let(:argument2) { double("argument2") }
    let(:verifier) { double("verifier") }

    def create_poker(verifier)
      Class.new(MethodStruct.new(:x, :y)) do
        define_method(:call) do
          verifier.poke(x, y)
        end
      end
    end

    before { verifier.should_receive(:poke).with(argument1, argument2) }

    it "creates a class method which calls the declared instance method with the given context" do
      create_poker(verifier).call(argument1, argument2)
    end

    describe "when arguments are hashes" do
      let(:argument1) { { :things => true } }
      let(:argument2) { { :stuff => true } }

      it "handles them correctly" do
        create_poker(verifier).call(argument1, argument2)
      end
    end

    it "creates a hash version of the call method" do
      create_poker(verifier).call(:x => argument1, :y => argument2)
    end

    it "can change the name of the main method" do
      the_verifier = verifier
      poker = Class.new(MethodStruct.new(:x, :y, :method_name => :something)) do
        define_method(:something) do
          the_verifier.poke(x, y)
        end
      end

      poker.something(argument1, argument2)
    end
  end
end
