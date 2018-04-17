# frozen_string_literal: true

require 'rails_helper'

describe ActiveCallRouterAdapter do
  describe '.instance(*args)' do
    it 'returns the default call router adapter' do
      expect(
        described_class.instance.class
      ).to eq(Twilreapi::ActiveCallRouter::Base)
    end

    it 'returns the default class if no custom call router is defined' do
      setup_custom_call_router('MyCallRouter')
      expect(
        described_class.instance.class
      ).to eq(Twilreapi::ActiveCallRouter::Base)
    end

    it 'returns the custom call router if defined', :focus do
      custom_call_router_class_name = 'MyCallRouter'
      setup_custom_call_router(custom_call_router_class_name)

      klass = Class.new do
        def initialize(options = {}); end

        def routing_instructions
          { 'foo' => 'bar' }
        end
      end

      custom_call_router_class = MetaProgrammingHelper.new.safe_define_class(
        custom_call_router_class_name, klass
      )

      instance = described_class.instance
      expect(instance.class).to eq(custom_call_router_class)
      expect(instance.routing_instructions).to eq('foo' => 'bar')
    end

    def setup_custom_call_router(class_name)
      stub_secrets(active_call_router_class_name: class_name)
      Object.send(:remove_const, class_name.to_sym) if Object.const_defined?(class_name.to_sym)
    end
  end
end
