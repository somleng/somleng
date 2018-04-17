# frozen_string_literal: true

require 'rails_helper'

describe ActiveBillerAdapter do
  describe '.instance(*args)' do
    it "returns the default biller class" do
      setup_custom_biller(nil)

      expect(
        described_class.instance.class
      ).to eq(Twilreapi::ActiveBiller::Base)
    end

    it 'returns the default biller class if no custom biller is defined' do
      setup_custom_biller('MyBiller')

      expect(described_class.instance.class).to eq(Twilreapi::ActiveBiller::Base)
    end

    it 'returns the custom biller class if defined' do
      custom_biller_class_name = 'MyBiller'
      setup_custom_biller(custom_biller_class_name)

      klass = Class.new do
        def initialize(options = {}); end

        def calculate_price_in_micro_units
          100
        end
      end

      custom_biller_class = MetaProgrammingHelper.new.safe_define_class(
        custom_biller_class_name, klass
      )

      instance = described_class.instance
      expect(instance.class).to eq(custom_biller_class)
      expect(instance.calculate_price_in_micro_units).to eq(100)
    end

    def setup_custom_biller(class_name)
      stub_secrets(active_biller_class_name: class_name)
      if class_name && Object.const_defined?(class_name.to_sym)
        Object.send(:remove_const, class_name.to_sym)
      end
    end
  end
end
