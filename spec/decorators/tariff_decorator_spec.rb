require "rails_helper"

RSpec.describe TariffDecorator do
  it "decorates a tariff" do
    call_tariff = build_stubbed(
      :tariff, :call,
      rate_cents: InfinitePrecisionMoney.from_amount(0.005, "USD").cents
    )
    expect(TariffDecorator.new(call_tariff)).to have_attributes(
      rate: "$0.005 / min"
    )

    message_tariff = build_stubbed(
      :tariff, :message,
      rate_cents: InfinitePrecisionMoney.from_amount(0.005, "USD").cents
    )
    expect(TariffDecorator.new(message_tariff)).to have_attributes(
      rate: "$0.005"
    )
  end
end
