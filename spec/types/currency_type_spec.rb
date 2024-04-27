require "rails_helper"

RSpec.describe CurrencyType do
  it "handles currency types" do
    klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :currency, CurrencyType.new
    end

    expect(klass.new(currency: Money::Currency.new("USD")).currency).to eq(Money::Currency.new("USD"))
    expect(klass.new(currency: "USD").currency).to eq(Money::Currency.new("USD"))
    expect(klass.new(currency: nil).currency).to eq(nil)
    expect(klass.new(currency: "invalid").currency).to eq(nil)
  end
end
