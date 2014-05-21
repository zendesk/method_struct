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

    it "creates a class method which calls the declared instance method with the given context" do
      verifier.should_receive(:poke).with(argument1, argument2)
      create_poker(verifier).call(argument1, argument2)
    end

    it "creates a hash version of the call method" do
      verifier.should_receive(:poke).with(argument1, argument2)
      create_poker(verifier).call(:x => argument1, :y => argument2)
    end

    it "creates a [] version of the call method" do
      verifier.should_receive(:poke).with(argument1, argument2)
      create_poker(verifier)[:x => argument1, :y => argument2]
    end

    it "creates a [] instance version of the call method" do
      verifier.should_receive(:poke).with(argument1, argument2)
      create_poker(verifier).new(:x => argument1, :y => argument2)[]
    end

    it "can change the name of the main method" do
      verifier.should_receive(:poke).with(argument1, argument2)

      the_verifier = verifier
      poker = Class.new(MethodStruct.new(:x, :y, :method_name => :something)) do
        define_method(:something) do
          the_verifier.poke(x, y)
        end
      end

      poker.something(argument1, argument2)
    end

    context "when method includes block" do
      def create_yielder
        Class.new(MethodStruct.new(:x, :y)) do
          define_method(:call) do |&block|
            block.call(x, y)
          end
        end
      end

      it "yields to block in class method" do
        expect(create_yielder.call(1, 2){ |x, y| x + y }).to eq(3)
      end

      it "yields to block in instance method" do
        expect(create_yielder.new(1, 2).call{ |x, y| x + y }).to eq(3)
      end

      it "yields to block in instance [] version of the call method" do
        expect(create_yielder.new(:x => 1, :y => 2).[]{ |x, y| x + y }).to eq(3)
      end
    end

    context "when :allow_missing => false" do
      let(:klass) { MethodStruct.new(:x, :y, :allow_missing => false) }

      it "does not allow creation without all arguments" do
        expect { klass.new(nil) }.to raise_error(ArgumentError)
      end

      it "does not allow creation without all hash arguments" do
        expect { klass.new(:y => nil) }.to raise_error(ArgumentError)
      end

      it "allows creation with all nil arguments" do
        expect { klass.new(nil, nil) }.not_to raise_error
      end
    end

    it "allows for additional methods defined with a block" do
      klass = MethodStruct.new(:x) do
        def something
          :value
        end
      end

      expect(klass.new(:y).something).to eq(:value)
    end

    describe "equality" do
      let(:struct) { MethodStruct.new(:a, :b) }

      it "is equal for equal arguments" do
        expect(struct.new(argument1, argument2) == struct.new(argument1, argument2)).to be_true
      end

      it "is eql for equal arguments" do
        expect(struct.new(argument1, argument2).eql?(struct.new(argument1, argument2))).to be_true
      end

      it "has equal hashes for equal arguments" do
        expect(struct.new(1, 2).hash).to eq(struct.new(1, 2).hash)
      end

      it "is unequal for unequal arguments" do
        expect(struct.new(argument1, argument2) == struct.new(argument2, argument1)).to be_false
      end

      it "is uneql for unequal arguments" do
        expect(struct.new(argument1, argument2).eql?(struct.new(argument2, argument1))).to be_false
      end

      it "is unequal for different MethodsStruct classes" do
        expect(MethodStruct.new(:a, :b).new(1, 2)).not_to eq(struct.new(1, 2))
      end

      it "has unequal hashes for unequal arguments (most of the time)" do
        expect(struct.new("something", "something else").hash).not_to eq(struct.new("more", "stuff").hash)
      end
    end

    context "when arguments are hashes" do
      let(:argument1) { { :things => true } }
      let(:argument2) { { :stuff => true } }

      it "handles them correctly" do
        verifier.should_receive(:poke).with(argument1, argument2)
        create_poker(verifier).call(argument1, argument2)
      end

      it "allows the single argument to be a hash" do
        verifier.should_receive(:poke).with(argument1)

        the_verifier = verifier
        poker = Class.new(MethodStruct.new(:x)) do
          define_method(:call) do
            the_verifier.poke(x)
          end
        end

        poker.call(argument1)
      end
    end
  end
end
