require 'rails_helper'

describe ActiveBillerAdapter do
  let(:args) { [{}] }

  subject { described_class.instance(*args) }

  context "by default" do
    describe ".instance(*args)" do
      it { expect(subject.class).to eq(Twilreapi::ActiveBiller::Base) }
    end
  end

  context "configuring a custom biller" do
    include Twilreapi::SpecHelpers::EnvHelpers

    let(:custom_biller_class_name) { "Twilreapi::ActiveBiller::MyBiller" }

    def setup_scenario
      stub_env(:active_biller_class_name => custom_biller_class_name)
    end

    before do
      setup_scenario
    end

    context "if the custom biller class is not defined" do
      describe ".instance(*args)" do
        it { expect(subject.class).to eq(Twilreapi::ActiveBiller::Base) }
      end
    end

    context "if the custom biller class is defined" do
      let(:meta_programming_helper) { MetaProgrammingHelper.new }

      let(:klass) do
        Class.new do
          def initialize(options = {})
          end

          def calculate_price_in_micro_units
            100
          end
        end
      end

      let(:custom_biller_class) { meta_programming_helper.safe_define_class(custom_biller_class_name, klass) }

      def setup_scenario
        super
        custom_biller_class
      end

      describe ".instance(*args)" do
        it { expect(subject.class).to eq(custom_biller_class) }
      end

      describe "#calculate_price_in_micro_units" do
        it { expect(subject.calculate_price_in_micro_units).to eq(100) }
      end
    end
  end
end
