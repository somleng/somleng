require "rails_helper"

RSpec.describe TariffScheduleCategoryType do
  it "handles tariff schedule categories" do
    klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :category, TariffScheduleCategoryType.new
    end

    expect(klass.new(category: "inbound_calls").category).to have_attributes(
      direction: have_attributes(inbound?: true),
      diagram_category: "CALL",
      diagram_direction_symbol: "<-",
      tariff_category: :call
    )
    expect(klass.new(category: "inbound_messages").category).to have_attributes(
      direction: have_attributes(inbound?: true),
      diagram_category: "MSG",
      diagram_direction_symbol: "<-",
      tariff_category: :message
    )
    expect(klass.new(category: "outbound_calls").category).to have_attributes(
      direction: have_attributes(outbound?: true),
      diagram_category: "CALL",
      diagram_direction_symbol: "->",
      tariff_category: :call
    )
    expect(klass.new(category: "outbound_messages").category).to have_attributes(
      direction: have_attributes(outbound?: true),
      diagram_category: "MSG",
      diagram_direction_symbol: "->",
      tariff_category: :message
    )
  end
end
