require 'rails_helper'

describe ActiveCallRouterAdapter do
  let(:source) { "8557771" }
  let(:destination) { "85512345678" }
  let(:args) { [{:phone_call => "phone_call"}] }

  subject { described_class.instance(*args) }

  context "by default" do
    describe ".instance(*args)" do
      it { expect(subject.class).to eq(Twilreapi::ActiveCallRouter::Base) }
    end
  end

  context "configuring a custom call router" do
    include Twilreapi::SpecHelpers::EnvHelpers

    let(:custom_call_router_class_name) { "Twilreapi::ActiveCallRouter::MyCallRouter" }

    def setup_scenario
      stub_env(:active_call_router_class_name => custom_call_router_class_name)
    end

    before do
      setup_scenario
    end

    context "if the custom call router class is not defined" do
      describe ".instance(*args)" do
        it { expect(subject.class).to eq(Twilreapi::ActiveCallRouter::Base) }
      end
    end

    context "if the custom call router class is defined" do
      let(:meta_programming_helper) { MetaProgrammingHelper.new }

      let(:klass) do
        Class.new do
          def initialize(options = {})
          end

          def routing_instructions
            {"foo" => "bar"}
          end
        end
      end

      let(:custom_call_router_class) { meta_programming_helper.safe_define_class(custom_call_router_class_name, klass) }

      def setup_scenario
        super
        custom_call_router_class
      end

      describe ".instance(*args)" do
        it { expect(subject.class).to eq(custom_call_router_class) }
      end

      describe "#routing_instructions" do
        it { expect(subject.routing_instructions).to eq("foo" => "bar") }
      end
    end
  end
end
