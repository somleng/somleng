require "rails_helper"

RSpec.describe OriginatorIDBehavior do
  describe "#resolve" do
    it "resolves passthrough" do
      behavior_definition = Data.define(:behavior) do
        def initialize(behavior:, **)
          super(behavior: behavior.to_s.inquiry, **)
        end

        delegate :passthrough?, :fallback?, :override?, to: :behavior
      end

      behavior = OriginatorIDBehavior.new(behavior_definition.new(behavior: :passthrough))
      expect(behavior.resolve(client_id: "1111", managed_id: "2222")).to eq("1111")

      behavior = OriginatorIDBehavior.new(behavior_definition.new(behavior: :fallback))
      expect(behavior.resolve(client_id: "1111", managed_id: "2222")).to eq("1111")
      expect(behavior.resolve(client_id: nil, managed_id: "2222")).to eq("2222")

      behavior = OriginatorIDBehavior.new(behavior_definition.new(behavior: :override))
      expect(behavior.resolve(client_id: "1111", managed_id: "2222")).to eq("2222")
    end
  end
end
