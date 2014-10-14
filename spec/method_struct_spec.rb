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

    WithDefault = MethodStruct.new(:x, :y) do
      def call
        [x, y]
      end

      def x
        @x ||= 'default'
      end
    end

    it 'does not allow definition with strings' do
      expect{ MethodStruct.new('x', 'y') }.to raise_error(
        ArgumentError, 'only symbol fields allowed: ["x", "y"]')
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

    context "when :require_all => true" do
      let(:klass) { MethodStruct.new(:x, :y, :require_all => true) }

      it "does not allow creation without all arguments" do
        expect { klass.new(nil) }.to raise_error(ArgumentError, 'missing arguments: [:y]')
      end

      it "does not allow creation without all hash arguments" do
        expect { klass.new(:y => nil) }.to raise_error(ArgumentError, 'missing arguments: [:x]')
      end

      it "allows creation with all nil hash arguments" do
        expect { klass.new(:x => nil, :y => nil) }.not_to raise_error
      end

      it "allows creation with all nil arguments" do
        expect { klass.new(nil, nil) }.not_to raise_error
      end
    end

    context "when :require_presence => true" do
      let(:klass) { MethodStruct.new(:x, :y, :require_presence => true) }

      it "does not allow creation without all arguments being non-nil" do
        expect { klass.new(1, nil) }.to raise_error(ArgumentError, 'nil arguments: [:y]')
      end

      it "does not allow creation without all hash arguments being non-nil" do
        expect { klass.new(:x => 1, :y => nil) }.to raise_error(ArgumentError, 'nil arguments: [:y]')
      end

      it "allows creation with boolean hash arguments provided" do
        expect { klass.new(:x => false, :y => false) }.not_to raise_error
      end

      it "allows creation with boolean hash arguments provided" do
        expect { klass.new(false, false) }.not_to raise_error
      end

      it "allows creation with all hash symbol arguments provided" do
        expect { klass.new(:x => 1, :y => 2) }.not_to raise_error
      end

      it "allows creation with all arguments provided" do
        expect { klass.new(1, 2) }.not_to raise_error
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

      it "is unequal for unequal arguments" do
        expect(struct.new(argument1, argument2).eql?(struct.new(argument2, argument1))).to be_false
      end

      it "is unequal for different MethodsStruct classes" do
        expect(MethodStruct.new(:a, :b).new(1, 2)).not_to eq(struct.new(1, 2))
      end

      it "has unequal hashes for unequal arguments (most of the time)" do
        expect(struct.new("something", "something else").hash).not_to eq(struct.new("more", "stuff").hash)
      end
    end

    describe "#to_proc" do
      it "is possible to pass one as a block argument" do
        struct = MethodStruct.new(:x) do
          def call
            x.odd?
          end
        end

        expect([1, 2, 3].select(&struct)).to eq([1,3])
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

    it 'allows overriding default attr_readers' do
      WithDefault.call(:x => argument1, :y => argument2).should eq([argument1, argument2])
      WithDefault.call(:y => argument2).should eq(['default', argument2])
    end
  end
end
